// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;

import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/api_requests/api_calls.dart';
import '/components/house_card_component_widget.dart';
import '/dovia_client/d_o_v_i_a_c_l_i_e_n_t_navbar/d_o_v_i_a_c_l_i_e_n_t_navbar_widget.dart';
import '/shared_components/corner_gradient_background/corner_gradient_background_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MapExplorerPageWidget
//  Self-contained map page: fetches properties, manages filter state,
//  shows filter pills + advanced filter sheet, and renders the map.
//  Uses only true custom widgets — safe from FlutterFlow regeneration.
// ─────────────────────────────────────────────────────────────────────────────

class MapExplorerPageWidget extends StatefulWidget {
  const MapExplorerPageWidget({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  State<MapExplorerPageWidget> createState() => _MapExplorerPageWidgetState();
}

class _MapExplorerPageWidgetState extends State<MapExplorerPageWidget> {
  static const Color _aqua = Color(0xFF007376);

  // ── Properties data ───────────────────────────────────────
  List<MapPropertyMarkerStruct> _allProperties = [];
  List<MapPropertyMarkerStruct> _filteredProperties = [];

  // ── Quick-filter state ────────────────────────────────────
  String? _listingFilter;
  String? _typeFilter;
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  int? _minBathrooms;
  double? _minArea;
  double? _maxArea;
  String _currency = 'USD';
  bool _showPriceOverlay = false;

  // ── Controllers ───────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _minPriceController = TextEditingController();
  final FocusNode _minPriceFocus = FocusNode();
  final TextEditingController _maxPriceController = TextEditingController();
  final FocusNode _maxPriceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final result =
          await DOVIAAPIPropertyContextGroup.getPropertiesForMapCall.call();
      if (result.succeeded && mounted) {
        setState(() {
          _allProperties = functions
              .parseMapMarkers(result.jsonBody)
              .cast<MapPropertyMarkerStruct>();
          _filteredProperties = _applyFilters(_allProperties);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _minPriceController.dispose();
    _minPriceFocus.dispose();
    _maxPriceController.dispose();
    _maxPriceFocus.dispose();
    super.dispose();
  }

  // ── Filter helpers ────────────────────────────────────────
  List<MapPropertyMarkerStruct> _applyFilters(
      List<MapPropertyMarkerStruct> all) {
    return functions
        .applyFiltersForMap(
          all,
          _typeFilter,
          _listingFilter,
          _minPrice,
          _maxPrice,
          _minBedrooms,
          _minBathrooms,
          _minArea,
          _maxArea,
        )
        .cast<MapPropertyMarkerStruct>();
  }

  void _updateFilters() {
    setState(() {
      _filteredProperties = _applyFilters(_allProperties);
    });
  }

  // ── Advanced filters sheet ────────────────────────────────
  Future<void> _openAdvancedFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      useSafeArea: true,
      context: context,
      builder: (ctx) => _AdvancedFilterSheet(
        initialBedrooms: _minBedrooms,
        initialBathrooms: _minBathrooms,
        initialMinArea: _minArea,
        initialMaxArea: _maxArea,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        minPriceController:
            TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? ''),
        maxPriceController:
            TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? ''),
      ),
    );

    if (result == null) return; // cancelled

    if (result.containsKey('clear')) {
      setState(() {
        _listingFilter = null;
        _typeFilter = null;
        _minPrice = null;
        _maxPrice = null;
        _minBedrooms = null;
        _minBathrooms = null;
        _minArea = null;
        _maxArea = null;
        _minPriceController.clear();
        _maxPriceController.clear();
        _filteredProperties = _applyFilters(_allProperties);
      });
    } else {
      setState(() {
        _minBedrooms = result['bedrooms'] as int?;
        _minBathrooms = result['bathrooms'] as int?;
        _minArea = result['minArea'] as double?;
        _maxArea = result['maxArea'] as double?;
        _minPrice = result['minPrice'] as double?;
        _maxPrice = result['maxPrice'] as double?;
        // Sync pill-bar price controllers
        _minPriceController.text = _minPrice?.toStringAsFixed(0) ?? '';
        _maxPriceController.text = _maxPrice?.toStringAsFixed(0) ?? '';
        _filteredProperties = _applyFilters(_allProperties);
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        top: true,
        child: Stack(
          children: [
            // const CornerGradientBackgroundWidget(),
            Positioned.fill(
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildFilterPills(),
                  if (_showPriceOverlay) _buildPriceOverlay(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 8.0, 0.0, 0.0),
                      child: DoviaMapExplorerWidget(
                        width: widget.width,
                        height: widget.height,
                        mapboxAccessToken: FFAppConstants.MapboxAccessToken,
                        initialLatitude: 14.6,
                        initialLongitude: -90.4,
                        initialZoom: 12.0,
                        filteredProperties: _filteredProperties,
                        onIconSelected: (propertyId, name, price, listingType,
                            landArea, isFavorite) async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: true,
                            context: context,
                            builder: (ctx) => Padding(
                              padding: MediaQuery.viewInsetsOf(ctx),
                              child: SizedBox(
                                height: 360.0,
                                child: HouseCardComponentWidget(
                                  propertyId: propertyId,
                                  name: name,
                                  price: price,
                                  listingType: listingType,
                                  landArea: landArea,
                                  isFavorite: isFavorite,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: DOVIACLIENTNavbarWidget(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 0.0),
      child: Container(
        height: 46.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14.0),
            SvgPicture.asset(
              'assets/images/lupa.svg',
              width: 20.0,
              height: 20.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Búsqueda con IA',
                  hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.publicSans(),
                        letterSpacing: 0.0,
                      ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(),
                      letterSpacing: 0.0,
                    ),
                cursorColor: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            // Funnel / filter icon button
            GestureDetector(
              onTap: _openAdvancedFilters,
              child: Container(
                width: 36.0,
                height: 36.0,
                margin: const EdgeInsets.only(right: 5.0),
                decoration: const BoxDecoration(
                  color: _aqua,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: SvgPicture.asset(
                    'assets/images/filter-alt-white.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter pills ──────────────────────────────────────────
  Widget _buildFilterPills() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            // Transacción
            _buildDropdownPill(
              label: _listingFilter == 'SALE'
                  ? 'Venta'
                  : _listingFilter == 'RENT'
                      ? 'Renta'
                      : 'Transacción',
              isActive: _listingFilter != null,
              items: const [
                PopupMenuItem(value: 'ALL', child: Text('Todos')),
                PopupMenuItem(value: 'SALE', child: Text('Venta')),
                PopupMenuItem(value: 'RENT', child: Text('Renta')),
              ],
              onSelected: (val) {
                _listingFilter = val == 'ALL' ? null : val;
                _updateFilters();
              },
            ),
            const SizedBox(width: 8),
            // Tipo
            _buildDropdownPill(
              label: _typeFilter == 'HOUSE'
                  ? 'Casa'
                  : _typeFilter == 'APARTMENT'
                      ? 'Depto'
                      : 'Tipo',
              isActive: _typeFilter != null,
              items: const [
                PopupMenuItem(value: 'ALL', child: Text('Todos')),
                PopupMenuItem(value: 'HOUSE', child: Text('Casa')),
                PopupMenuItem(value: 'APARTMENT', child: Text('Departamento')),
              ],
              onSelected: (val) {
                _typeFilter = val == 'ALL' ? null : val;
                _updateFilters();
              },
            ),
            const SizedBox(width: 8),
            // Rango de precio
            _buildPill(
              label: (_minPrice != null || _maxPrice != null)
                  ? 'Precio ✓'
                  : 'Rango de precio',
              isActive: _minPrice != null || _maxPrice != null,
              hasChevron: true,
              onTap: () =>
                  setState(() => _showPriceOverlay = !_showPriceOverlay),
            ),
            const SizedBox(width: 8),
            // Moneda
            _buildPill(
              label: _currency,
              isActive: false,
              onTap: () => setState(
                  () => _currency = _currency == 'USD' ? 'GTQ' : 'USD'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Price overlay (inline under pills) ───────────────────
  Widget _buildPriceOverlay() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _priceTextField(
                controller: _minPriceController,
                focusNode: _minPriceFocus,
                hint: 'Desde',
                onChanged: (v) {
                  _minPrice = double.tryParse(v);
                  _updateFilters();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('–',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(),
                        letterSpacing: 0.0,
                      )),
            ),
            Expanded(
              child: _priceTextField(
                controller: _maxPriceController,
                focusNode: _maxPriceFocus,
                hint: 'Hasta',
                onChanged: (v) {
                  _maxPrice = double.tryParse(v);
                  _updateFilters();
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  size: 18.0,
                  color: FlutterFlowTheme.of(context).secondaryText),
              onPressed: () => setState(() => _showPriceOverlay = false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.publicSans(),
              letterSpacing: 0.0,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _aqua, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).error),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).error),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).primaryBackground,
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.publicSans(),
            letterSpacing: 0.0,
          ),
      onChanged: onChanged,
    );
  }

  // ── Pill builders ─────────────────────────────────────────
  Widget _buildDropdownPill({
    required String label,
    required bool isActive,
    required List<PopupMenuEntry<String>> items,
    required void Function(String) onSelected,
  }) {
    final bg =
        isActive ? _aqua : FlutterFlowTheme.of(context).secondaryBackground;
    final textColor =
        isActive ? Colors.white : FlutterFlowTheme.of(context).primaryText;
    final iconColor =
        isActive ? Colors.white : FlutterFlowTheme.of(context).secondaryText;

    return PopupMenuButton<String>(
      offset: const Offset(0, 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      onSelected: onSelected,
      itemBuilder: (_) => items,
      child: Container(
        height: 34.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.publicSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.0,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16.0, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool hasChevron = false,
    bool hasFilterIcon = false,
  }) {
    final bg =
        isActive ? _aqua : FlutterFlowTheme.of(context).secondaryBackground;
    final textColor =
        isActive ? Colors.white : FlutterFlowTheme.of(context).primaryText;
    final iconColor =
        isActive ? Colors.white : FlutterFlowTheme.of(context).secondaryText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasFilterIcon)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(Icons.tune_rounded, size: 16.0, color: iconColor),
              ),
            Text(label,
                style: GoogleFonts.publicSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.0,
                )),
            if (hasChevron)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16.0, color: iconColor),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _AdvancedFilterSheet
//  Full-height modal matching Figma node 1023-54897.
//  Sections: Habitaciones, Baños, Parqueos (UI only), Área, Precio, Descripción.
//  Returns Map with filter values via Navigator.pop, or null if cancelled.
//  Returns {'clear': true} when the user taps "Cancelar".
// ─────────────────────────────────────────────────────────────────────────────

class _AdvancedFilterSheet extends StatefulWidget {
  const _AdvancedFilterSheet({
    this.initialBedrooms,
    this.initialBathrooms,
    this.initialMinArea,
    this.initialMaxArea,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.minPriceController,
    required this.maxPriceController,
  });

  final int? initialBedrooms;
  final int? initialBathrooms;
  final double? initialMinArea;
  final double? initialMaxArea;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  static const Color _aqua = Color(0xFF007376);
  static const List<String> _numberOptions = ['1', '2', '3', '4+'];

  String? _bedrooms;
  String? _bathrooms;
  String? _parkings; // UI only — not wired to filter logic yet
  String? _expandedSection; // tracks which selector is open
  late final TextEditingController _minAreaCtrl;
  late final TextEditingController _maxAreaCtrl;
  late final TextEditingController _minPriceCtrl;
  late final TextEditingController _maxPriceCtrl;
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bedrooms = widget.initialBedrooms != null
        ? (widget.initialBedrooms! >= 4
            ? '4+'
            : widget.initialBedrooms.toString())
        : null;
    _bathrooms = widget.initialBathrooms != null
        ? (widget.initialBathrooms! >= 4
            ? '4+'
            : widget.initialBathrooms.toString())
        : null;
    _minAreaCtrl = TextEditingController(
        text: widget.initialMinArea?.toStringAsFixed(0) ?? '');
    _maxAreaCtrl = TextEditingController(
        text: widget.initialMaxArea?.toStringAsFixed(0) ?? '');
    _minPriceCtrl = widget.minPriceController;
    _maxPriceCtrl = widget.maxPriceController;
  }

  @override
  void dispose() {
    _minAreaCtrl.dispose();
    _maxAreaCtrl.dispose();
    _descriptionCtrl.dispose();
    // Note: _minPriceCtrl / _maxPriceCtrl are passed in and disposed by caller
    super.dispose();
  }

  int? _parseOption(String? val) {
    if (val == null) return null;
    if (val == '4+') return 4;
    return int.tryParse(val);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      // ~90% of screen height
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: GoogleFonts.publicSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00444B),
                        letterSpacing: 0.32,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Es opcional',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _aqua,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.alternate,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: theme.primaryText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // ── Scrollable body ───────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habitaciones
                  _sectionLabel('Habitaciones', theme),
                  const SizedBox(height: 10),
                  _inlineDropdown(
                    key: const ValueKey('bedrooms'),
                    selected: _bedrooms,
                    placeholder: 'Selecciona el número de habitaciones',
                    isOpen: _expandedSection == 'bedrooms',
                    onToggle: () => setState(() {
                      _expandedSection =
                          _expandedSection == 'bedrooms' ? null : 'bedrooms';
                    }),
                    onSelect: (v) => setState(() {
                      _bedrooms = v;
                      _expandedSection = null;
                    }),
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // Baños
                  _sectionLabel('Baños', theme),
                  const SizedBox(height: 10),
                  _inlineDropdown(
                    key: const ValueKey('bathrooms'),
                    selected: _bathrooms,
                    placeholder: 'Selecciona el número de baños',
                    isOpen: _expandedSection == 'bathrooms',
                    onToggle: () => setState(() {
                      _expandedSection =
                          _expandedSection == 'bathrooms' ? null : 'bathrooms';
                    }),
                    onSelect: (v) => setState(() {
                      _bathrooms = v;
                      _expandedSection = null;
                    }),
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // Parqueos (UI only)
                  _sectionLabel('Parqueos', theme),
                  const SizedBox(height: 10),
                  _inlineDropdown(
                    key: const ValueKey('parkings'),
                    selected: _parkings,
                    placeholder: 'Selecciona el número de parqueos',
                    isOpen: _expandedSection == 'parkings',
                    onToggle: () => setState(() {
                      _expandedSection =
                          _expandedSection == 'parkings' ? null : 'parkings';
                    }),
                    onSelect: (v) => setState(() {
                      _parkings = v;
                      _expandedSection = null;
                    }),
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  // Área de construcción
                  _sectionLabel('Área de construcción', theme),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subLabel('Desde'),
                            const SizedBox(height: 6),
                            _numericInput(
                                ctrl: _minAreaCtrl, hint: 'm2', theme: theme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subLabel('Hasta'),
                            const SizedBox(height: 6),
                            _numericInput(
                                ctrl: _maxAreaCtrl, hint: 'm2', theme: theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Precio
                  _sectionLabel('Precio', theme),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subLabel('Desde'),
                            const SizedBox(height: 6),
                            _numericInput(
                                ctrl: _minPriceCtrl, hint: '\$', theme: theme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subLabel('Hasta'),
                            const SizedBox(height: 6),
                            _numericInput(
                                ctrl: _maxPriceCtrl, hint: '\$', theme: theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Descripción libre (AI)
                  _sectionLabel(
                      'Describe que otras características son importantes para ti',
                      theme),
                  const SizedBox(height: 10),
                  _aiTextField(theme),
                ],
              ),
            ),
          ),

          // ── Footer ────────────────────────────────────────
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.paddingOf(context).bottom + 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _aqua,
                      side: const BorderSide(color: _aqua),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, {'clear': true}),
                    child: Text('Cancelar',
                        style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _aqua)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _aqua,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'bedrooms': _parseOption(_bedrooms),
                        'bathrooms': _parseOption(_bathrooms),
                        // parkings is UI-only for now — not returned
                        'minArea': _minAreaCtrl.text.isNotEmpty
                            ? double.tryParse(_minAreaCtrl.text)
                            : null,
                        'maxArea': _maxAreaCtrl.text.isNotEmpty
                            ? double.tryParse(_maxAreaCtrl.text)
                            : null,
                        'minPrice': _minPriceCtrl.text.isNotEmpty
                            ? double.tryParse(_minPriceCtrl.text)
                            : null,
                        'maxPrice': _maxPriceCtrl.text.isNotEmpty
                            ? double.tryParse(_maxPriceCtrl.text)
                            : null,
                      });
                    },
                    child: Text('Aplicar filtro',
                        style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section helpers ───────────────────────────────────────

  Widget _sectionLabel(String text, FlutterFlowTheme theme) {
    return Text(
      text,
      style: GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF00444B),
        letterSpacing: 0.28,
      ),
    );
  }

  // ── Inline dropdown (full-width, expands below) ─────────────
  Widget _inlineDropdown({
    Key? key,
    required String? selected,
    required String placeholder,
    required bool isOpen,
    required VoidCallback onToggle,
    required ValueChanged<String?> onSelect,
    required FlutterFlowTheme theme,
  }) {
    const options = ['1', '2', '3', '4+'];
    final hasValue = selected != null;

    return AnimatedSize(
      key: key,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: isOpen
              ? Border.all(color: _aqua, width: 1.2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─ Trigger row ─────────────────────────────────
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasValue ? selected! : placeholder,
                        style: GoogleFonts.publicSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: hasValue
                              ? const Color(0xFF00444B)
                              : const Color(0xFF888888).withValues(alpha: 0.5),
                          letterSpacing: 0.28,
                          height: 49.849 / 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: isOpen ? _aqua : const Color(0xFF00444B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ─ Options list (shows only when open) ───────────
            if (isOpen) ...[
              Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.alternate.withValues(alpha: 0.6)),
              ...options.map((opt) {
                final isSelected = selected == opt;
                return GestureDetector(
                  onTap: () => onSelect(isSelected ? null : opt),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 13),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _aqua.withValues(alpha: 0.06)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          opt,
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? _aqua : const Color(0xFF00444B),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              size: 16, color: _aqua),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _subLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF00444B),
        letterSpacing: 0.28,
      ),
    );
  }

  Widget _numericInput({
    required TextEditingController ctrl,
    required String hint,
    required FlutterFlowTheme theme,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: GoogleFonts.publicSans(
          fontSize: 14,
          color: const Color(0xFF888888).withValues(alpha: 0.5),
          letterSpacing: 0.28,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _aqua, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      style: GoogleFonts.publicSans(
        fontSize: 14,
        color: const Color(0xFF00444B),
      ),
    );
  }

  Widget _aiTextField(FlutterFlowTheme theme) {
    return TextField(
      controller: _descriptionCtrl,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        isDense: true,
        hintText:
            'Aquí puedes escribir en lenguaje natural lo que buscas y nuestra IA lo procesara',
        hintStyle: GoogleFonts.publicSans(
          fontSize: 14,
          color: const Color(0xFF888888),
          letterSpacing: 0.28,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _aqua, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      style: GoogleFonts.publicSans(
        fontSize: 14,
        color: const Color(0xFF00444B),
      ),
    );
  }
}
