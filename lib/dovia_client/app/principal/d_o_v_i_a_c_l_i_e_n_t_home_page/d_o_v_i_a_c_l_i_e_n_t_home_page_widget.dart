import '/domain/property_location.dart';
import '/shared_components/app_tutorial/app_tutorial.dart';
import '/shared_components/fixed_dovia_icon/fixed_dovia_icon_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/domain/property_owner.dart';
import 'dart:async';

import '/domain/offer_json.dart' show firstPropertyPhotoUrl;
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/agregar_favorito_a_carpeta_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';
import '/shared_components/dovia_suupport_messages/dovia_suupport_messages_widget.dart';
import '/shared_components/visitor_restriction_popup/visitor_restriction_popup_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/dovia_client/app/principal/new_projects.dart';
import '/domain/offer_json.dart';
import '/index.dart';
import '/dovia_client/app/mis_favoritos/tus_favoritos_carpetas_modal/tus_favoritos_carpetas_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/shared_components/notification_badge.dart';
import 'd_o_v_i_a_c_l_i_e_n_t_home_page_model.dart';
export 'd_o_v_i_a_c_l_i_e_n_t_home_page_model.dart';

class DOVIACLIENTHomePageWidget extends StatefulWidget {
  const DOVIACLIENTHomePageWidget({super.key});

  static String routeName = 'DOVIA_CLIENT_HomePage';
  static String routePath = '/dOVIACLIENTHomePage';

  @override
  State<DOVIACLIENTHomePageWidget> createState() =>
      _DOVIACLIENTHomePageWidgetState();
}

class _DOVIACLIENTHomePageWidgetState extends State<DOVIACLIENTHomePageWidget> {
  late DOVIACLIENTHomePageModel _model;
  Set<String> _favoritePropertyIds = <String>{};

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isHouseFavorite(dynamic eachHouseItem) {
    final propertyId = getJsonField(eachHouseItem, r'''$.id''').toString();
    final payloadFavorite = getJsonField(
              eachHouseItem,
              r'''$.isFavorite''',
            ) ==
            true ||
        getJsonField(
              eachHouseItem,
              r'''$.isFavorite''',
            ).toString().toLowerCase() ==
            'true' ||
        getJsonField(
              eachHouseItem,
              r'''$.isFavorite''',
            ).toString() ==
            '1';

    return _favoritePropertyIds.contains(propertyId) || payloadFavorite;
  }

  /// Foto principal que manda el backend para la propiedad. El listado de
  /// propiedades hoy no incluye ninguna, y ahi la tarjeta se queda con su
  /// imagen por defecto.
  Future<ApiCallResponse>? _newProjectsFuture;

  /// Proyectos Nuevos: `GET /properties?isMock=true`. Pedido aparte del resto
  /// de Inicio, así un fallo acá no afecta a los demás carruseles.
  Future<ApiCallResponse> _newProjects() => _newProjectsFuture ??=
          DOVIAAPIPropertyContextGroup.listPropertiesCall.call(
        page: '1',
        limit: '$kNewProjectsLimit',
        isMock: 'true',
        authToken: currentAuthenticationToken,
      );

  Widget _buildNewProjects() {
    return FutureBuilder<ApiCallResponse>(
      future: _newProjects(),
      builder: (context, snapshot) {
        final response = snapshot.data;
        if (response == null) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        if (!response.succeeded) {
          return Row(
            children: [
              const Expanded(
                child: Text('No pudimos cargar los proyectos nuevos.'),
              ),
              TextButton(
                onPressed: () => safeSetState(() => _newProjectsFuture = null),
                child: const Text('Reintentar'),
              ),
            ],
          );
        }
        final projects = NewProject.listFrom(response.jsonBody);
        if (projects.isEmpty) {
          return const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text('Aún no hay proyectos nuevos.'),
          );
        }
        // Con uno o dos proyectos quedaba centrado; va alineado como los
        // demás carruseles.
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final project in projects)
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    // Sin ficha en la app: abre su página en el sitio de
                    // desarrollos, como la web.
                    onTap: () => _handleRestrictedAction(
                        () async => launchURL(project.url)),
                    child: custom_widgets.DoviaClientHouseCard(
                      width: 210.0,
                      height: 0.0,
                      imageUrl: project.imageUrl ?? '',
                      name: project.name,
                      type: project.listingType,
                      priceLabel: project.priceLabel,
                      priceCaption: project.hasPrice ? 'Precio desde' : null,
                      propertyType: project.propertyType,
                      location: project.location,
                      landArea: project.landArea,
                      constructionArea: project.constructionArea,
                      bedrooms: project.bedrooms,
                      bathrooms: project.bathrooms,
                      parkingSpots: project.parkingSpots,
                      dashEmptySpecs: true,
                      // Flecha al sitio en vez de corazón: no se pueden guardar
                      // en favoritos.
                      isNewProject: true,
                    ),
                  ),
              ].divide(const SizedBox(width: 16.0)),
            ),
          ),
        );
      },
    );
  }

  String _houseImageUrl(dynamic house) {
    if (house is! Map) {
      return '';
    }
    return firstPropertyPhotoUrl(Map<String, dynamic>.from(house)) ?? '';
  }

  /// Cuantas tarjetas muestra cada carrusel del Home.
  static const int _carouselSize = 5;

  /// Cuántos bloques extra de [_carouselSize] cargó cada carrusel, por clave.
  /// Los bloques se acumulan: el carrusel muestra todo lo cargado y se
  /// recorre libremente con el gesto.
  final Map<String, int> _carouselPages = <String, int>{};

  /// Scroll horizontal de cada carrusel, por clave.
  final Map<String, ScrollController> _carouselControllers =
      <String, ScrollController>{};

  /// Ancho de una tarjeta más la separación entre tarjetas.
  static const double _carouselItemExtent = 210.0 + 16.0;

  ScrollController _carouselController(String carouselKey) =>
      _carouselControllers.putIfAbsent(carouselKey, ScrollController.new);

  /// Vuelve todos los carruseles al principio (cambió el filtro).
  void _resetCarousels() {
    _carouselPages.clear();
    for (final controller in _carouselControllers.values) {
      if (controller.hasClients) controller.jumpTo(0);
    }
  }

  /// Los botones Comprar y Rentar filtran los carruseles por tipo de
  /// operacion. Sin ninguno seleccionado se muestran todas las propiedades.
  List<dynamic> _filterByListingType(List<dynamic> houses) {
    // El usuario no ve sus propias publicaciones ni en los carruseles ni en
    // la búsqueda.
    houses = houses.where((house) => !isOwnProperty(house)).toList();
    final selected = _model.comprarORentar;
    if (selected.isEmpty) {
      return houses;
    }

    final wanted = selected == 'rentar' ? 'RENT' : 'SALE';
    return houses.where((house) {
      final listingType = getJsonField(house, r'''$.listingType''');
      if (listingType is List) {
        return listingType
            .any((type) => type.toString().toUpperCase().contains(wanted));
      }
      return listingType.toString().toUpperCase().contains(wanted);
    }).toList();
  }

  static const _listingHintKey = 'home_listing_hint_seen';
  bool _showListingHint = false;

  Future<void> _loadListingHint() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _showListingHint =
        !(prefs.getBool('${_listingHintKey}_$currentUserUid') ?? false));
  }

  Future<void> _dismissListingHint() async {
    if (!_showListingHint) return;
    setState(() => _showListingHint = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_listingHintKey}_$currentUserUid', true);
  }

  /// Botón Comprar/Rentar. Seleccionado: verde oscuro con texto e ícono
  /// blancos. Si el otro está seleccionado, queda gris como desactivado.
  /// Los cambios se animan.
  Widget _listingToggle(String value, String label, String asset) {
    const duration = Duration(milliseconds: 450);
    const curve = Curves.easeInOutCubic;
    const dark = Color(0xFF007376);
    const grey = Color(0xFF9E9E9E);
    final selected = _model.comprarORentar == value;
    final otherSelected = _model.comprarORentar.isNotEmpty && !selected;
    final theme = FlutterFlowTheme.of(context);
    final Color background = selected
        ? dark
        : otherSelected
            ? const Color(0xFFF0F0F0)
            : const Color(0xFFE6ECED);
    final Color foreground = selected
        ? Colors.white
        : otherSelected
            ? grey
            : theme.primaryText;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
      child: GestureDetector(
        onTap: () {
          _dismissListingHint();
          _handleRestrictedAction(() {
            _model.comprarORentar = selected ? '' : value;
            _resetCarousels();
            safeSetState(() {});
          });
        },
        child: AnimatedScale(
          scale: selected ? 1.03 : 1.0,
          duration: duration,
          curve: curve,
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: 144.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x33000000)
                      : const Color(0x00000000),
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 3.0),
                ),
              ],
            ),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: foreground),
              duration: duration,
              curve: curve,
              builder: (context, color, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    asset,
                    width: 20.0,
                    height: 20.0,
                    fit: BoxFit.cover,
                    // El ícono siempre toma el color del texto: el SVG del
                    // carrito es claro y no se veía sobre el fondo.
                    colorFilter: color == null
                        ? null
                        : ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    label,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      color: color,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          selected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Las propiedades cargadas hasta ahora en el carrusel.
  /// Recién registrado o con el token recién renovado, la primera consulta
  /// puede fallar y el carrusel quedaba vacío hasta que algo reconstruía la
  /// pantalla. Mientras falle se sigue mostrando el spinner y se reintenta.
  int _carouselRetries = 0;
  bool _carouselRetryScheduled = false;

  /// Una sola consulta compartida por los tres carruseles. Antes se volvía a
  /// pedir en cada reconstrucción de la pantalla (y volvía el spinner, o un
  /// "no hay propiedades" momentáneo); ahora se pide una vez y se reusa.
  Future<ApiCallResponse>? _propertiesFuture;

  /// Última respuesta buena: una vez que hubo propiedades, se siguen
  /// mostrando aunque un reintento falle o esté en curso.
  ApiCallResponse? _lastProperties;

  Future<ApiCallResponse> _properties() => _propertiesFuture ??=
      DOVIAAPIPropertyContextGroup.listPropertiesCall.call(
          limit: '40',
          // Sin los proyectos nuevos: no tienen ficha en la app (404).
          isMock: 'false',
          authToken: currentAuthenticationToken);

  /// Respuesta a mostrar, o null mientras no haya ninguna buena (spinner).
  ApiCallResponse? _carouselResponse(AsyncSnapshot<ApiCallResponse> snap) {
    final response = snap.data;
    if (response != null && response.succeeded) {
      _lastProperties = response;
      return response;
    }
    if (_lastProperties != null) return _lastProperties;
    if (response == null) return null;
    if (_carouselRetries >= 6) return response;
    if (!_carouselRetryScheduled) {
      _carouselRetryScheduled = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _carouselRetryScheduled = false;
        _carouselRetries++;
        _propertiesFuture = null;
        safeSetState(() {});
      });
    }
    return null;
  }

  Widget _carouselEmpty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            text,
            style: GoogleFonts.publicSans(
                color: const Color(0xFF8A8A8A), fontSize: 13.0),
          ),
        ),
      );

  List<dynamic> _carouselPage(String carouselKey, List<dynamic> houses) {
    final loaded = ((_carouselPages[carouselKey] ?? 0) + 1) * _carouselSize;
    return houses.take(loaded).toList();
  }

  /// Carga el siguiente bloque y lleva el carrusel a su primera tarjeta.
  void _loadMoreCarousel(String carouselKey, int total,
      {bool scrollToNew = false}) {
    final page = _carouselPages[carouselKey] ?? 0;
    final loaded = (page + 1) * _carouselSize;
    if (loaded >= total) return;
    _carouselPages[carouselKey] = page + 1;
    safeSetState(() {});
    // Con el gesto no se mueve nada: las nuevas ya están cargadas antes de
    // llegar al borde y el scroll sigue de forma natural. Sólo la flecha
    // lleva a la primera de las nuevas.
    if (!scrollToNew) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _carouselControllers[carouselKey];
      if (controller == null ||
          !controller.hasClients ||
          !controller.position.hasContentDimensions) {
        return;
      }
      final target = (loaded * _carouselItemExtent)
          .clamp(0.0, controller.position.maxScrollExtent);
      controller.animateTo(target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    });
  }

  /// Las flechas avanzan o retroceden un ancho de pantalla; al llegar al
  /// final, la de avanzar carga el bloque siguiente.
  void _moveCarousel(String carouselKey, int step, int total) {
    final controller = _carouselController(carouselKey);
    if (!controller.hasClients || !controller.position.hasContentDimensions) {
      return;
    }
    final position = controller.position;
    if (step > 0 && position.pixels >= position.maxScrollExtent - 1) {
      _loadMoreCarousel(carouselKey, total, scrollToNew: true);
      return;
    }
    final target = (position.pixels + step * position.viewportDimension)
        .clamp(0.0, position.maxScrollExtent);
    controller.animateTo(target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic);
  }

  /// Flecha discreta dentro de un circulo claro.
  Widget _carouselArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 6.0,
              color: Color(0x26000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        child: Icon(
          icon,
          color: FlutterFlowTheme.of(context).primaryText,
          size: 20.0,
        ),
      ),
    );
  }

  /// Las flechas van superpuestas al carrusel para no robarle ancho a la
  /// pantalla. La de volver solo aparece cuando hay algo atras. Al llegar al
  /// final con el gesto se cargan solas las siguientes propiedades.
  Widget _withCarouselArrows({
    required String carouselKey,
    required int total,
    required Widget child,
  }) {
    final controller = _carouselController(carouselKey);
    bool hasMore() =>
        ((_carouselPages[carouselKey] ?? 0) + 1) * _carouselSize < total;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis != Axis.horizontal) return false;
            // Scroll infinito estándar: se carga el bloque siguiente un poco
            // antes de llegar al final, así nunca se siente el tope.
            final nearEnd = notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 2 * _carouselItemExtent;
            if (notification is ScrollUpdateNotification &&
                nearEnd &&
                hasMore()) {
              _loadMoreCarousel(carouselKey, total);
            }
            return false;
          },
          child: child,
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final hasClients = controller.hasClients &&
                controller.position.hasContentDimensions;
            final pixels = hasClients ? controller.position.pixels : 0.0;
            final max = hasClients ? controller.position.maxScrollExtent : 0.0;
            final hasPrevious = pixels > 1;
            final hasNext = pixels < max - 1 || hasMore();
            return Positioned.fill(
              child: Stack(
                children: [
                  if (hasPrevious)
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: _carouselArrow(
                        icon: Icons.chevron_left,
                        onTap: () => _moveCarousel(carouselKey, -1, total),
                      ),
                    ),
                  if (hasNext)
                    Align(
                      alignment: const AlignmentDirectional(1.0, 0.0),
                      child: _carouselArrow(
                        icon: Icons.chevron_right,
                        onTap: () => _moveCarousel(carouselKey, 1, total),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _refreshFavoritePropertyIds() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;

    final favoriteIds = <String>{};

    final defaultFavoritesResponse =
        await DOVIAAPIFavoriteContextGroup.getDefaultFavoritesCall.call(
      authToken: token,
      // Sin límite el backend devuelve 20 y los favoritos siguientes salían
      // con el corazón vacío. 100 es el máximo de los listados.
      limit: '100',
    );
    if (defaultFavoritesResponse.succeeded) {
      final defaultFavorites = getJsonField(
        defaultFavoritesResponse.jsonBody,
        r'''$.data''',
      ).toList();
      for (final item in defaultFavorites) {
        final id = getJsonField(item, r'''$.id''').toString();
        final propertyId = getJsonField(item, r'''$.propertyId''').toString();
        if (id.isNotEmpty && id != 'null') favoriteIds.add(id);
        if (propertyId.isNotEmpty && propertyId != 'null') {
          favoriteIds.add(propertyId);
        }
      }
    }

    final foldersResponse =
        await DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall.call(
      authToken: token,
    );
    if (foldersResponse.succeeded) {
      final folders = DOVIAAPIFavoriteContextGroup.getAllFavoriteFoldersCall
              .folders(foldersResponse.jsonBody)
              ?.toList() ??
          [];
      for (final folder in folders) {
        final folderId = getJsonField(folder, r'''$.id''').toString();
        if (folderId.isEmpty || folderId == 'null') continue;

        final folderFavoritesResponse =
            await DOVIAAPIFavoriteContextGroup.getFavoritesInFolderCall.call(
          authToken: token,
          folderId: folderId,
          limit: '100',
        );
        if (!folderFavoritesResponse.succeeded) continue;

        final folderFavorites = getJsonField(
          folderFavoritesResponse.jsonBody,
          r'''$.data.favorites''',
        ).toList();
        for (final item in folderFavorites) {
          final id = getJsonField(item, r'''$.id''').toString();
          final propertyId = getJsonField(item, r'''$.propertyId''').toString();
          if (id.isNotEmpty && id != 'null') favoriteIds.add(id);
          if (propertyId.isNotEmpty && propertyId != 'null') {
            favoriteIds.add(propertyId);
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _favoritePropertyIds = favoriteIds;
    });
  }

  // ── Búsqueda del Home ─────────────────────────────────────────────────
  // Al empezar a escribir se traen de nuevo todas las propiedades publicadas
  // y se filtran en la app por nombre, descripción, dirección, tipo y precio.
  // Mientras hay texto, los carruseles se reemplazan por uno solo con las
  // coincidencias.

  String _searchQuery = '';
  Timer? _searchDebounce;
  List<dynamic>? _searchPool;
  bool _searchLoading = false;
  String? _searchError;
  int _searchRequest = 0;

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      // Se borró la búsqueda: la próxima vuelve a pedir las propiedades.
      _searchRequest++;
      safeSetState(() {
        _searchQuery = '';
        _searchPool = null;
        _searchLoading = false;
        _searchError = null;
      });
      return;
    }
    if (_searchQuery.isEmpty && _searchPool == null && !_searchLoading) {
      _fetchSearchPool();
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _carouselPages.remove('busqueda');
      final c = _carouselControllers['busqueda'];
      if (c != null && c.hasClients) c.jumpTo(0);
      safeSetState(() => _searchQuery = query);
    });
  }

  Future<void> _fetchSearchPool() async {
    final request = ++_searchRequest;
    safeSetState(() {
      _searchLoading = true;
      _searchError = null;
    });
    const pageSize = 100;
    final all = <dynamic>[];
    String? error;
    for (var page = 1; page <= 20; page++) {
      final res = await DOVIAAPIPropertyContextGroup.listPropertiesCall.call(
        page: '$page',
        limit: '$pageSize',
        isMock: 'false',
        authToken: currentAuthenticationToken,
      );
      if (!res.succeeded) {
        error = 'No se pudieron cargar las propiedades.';
        break;
      }
      final data = getJsonField(res.jsonBody, r'''$.data''');
      if (data is! List || data.isEmpty) break;
      all.addAll(data);
      if (data.length < pageSize) break;
    }
    if (!mounted || request != _searchRequest) return;
    safeSetState(() {
      _searchLoading = false;
      _searchPool = all;
      _searchError = all.isEmpty ? error : null;
    });
  }

  static String _normalize(String input) {
    var s = input.toLowerCase();
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    return s;
  }

  String _searchText(dynamic house) {
    String field(String path) {
      final v = getJsonField(house, path);
      return v == null ? '' : v.toString();
    }

    final price = field(r'''$.price''');
    return _normalize([
      field(r'''$.name'''),
      field(r'''$.description.raw'''),
      field(r'''$.description'''),
      field(r'''$.location.address.fullAddress'''),
      field(r'''$.address'''),
      field(r'''$.propertyType'''),
      field(r'''$.listingType'''),
      price,
      price.replaceAll(RegExp(r'[^0-9]'), ''),
    ].join(' '));
  }

  List<dynamic> _searchResults() {
    final pool = _filterByListingType(_searchPool ?? const []);
    final words = _normalize(_searchQuery)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map(
            (w) => w.replaceAll(RegExp(r'^(q|\$)(?=\d)|(?<=\d)[.,](?=\d)'), ''))
        .toList();
    return pool.where((house) {
      final text = _searchText(house);
      return words.every(text.contains);
    }).toList();
  }

  Widget _buildSearchResults() {
    final theme = FlutterFlowTheme.of(context);
    final titleStyle = theme.bodyMedium.override(
      font: GoogleFonts.inter(),
      letterSpacing: 0.0,
    );

    Widget body;
    if (_searchLoading || (_searchPool == null && _searchError == null)) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(color: theme.primary),
        ),
      );
    } else if (_searchError != null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Text(_searchError!, style: titleStyle),
            TextButton(
              onPressed: _fetchSearchPool,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } else {
      final results = _searchResults();
      if (results.isEmpty) {
        body = Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 44.0, color: theme.secondaryText),
              const SizedBox(height: 10.0),
              Text(
                'No encontramos propiedades con "$_searchQuery"',
                textAlign: TextAlign.center,
                style: titleStyle.copyWith(color: theme.secondaryText),
              ),
            ],
          ),
        );
      } else {
        final page = _carouselPage('busqueda', results);
        body = _withCarouselArrows(
          carouselKey: 'busqueda',
          total: results.length,
          child: SingleChildScrollView(
            controller: _carouselController('busqueda'),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: page
                  .map<Widget>((house) => _houseCardItem(house))
                  .toList()
                  .divide(const SizedBox(width: 16.0)),
            ),
          ),
        );
      }
    }

    final count = (!_searchLoading && _searchPool != null)
        ? _searchResults().length
        : null;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count == null
                ? 'Buscando…'
                : count == 1
                    ? '1 resultado'
                    : '$count resultados',
            style: titleStyle,
          ),
          const SizedBox(height: 8.0),
          body,
        ],
      ),
    );
  }

  /// Tarjeta de una propiedad, igual en los carruseles y en la búsqueda.
  Widget _houseCardItem(dynamic eachHouseItem) {
    return Builder(
      builder: (context) => InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          context.pushNamed(
            DOVIACLIENTPropiedadSeleccionadaNewWidget.routeName,
            queryParameters: {
              'propertyId': serializeParam(
                getJsonField(
                  eachHouseItem,
                  r'''$.id''',
                ).toString(),
                ParamType.String,
              ),
            }.withoutNulls,
          );
        },
        onLongPress: () async {
          await showDialog(
            context: context,
            builder: (dialogContext) {
              return Dialog(
                elevation: 0,
                insetPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                alignment: const AlignmentDirectional(0.0, 0.0)
                    .resolve(Directionality.of(context)),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(dialogContext).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: AgregarFavoritoACarpetaWidget(
                    houseId: getJsonField(
                      eachHouseItem,
                      r'''$.id''',
                    ).toString(),
                  ),
                ),
              );
            },
          );
        },
        child: custom_widgets.DoviaClientHouseCard(
          width: 210.0,
          height: 0.0,
          imageUrl: _houseImageUrl(eachHouseItem),
          isFavorite: _isHouseFavorite(eachHouseItem),
          name: getJsonField(
            eachHouseItem,
            r'''$.name''',
          ).toString(),
          type: getJsonField(
            eachHouseItem,
            r'''$.listingType''',
          ).toString(),
          price: getJsonField(
            eachHouseItem,
            r'''$.price''',
          ).toString(),
          propertyType:
              getJsonField(eachHouseItem, r'''$.propertyType''')?.toString(),
          constructionArea: castToType<int>(getJsonField(
              eachHouseItem, r'''$.features.general.constructionArea''')),
          landArea: castToType<double>(
              getJsonField(eachHouseItem, r'''$.features.general.landArea''')),
          bedrooms: castToType<int>(
              getJsonField(eachHouseItem, r'''$.features.general.bedrooms''')),
          bathrooms: castToType<int>(
              getJsonField(eachHouseItem, r'''$.features.general.bathrooms''')),
          location: propertyLocationLabel(eachHouseItem),
          parkingSpots: castToType<int>(getJsonField(
              eachHouseItem, r'''$.features.general.parkingSpots''')),
          hasDiscount: getJsonField(eachHouseItem, r'''$.hasDiscount''') ==
                  true ||
              getJsonField(eachHouseItem, r'''$.hasDiscount''').toString() ==
                  'true',
          originalPrice:
              getJsonField(eachHouseItem, r'''$.originalPrice''')?.toString(),
          propertyId: getJsonField(
            eachHouseItem,
            r'''$.id''',
          ).toString(),
          authToken: currentAuthenticationToken,
          onAddToFavorites: () async {
            if (FFAppState().UserRole != 'VISITOR') {
              _model.addFavoriteNew = await DOVIAAPIFavoriteContextGroup
                  .addPropertyToFavoritesCall
                  .call(
                propertyId: getJsonField(
                  eachHouseItem,
                  r'''$.id''',
                ).toString(),
                authToken: currentAuthenticationToken,
              );

              final addFavoriteResponse = _model.addFavoriteNew;
              final isAlreadyFavorite =
                  (addFavoriteResponse?.statusCode == 409) ||
                      (addFavoriteResponse?.jsonBody ?? '')
                          .toString()
                          .toLowerCase()
                          .contains('already');

              if ((addFavoriteResponse?.succeeded ?? false) ||
                  isAlreadyFavorite) {
                if (!context.mounted) return;
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: TusFavoritosCarpetasModalWidget(
                          isCreatingNewFolderPARAM: false,
                          houseId: getJsonField(
                            eachHouseItem,
                            r'''$.id''',
                          ).toString(),
                          propertyName: getJsonField(
                            eachHouseItem,
                            r'''$.name''',
                          ).toString(),
                          propertyImage: _modalImage(eachHouseItem),
                          propertyIsFavorite: true,
                        ),
                      ),
                    );
                  },
                ).then((value) => safeSetState(() {}));
              } else {
                if (!context.mounted) return;
                await showDialog(
                  context: context,
                  builder: (alertDialogContext) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text(
                          (addFavoriteResponse?.jsonBody ?? '').toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(alertDialogContext),
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
              }
            } else {
              await showDialog(
                context: context,
                builder: (dialogContext) {
                  return Dialog(
                    elevation: 0,
                    insetPadding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    alignment: const AlignmentDirectional(0.0, 0.0)
                        .resolve(Directionality.of(context)),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(dialogContext).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: const VisitorRestrictionPopupWidget(),
                    ),
                  );
                },
              );
            }

            safeSetState(() {});
          },
          onRemoveFromFavorites: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: false,
              context: context,
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: TusFavoritosCarpetasModalWidget(
                      isCreatingNewFolderPARAM: false,
                      houseId: getJsonField(
                        eachHouseItem,
                        r'''$.id''',
                      ).toString(),
                      propertyName: getJsonField(
                        eachHouseItem,
                        r'''$.name''',
                      ).toString(),
                      propertyImage: _modalImage(eachHouseItem),
                      propertyIsFavorite: true,
                    ),
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));

            safeSetState(() {});
          },
        ),
      ),
    );
  }

  /// "Ver más" como texto sin fondo, igual que en Mis Visitas y Mis Ofertas.
  Widget _verMasLink({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        'Ver más',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primary,
              fontSize: 14.0,
            ),
      ),
    );
  }

  /// Títulos de los carruseles del home, como los de las otras pantallas.
  TextStyle get _carouselTitleStyle =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
            fontSize: 17.0,
            letterSpacing: 0.33,
            fontWeight: FontWeight.w600,
            lineHeight: 1.3,
          );

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DOVIACLIENTHomePageModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _loadListingHint();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      // Primero las propias, para sacarlas de los carruseles.
      await loadOwnPropertyIds();
      safeSetState(() {});
      await _refreshFavoritePropertyIds();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  @override
  void dispose() {
    for (final controller in _carouselControllers.values) {
      controller.dispose();
    }
    _searchDebounce?.cancel();
    _pageScroll.dispose();
    _model.dispose();

    super.dispose();
  }

  Future<void> _handleRestrictedAction(Function() action) async {
    if (FFAppState().UserRole == 'VISITOR') {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: const AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(dialogContext).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: const VisitorRestrictionPopupWidget(),
            ),
          );
        },
      );
    } else {
      action();
    }
  }

  /// Boton redondo de la cabecera. El mapa del hero usa el mismo aspecto.
  // ── Tutorial de bienvenida ────────────────────────────────────────────────
  final _pageScroll = ScrollController();
  final _tutorialHomeKey = GlobalKey();
  final _tutorialMapKey = GlobalKey();
  final _tutorialMessagesKey = GlobalKey();
  final _tutorialNotificationsKey = GlobalKey();
  final _tutorialSettingsKey = GlobalKey();
  final _navbarKeys = {
    for (final k in [
      'propiedades',
      'visitas',
      'doviaHome',
      'ofertas',
      'favoritos'
    ])
      k: GlobalKey(),
  };

  /// La primera vez que un cliente entra (recién registrado o primer inicio
  /// de sesión en este teléfono) se le muestra el tutorial.
  Future<void> _maybeShowTutorial() async {
    if (FFAppState().UserRole != 'CLIENT') return;
    final userId = currentUserUid;
    if (userId.isEmpty) return;
    if (await AppTutorial.isDone('client_home', userId)) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_pageScroll.hasClients) _pageScroll.jumpTo(0);
    final shown = await AppTutorial.show(context, [
      const TutorialStep(
        title: '¡Bienvenido a DOVIA!',
        text: 'La plataforma donde puedes comprar, vender y rentar '
            'propiedades, y contratar servicios para tu hogar.',
      ),
      TutorialStep(
        title: 'Inicio',
        text: 'Busca propiedades describiendo con tus palabras lo que '
            'quieres, elige entre comprar y rentar y descubre lo nuevo, '
            'proyectos nuevos y recomendaciones.',
        target: () => rectOfKey(_tutorialHomeKey),
      ),
      TutorialStep(
        title: 'Mapa',
        text: 'Explora las propiedades en el mapa y filtra por zona para '
            'encontrar las que están donde quieres vivir.',
        target: () => rectOfKey(_tutorialMapKey),
      ),
      TutorialStep(
        title: 'Propiedades',
        text: 'Publica tus propiedades, revisa sus métricas y acepta '
            'visitas u ofertas.',
        target: () => rectOfKey(_navbarKeys['propiedades']!),
      ),
      TutorialStep(
        title: 'Visitas',
        text: 'Consulta el estado de las visitas que solicitaste.',
        target: () => rectOfKey(_navbarKeys['visitas']!),
      ),
      TutorialStep(
        title: 'Ofertas',
        text: 'Revisa las ofertas que enviaste, su estado y las '
            'contraofertas que recibiste.',
        target: () => rectOfKey(_navbarKeys['ofertas']!),
      ),
      TutorialStep(
        title: 'Favoritos',
        text: 'Guarda las propiedades que te gustan y organízalas en '
            'carpetas.',
        target: () => rectOfKey(_navbarKeys['favoritos']!),
      ),
      TutorialStep(
        title: 'DOVIA Home',
        text: 'Suscríbete a DOVIA Home para contratar servicios para tu '
            'hogar.',
        target: () => rectOfKey(_navbarKeys['doviaHome']!),
      ),
      TutorialStep(
        title: 'Ajustes',
        text: 'Edita tu perfil y tus datos, administra tu suscripción y '
            'la seguridad de tu cuenta.',
        target: () => rectOfKey(_tutorialSettingsKey),
      ),
      TutorialStep(
        title: 'Notificaciones',
        text: 'Aquí te avisamos de novedades sobre tus visitas, ofertas y '
            'trámites.',
        target: () => rectOfKey(_tutorialNotificationsKey),
      ),
      TutorialStep(
        title: 'Soporte',
        text: 'Escríbenos si necesitas ayuda: el equipo de DOVIA te '
            'responde por aquí.',
        target: () => rectOfKey(_tutorialMessagesKey),
      ),
      TutorialStep(
        title: 'Soporte siempre a mano',
        text: 'También puedes abrir soporte desde este ícono. Arrástralo '
            'con el dedo para ubicarlo donde prefieras en la pantalla.',
        target: () => FixedDoviaIconWidget.lastRect,
      ),
    ]);
    // Otra instancia de la home ya lo está mostrando: lo marca ella al terminar.
    if (!shown) return;
    await AppTutorial.markDone('client_home', userId);
  }

  Widget _headerAction({
    required String asset,
    required Future<void> Function() onTap,
    Key? key,
  }) {
    return InkWell(
      key: key,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8.0,
              color: Color(0x1A000000),
              offset: Offset(0.0, 2.0),
            )
          ],
        ),
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: withNotificationBadge(
          asset,
          SvgPicture.asset(
            asset,
            width: 22.0,
            height: 22.0,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// Foto principal de la casa para el modal de carpetas de favoritos.
  String _modalImage(dynamic house) => house is Map
      ? firstPropertyPhotoUrl(Map<String, dynamic>.from(house)) ?? ''
      : '';

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        // El teclado tapa la barra de navegación en vez de empujarla.
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              wrapWithModel(
                model: _model.cornerGradientBackgroundModel,
                updateCallback: () => safeSetState(() {}),
                child: const CornerGradientBackgroundWidget(),
              ),
              SingleChildScrollView(
                controller: _pageScroll,
                child: Column(
                  children: [
                    // Para quien todavía no tiene cuenta, la invitación a
                    // sumarse como asociado.
                    if (FFAppState().UserRole == 'VISITOR')
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 16.0, 20.0, 8.0),
                        child: Row(
                          children: [
                            const Spacer(),
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed('CreateAccount');
                              },
                              text: 'Conviértete en Asociado',
                              options: FFButtonOptions(
                                height: 36.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: Colors.transparent,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.publicSans(
                                        color: const Color(0xFF007376),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      fontSize: 14.0,
                                    ),
                                elevation: 0.0,
                                borderSide: const BorderSide(
                                  color: Color(0xFF007376),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Cabecera clara del diseño: el logotipo a la izquierda y
                    // los accesos rápidos a la derecha, ajustes incluido.
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/images/dovia-wordmark.svg',
                            width: 120.0,
                            height: 28.0,
                            fit: BoxFit.contain,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (FFAppState().UserRole != 'VISITOR') ...[
                                _headerAction(
                                  key: _tutorialMessagesKey,
                                  asset:
                                      'assets/images/IconoDoviaHomeClienteMensajes.svg',
                                  onTap: () async {
                                    await showDoviaSupportChat(context);
                                    safeSetState(() {});
                                  },
                                ),
                                _headerAction(
                                  key: _tutorialNotificationsKey,
                                  asset:
                                      'assets/images/DH_icono-navbar-notificaciones.svg',
                                  onTap: () async {
                                    context.pushNamed(
                                        DOVIACLIENTNotificacionesWidget
                                            .routeName);
                                  },
                                ),
                              ],
                              // Ajustes dejó la barra de abajo y vive acá.
                              _headerAction(
                                key: _tutorialSettingsKey,
                                asset:
                                    'assets/images/DH_icono-navbar-ajustes.svg',
                                onTap: () async {
                                  await _handleRestrictedAction(() {
                                    context.pushNamed(
                                        DOVIACLIENTAjustesWidget.routeName);
                                  });
                                },
                              ),
                            ].divide(const SizedBox(width: 8.0)),
                          ),
                        ],
                      ),
                    ),
                    // Hero del diseño: la foto con el titular arriba y, al pie
                    // y superpuestos, la búsqueda, la moneda y el mapa.
                    Padding(
                      key: _tutorialHomeKey,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 8.0, 20.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.0),
                        child: AspectRatio(
                          aspectRatio: 1.4,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/HomeBannerFamilia.jpg',
                                fit: BoxFit.cover,
                                alignment: const Alignment(0.0, 0.2),
                              ),
                              // Aclara la parte de arriba para que el titular
                              // se lea sobre la foto.
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xF2FFFFFF),
                                      Color(0x00FFFFFF)
                                    ],
                                    stops: [0.0, 0.55],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0.0, 1.0),
                                  ),
                                ),
                              ),
                              Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, -1.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 22.0, 20.0, 0.0),
                                  child: Text.rich(
                                    const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Tu próximo hogar,\n',
                                          style: TextStyle(
                                              color: Color(0xFF0F172A)),
                                        ),
                                        TextSpan(
                                          text: 'sin complicaciones.',
                                          style: TextStyle(
                                              color: Color(0xFF065A5A)),
                                        ),
                                      ],
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.publicSans(
                                              fontWeight: FontWeight.bold),
                                          fontSize: 26.0,
                                          letterSpacing: -0.5,
                                          fontWeight: FontWeight.bold,
                                          lineHeight: 1.25,
                                        ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(0.0, 1.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      12.0, 0.0, 12.0, 14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 42.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 12.0,
                                                color: Color(0x1A000000),
                                                offset: Offset(0.0, 4.0),
                                              )
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _model.textController,
                                            onChanged: _onSearchChanged,
                                            textInputAction:
                                                TextInputAction.search,
                                            focusNode:
                                                _model.textFieldFocusNode,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 10.0, 12.0, 10.0),
                                              hintText: 'Búsqueda con IA',
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .publicSans(),
                                                        fontSize: 13.0,
                                                        letterSpacing: 0.2,
                                                      ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(25.0)),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(25.0)),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              prefixIcon: const Icon(
                                                Icons.search_rounded,
                                                size: 20.0,
                                              ),
                                              suffixIcon: _searchQuery
                                                          .isEmpty &&
                                                      !_searchLoading
                                                  ? null
                                                  : IconButton(
                                                      icon: const Icon(
                                                          Icons.close_rounded,
                                                          size: 18.0),
                                                      onPressed: () {
                                                        _model.textController
                                                            ?.clear();
                                                        _onSearchChanged('');
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                      },
                                                    ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font:
                                                      GoogleFonts.publicSans(),
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.2,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _headerAction(
                                        key: _tutorialMapKey,
                                        asset:
                                            'assets/images/IconoDoviaHomeClienteMapa.svg',
                                        onTap: () async {
                                          context.pushNamed(
                                              MapWidgetPageTestWidget
                                                  .routeName);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 12.0, 0.0, 0.0),
                      child: Container(
                        decoration: const BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              10.0, 10.0, 10.0, 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _listingToggle('comprar', 'Comprar',
                                      'assets/images/cart-alt.svg'),
                                  _listingToggle('rentar', 'Rentar',
                                      'assets/images/page-edit.svg'),
                                ].divide(const SizedBox(width: 20.0)),
                              ),
                              // Ayuda solo la primera vez: se va al tocar Comprar o Rentar.
                              AnimatedSize(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                                child: _showListingHint
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          'Elige si quieres comprar o rentar para ver propiedades',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.0,
                                            color: const Color(0xFF9E9E9E),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(width: double.infinity),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      _buildSearchResults()
                    else ...[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 4.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lo nuevo',
                                  style: _carouselTitleStyle,
                                ),
                                _verMasLink(onTap: () async {
                                  _handleRestrictedAction(() {
                                    context.pushNamed(
                                      DOVIACLIENTVerMasPropiedadesWidget
                                          .routeName,
                                      queryParameters: {
                                        'title': serializeParam(
                                          'Lo nuevo',
                                          ParamType.String,
                                        ),
                                        // Mismo filtro Comprar/Rentar que el
                                        // carrusel.
                                        'listingFilter': serializeParam(
                                          _model.comprarORentar,
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  });
                                }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 8.0, 20.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: _properties(),
                              builder: (context, snapshot) {
                                // Spinner sólo hasta la primera respuesta
                                // buena.
                                if (_carouselResponse(snapshot) == null) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final rowListPropertiesResponse =
                                    _carouselResponse(snapshot)!;

                                return Builder(
                                  builder: (context) {
                                    final allHouses =
                                        _filterByListingType(getJsonField(
                                              rowListPropertiesResponse
                                                  .jsonBody,
                                              r'''$.data''',
                                            ) as List? ??
                                            []);
                                    if (allHouses.isEmpty) {
                                      return _carouselEmpty(
                                          'No hay propiedades nuevas por ahora.');
                                    }
                                    final eachHouse =
                                        _carouselPage('loNuevo', allHouses);

                                    return _withCarouselArrows(
                                      carouselKey: 'loNuevo',
                                      total: allHouses.length,
                                      child: SingleChildScrollView(
                                        controller:
                                            _carouselController('loNuevo'),
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children:
                                              List.generate(eachHouse.length,
                                                  (eachHouseIndex) {
                                            final eachHouseItem =
                                                eachHouse[eachHouseIndex];
                                            return _houseCardItem(
                                                eachHouseItem);
                                          }).divide(
                                                  const SizedBox(width: 16.0)),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Proyectos Nuevos',
                                  style: _carouselTitleStyle,
                                ),
                                _verMasLink(onTap: () async {
                                  _handleRestrictedAction(() async {
                                    await launchURL(kNewProjectsLandingUrl);
                                  });
                                }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: _buildNewProjects(),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recomendado',
                                  style: _carouselTitleStyle,
                                ),
                                _verMasLink(onTap: () async {
                                  _handleRestrictedAction(() {
                                    context.pushNamed(
                                      DOVIACLIENTVerMasPropiedadesWidget
                                          .routeName,
                                      queryParameters: {
                                        'title': serializeParam(
                                          'Recomendado',
                                          ParamType.String,
                                        ),
                                        // Mismo filtro Comprar/Rentar que el
                                        // carrusel.
                                        'listingFilter': serializeParam(
                                          _model.comprarORentar,
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  });
                                }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: _properties(),
                              builder: (context, snapshot) {
                                // Spinner sólo hasta la primera respuesta
                                // buena.
                                if (_carouselResponse(snapshot) == null) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final rowListPropertiesResponse =
                                    _carouselResponse(snapshot)!;

                                return Builder(
                                  builder: (context) {
                                    final allHouses =
                                        _filterByListingType(getJsonField(
                                              rowListPropertiesResponse
                                                  .jsonBody,
                                              r'''$.data''',
                                            ) as List? ??
                                            []);
                                    if (allHouses.isEmpty) {
                                      return _carouselEmpty(
                                          'No hay recomendaciones por ahora.');
                                    }
                                    final eachHouse =
                                        _carouselPage('recomendado', allHouses);

                                    return _withCarouselArrows(
                                      carouselKey: 'recomendado',
                                      total: allHouses.length,
                                      child: SingleChildScrollView(
                                        controller:
                                            _carouselController('recomendado'),
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children:
                                              List.generate(eachHouse.length,
                                                  (eachHouseIndex) {
                                            final eachHouseItem =
                                                eachHouse[eachHouseIndex];
                                            return Builder(
                                              builder: (context) => InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    DOVIACLIENTPropiedadSeleccionadaNewWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'propertyId':
                                                          serializeParam(
                                                        getJsonField(
                                                          eachHouseItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                        ParamType.String,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                },
                                                onLongPress: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return Dialog(
                                                        elevation: 0,
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    dialogContext)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child:
                                                              AgregarFavoritoACarpetaWidget(
                                                            houseId:
                                                                getJsonField(
                                                              eachHouseItem,
                                                              r'''$.id''',
                                                            ).toString(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: custom_widgets
                                                    .DoviaClientHouseCard(
                                                  width: 210.0,
                                                  height: 0.0,
                                                  imageUrl: _houseImageUrl(
                                                      eachHouseItem),
                                                  isFavorite: _isHouseFavorite(
                                                      eachHouseItem),
                                                  name: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.name''',
                                                  ).toString(),
                                                  type: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.listingType''',
                                                  ).toString(),
                                                  price: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.price''',
                                                  ).toString(),
                                                  constructionArea: castToType<
                                                          int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.constructionArea''')),
                                                  landArea: castToType<double>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.landArea''')),
                                                  bedrooms: castToType<int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.bedrooms''')),
                                                  bathrooms: castToType<int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.bathrooms''')),
                                                  location:
                                                      propertyLocationLabel(
                                                          eachHouseItem),
                                                  parkingSpots: castToType<int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.parkingSpots''')),
                                                  propertyType: getJsonField(
                                                          eachHouseItem,
                                                          r'''$.propertyType''')
                                                      ?.toString(),
                                                  hasDiscount: getJsonField(
                                                              eachHouseItem,
                                                              r'''$.hasDiscount''') ==
                                                          true ||
                                                      getJsonField(
                                                                  eachHouseItem,
                                                                  r'''$.hasDiscount''')
                                                              .toString() ==
                                                          'true',
                                                  originalPrice: getJsonField(
                                                          eachHouseItem,
                                                          r'''$.originalPrice''')
                                                      ?.toString(),
                                                  propertyId: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.id''',
                                                  ).toString(),
                                                  authToken:
                                                      currentAuthenticationToken,
                                                  onAddToFavorites: () async {
                                                    if (FFAppState().UserRole !=
                                                        'VISITOR') {
                                                      _model.addFvoriteRecommended =
                                                          await DOVIAAPIFavoriteContextGroup
                                                              .addPropertyToFavoritesCall
                                                              .call(
                                                        propertyId:
                                                            getJsonField(
                                                          eachHouseItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                        authToken:
                                                            currentAuthenticationToken,
                                                      );

                                                      final addFavoriteResponse =
                                                          _model
                                                              .addFvoriteRecommended;
                                                      final isAlreadyFavorite =
                                                          (addFavoriteResponse
                                                                      ?.statusCode ==
                                                                  409) ||
                                                              (addFavoriteResponse
                                                                          ?.jsonBody ??
                                                                      '')
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'already');

                                                      if ((addFavoriteResponse
                                                                  ?.succeeded ??
                                                              false) ||
                                                          isAlreadyFavorite) {
                                                        if (!context.mounted)
                                                          return;
                                                        await showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          enableDrag: false,
                                                          context: context,
                                                          builder: (context) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child: Padding(
                                                                padding: MediaQuery
                                                                    .viewInsetsOf(
                                                                        context),
                                                                child:
                                                                    TusFavoritosCarpetasModalWidget(
                                                                  isCreatingNewFolderPARAM:
                                                                      false,
                                                                  houseId:
                                                                      getJsonField(
                                                                    eachHouseItem,
                                                                    r'''$.id''',
                                                                  ).toString(),
                                                                  propertyName:
                                                                      getJsonField(
                                                                    eachHouseItem,
                                                                    r'''$.name''',
                                                                  ).toString(),
                                                                  propertyImage:
                                                                      _modalImage(
                                                                          eachHouseItem),
                                                                  propertyIsFavorite:
                                                                      true,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      } else {
                                                        if (!context.mounted)
                                                          return;
                                                        await showDialog(
                                                          context: context,
                                                          builder:
                                                              (alertDialogContext) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Error'),
                                                              content: Text(
                                                                  (addFavoriteResponse
                                                                              ?.jsonBody ??
                                                                          '')
                                                                      .toString()),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          alertDialogContext),
                                                                  child:
                                                                      const Text(
                                                                          'Ok'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    } else {
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: const AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        dialogContext)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child:
                                                                  const VisitorRestrictionPopupWidget(),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }

                                                    safeSetState(() {});
                                                  },
                                                  onRemoveFromFavorites:
                                                      () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      enableDrag: false,
                                                      context: context,
                                                      builder: (context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                TusFavoritosCarpetasModalWidget(
                                                              isCreatingNewFolderPARAM:
                                                                  false,
                                                              houseId:
                                                                  getJsonField(
                                                                eachHouseItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                              propertyName:
                                                                  getJsonField(
                                                                eachHouseItem,
                                                                r'''$.name''',
                                                              ).toString(),
                                                              propertyImage:
                                                                  _modalImage(
                                                                      eachHouseItem),
                                                              propertyIsFavorite:
                                                                  true,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));

                                                    safeSetState(() {});
                                                  },
                                                ),
                                              ),
                                            );
                                          }).divide(
                                                  const SizedBox(width: 16.0)),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Visto recientemente',
                                  style: _carouselTitleStyle,
                                ),
                                _verMasLink(onTap: () async {
                                  _handleRestrictedAction(() {
                                    context.pushNamed(
                                      DOVIACLIENTVerMasPropiedadesWidget
                                          .routeName,
                                      queryParameters: {
                                        'title': serializeParam(
                                          'Visto recientemente',
                                          ParamType.String,
                                        ),
                                        // Mismo filtro Comprar/Rentar que el
                                        // carrusel.
                                        'listingFilter': serializeParam(
                                          _model.comprarORentar,
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  });
                                }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 0.0),
                            child: FutureBuilder<ApiCallResponse>(
                              future: _properties(),
                              builder: (context, snapshot) {
                                // Spinner sólo hasta la primera respuesta
                                // buena.
                                if (_carouselResponse(snapshot) == null) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final rowListPropertiesResponse =
                                    _carouselResponse(snapshot)!;

                                return Builder(
                                  builder: (context) {
                                    final allHouses =
                                        _filterByListingType(getJsonField(
                                              rowListPropertiesResponse
                                                  .jsonBody,
                                              r'''$.data''',
                                            ) as List? ??
                                            []);
                                    if (allHouses.isEmpty) {
                                      return _carouselEmpty(
                                          'Todavía no viste propiedades.');
                                    }
                                    final eachHouse = _carouselPage(
                                        'vistoRecientemente', allHouses);

                                    return _withCarouselArrows(
                                      carouselKey: 'vistoRecientemente',
                                      total: allHouses.length,
                                      child: SingleChildScrollView(
                                        controller: _carouselController(
                                            'vistoRecientemente'),
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children:
                                              List.generate(eachHouse.length,
                                                  (eachHouseIndex) {
                                            final eachHouseItem =
                                                eachHouse[eachHouseIndex];
                                            return Builder(
                                              builder: (context) => InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    DOVIACLIENTPropiedadSeleccionadaNewWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'propertyId':
                                                          serializeParam(
                                                        getJsonField(
                                                          eachHouseItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                        ParamType.String,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                },
                                                onLongPress: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return Dialog(
                                                        elevation: 0,
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    dialogContext)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child:
                                                              AgregarFavoritoACarpetaWidget(
                                                            houseId:
                                                                getJsonField(
                                                              eachHouseItem,
                                                              r'''$.id''',
                                                            ).toString(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: custom_widgets
                                                    .DoviaClientHouseCard(
                                                  width: 210.0,
                                                  height: 0.0,
                                                  imageUrl: _houseImageUrl(
                                                      eachHouseItem),
                                                  isFavorite: _isHouseFavorite(
                                                      eachHouseItem),
                                                  name: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.name''',
                                                  ).toString(),
                                                  type: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.listingType''',
                                                  ).toString(),
                                                  price: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.price''',
                                                  ).toString(),
                                                  constructionArea: castToType<
                                                          int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.constructionArea''')),
                                                  landArea: castToType<double>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.landArea''')),
                                                  bedrooms: castToType<int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.bedrooms''')),
                                                  bathrooms: castToType<int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.bathrooms''')),
                                                  location:
                                                      propertyLocationLabel(
                                                          eachHouseItem),
                                                  parkingSpots: castToType<int>(
                                                      getJsonField(
                                                          eachHouseItem,
                                                          r'''$.features.general.parkingSpots''')),
                                                  propertyType: getJsonField(
                                                          eachHouseItem,
                                                          r'''$.propertyType''')
                                                      ?.toString(),
                                                  hasDiscount: getJsonField(
                                                              eachHouseItem,
                                                              r'''$.hasDiscount''') ==
                                                          true ||
                                                      getJsonField(
                                                                  eachHouseItem,
                                                                  r'''$.hasDiscount''')
                                                              .toString() ==
                                                          'true',
                                                  originalPrice: getJsonField(
                                                          eachHouseItem,
                                                          r'''$.originalPrice''')
                                                      ?.toString(),
                                                  propertyId: getJsonField(
                                                    eachHouseItem,
                                                    r'''$.id''',
                                                  ).toString(),
                                                  authToken:
                                                      currentAuthenticationToken,
                                                  onAddToFavorites: () async {
                                                    if (FFAppState().UserRole !=
                                                        'VISITOR') {
                                                      _model.addFavoriteViewedRecently =
                                                          await DOVIAAPIFavoriteContextGroup
                                                              .addPropertyToFavoritesCall
                                                              .call(
                                                        propertyId:
                                                            getJsonField(
                                                          eachHouseItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                        authToken:
                                                            currentAuthenticationToken,
                                                      );

                                                      final addFavoriteResponse =
                                                          _model
                                                              .addFavoriteViewedRecently;
                                                      final isAlreadyFavorite =
                                                          (addFavoriteResponse
                                                                      ?.statusCode ==
                                                                  409) ||
                                                              (addFavoriteResponse
                                                                          ?.jsonBody ??
                                                                      '')
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'already');

                                                      if ((addFavoriteResponse
                                                                  ?.succeeded ??
                                                              false) ||
                                                          isAlreadyFavorite) {
                                                        if (!context.mounted)
                                                          return;
                                                        await showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          enableDrag: false,
                                                          context: context,
                                                          builder: (context) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child: Padding(
                                                                padding: MediaQuery
                                                                    .viewInsetsOf(
                                                                        context),
                                                                child:
                                                                    TusFavoritosCarpetasModalWidget(
                                                                  isCreatingNewFolderPARAM:
                                                                      false,
                                                                  houseId:
                                                                      getJsonField(
                                                                    eachHouseItem,
                                                                    r'''$.id''',
                                                                  ).toString(),
                                                                  propertyName:
                                                                      getJsonField(
                                                                    eachHouseItem,
                                                                    r'''$.name''',
                                                                  ).toString(),
                                                                  propertyImage:
                                                                      _modalImage(
                                                                          eachHouseItem),
                                                                  propertyIsFavorite:
                                                                      true,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      } else {
                                                        if (!context.mounted)
                                                          return;
                                                        await showDialog(
                                                          context: context,
                                                          builder:
                                                              (alertDialogContext) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Error'),
                                                              content: Text(
                                                                  (addFavoriteResponse
                                                                              ?.jsonBody ??
                                                                          '')
                                                                      .toString()),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          alertDialogContext),
                                                                  child:
                                                                      const Text(
                                                                          'Ok'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    } else {
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: const AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        dialogContext)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child:
                                                                  const VisitorRestrictionPopupWidget(),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }

                                                    safeSetState(() {});
                                                  },
                                                  onRemoveFromFavorites:
                                                      () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      enableDrag: false,
                                                      context: context,
                                                      builder: (context) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                TusFavoritosCarpetasModalWidget(
                                                              isCreatingNewFolderPARAM:
                                                                  false,
                                                              houseId: getJsonField(
                                                                      eachHouseItem,
                                                                      r'''$.id''')
                                                                  .toString(),
                                                              propertyName: getJsonField(
                                                                      eachHouseItem,
                                                                      r'''$.name''')
                                                                  .toString(),
                                                              propertyImage:
                                                                  _modalImage(
                                                                      eachHouseItem),
                                                              propertyIsFavorite:
                                                                  true,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));

                                                    safeSetState(() {});
                                                  },
                                                ),
                                              ),
                                            );
                                          }).divide(
                                                  const SizedBox(width: 16.0)),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Aire al pie para que la ultima fila no quede debajo
                    // de la barra de navegacion, que va flotando encima.
                    const SizedBox(height: 110.0),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Ícono flotante de soporte, como en el resto de las
                    // pantallas del cliente.
                    if (FFAppState().UserRole != 'VISITOR')
                      const Align(
                        alignment: AlignmentDirectional(1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 15.0, 12.0),
                          child: FixedDoviaIconWidget(),
                        ),
                      ),
                    wrapWithModel(
                      model: _model.dOVIACLIENTNavbarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DOVIACLIENTNavbarWidget(
                        activeTab: DOVIACLIENTHomePageWidget.routeName,
                        tutorialKeys: _navbarKeys,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
