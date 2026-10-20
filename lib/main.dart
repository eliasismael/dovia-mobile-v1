import '/auth/registration_progress.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show LicenseEntry, LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/custom_auth/auth_util.dart';
import 'auth/custom_auth/custom_auth_user_provider.dart';
import 'auth/custom_auth/session_restore.dart';
import 'auth/custom_auth/token_refresher.dart';
import 'backend/api_requests/api_manager.dart';
import 'dovia_home_associate/associate_current_job.dart';
import 'index.dart' show DHCLIENTUbicacionWidget, SignInWidget;
import 'notifications/notification_navigation.dart';
import 'notifications/notification_router.dart';
import 'notifications/firebase_push_messaging.dart';
import 'notifications/push_messaging.dart';
import 'notifications/push_notifications_service.dart';

import 'flutter_flow/flutter_flow_util.dart';
import 'repositories/index.dart';

/// Licencias OFL de las fuentes incluidas en `assets/google_fonts`.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final font in ['inter', 'publicsans', 'raleway']) {
    final text =
        await rootBundle.loadString('assets/google_fonts/OFL-$font.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], text);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Las fuentes vienen dentro de la app (assets/google_fonts): sin esto se
  // bajaban de internet la primera vez, lo que en celulares viejos o con mala
  // señal demoraba el arranque y hacía saltar el texto de fuente.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await authManager.initialize();
  ApiManager.onUnauthorized = refreshSession;
  ApiManager.freshTokenIfExpired = freshTokenIfExpired;
  ApiManager.sessionGeneration = () => authManager.sessionGeneration;
  await restoreSession();
  // Firebase para push (Android/iOS); sin configuración queda sin push.
  pushMessaging = await initPushMessaging();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();
  await RegistrationProgress.load();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => appState),
      ChangeNotifierProvider(create: (_) => FavoritesRepository()),
      ChangeNotifierProvider(create: (_) => PropertiesRepository()),
      ChangeNotifierProvider(create: (_) => UserRepository()),
      ChangeNotifierProvider(create: (_) => VisitsRepository()),
      ChangeNotifierProvider(create: (_) => OffersRepository()),
      ChangeNotifierProvider(create: (_) => PaymentsRepository()),
      ChangeNotifierProvider(create: (_) => NotificationsRepository()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<DoviaAuthUser> userStream;
  String? _notificationsUserId;
  bool _wasLoggedIn = false;
  late final PushNotificationsService _push;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    WidgetsBinding.instance.addObserver(this);
    onSessionExpired = _onSessionExpired;
    _push = PushNotificationsService(
      messaging: pushMessaging,
      repository: context.read<NotificationsRepository>(),
      onOpen: _openPush,
      onForeground: _showForegroundPush,
    );
    pushNotificationsService = _push;
    _push.start();
    userStream = doviaAuthUserStream()
      ..listen((user) {
        // Empezó una sesión (login, arranque con sesión o cambio de cuenta):
        // se registra el dispositivo para push y se trae el contador.
        final sessionStarted = user.loggedIn &&
            (!_wasLoggedIn || user.uid != _notificationsUserId);
        _appStateNotifier.update(user);
        // Cerrar sesión no pasa por un solo lugar (cada rol tiene su pantalla
        // de ajustes, y la sesión también puede vencer), pero este stream sí
        // es común a todos: el estado del usuario se limpia acá. Los
        // repositorios viven en toda la app y guardan en caché perfil,
        // favoritos, propiedades y visitas; sin esto quien iniciara sesión
        // después en el mismo teléfono veía los datos de la cuenta anterior
        // (y heredaba la suscripción Premium).
        final previousUid = _notificationsUserId;
        final switchedAccount = user.loggedIn &&
            (previousUid ?? '').isNotEmpty &&
            previousUid != user.uid;
        if (mounted && (!user.loggedIn || switchedAccount)) {
          context.read<UserRepository>().clear();
          context.read<FavoritesRepository>().clear();
          context.read<PropertiesRepository>().clear();
          context.read<VisitsRepository>().clear();
          context.read<PaymentsRepository>().clear();
          // Estado guardado fuera de los repositorios que también es de la
          // cuenta: el trabajo "En curso" del asociado y la última dirección
          // verificada del cliente de Dovia Home.
          AssociateCurrentJob.clear();
          DHCLIENTUbicacionWidget.lastVerifiedAddressId = null;
          DHCLIENTUbicacionWidget.lastVerifiedAddressLabel = null;
        }
        // Solo en un logout real: al abrir la app sin sesión puede haber un
        // registro a medias que necesita esos datos.
        if (!user.loggedIn && _wasLoggedIn) {
          FFAppState().clearUserScopedState();
          // También si la sesión venció y no se pudo dar de baja el
          // dispositivo: que no le sigan llegando push de esa cuenta.
          _push.afterSignOut();
        }
        _wasLoggedIn = user.loggedIn;
        // Tambien cubre un cambio directo de cuenta sin un evento de logout.
        if (mounted && (!user.loggedIn || _notificationsUserId != user.uid)) {
          context.read<NotificationsRepository>().clear();
        }
        _notificationsUserId = user.loggedIn ? user.uid : null;
        if (mounted && sessionStarted) {
          _push.syncForCurrentSession();
          context.read<NotificationsRepository>().refreshUnreadCount();
        }
      });

    Future.delayed(
      const Duration(milliseconds: 500),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onSessionExpired = null;
    _push.dispose();
    pushNotificationsService = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al volver del fondo el token puede haber vencido: se renueva antes de
    // que la pantalla empiece a pedir datos.
    if (state == AppLifecycleState.resumed) {
      refreshSessionIfStale();
      // Pudo haber llegado algo mientras la app estaba en segundo plano.
      if (loggedIn) context.read<NotificationsRepository>().refreshUnreadCount();
      // Si el registro del dispositivo falló (sin conexión) o el permiso se
      // dio desde Ajustes, se reintenta acá: si no, los push no llegaban
      // hasta el próximo inicio de sesión.
      _push.retryIfNotRegistered();
    }
  }

  /// El usuario tocó un push: al detalle si se puede, si no a su bandeja.
  void _openPush(PushMessage message) {
    if (!mounted) return;
    final destination = destinationForPush(
      role: FFAppState().UserRole,
      message: message,
      isAppRoute: (path) => isAppRoute(_router, path),
    );
    openNotificationDestination(_router, destination);
  }

  /// Un push con la app abierta no lo muestra el sistema: se avisa acá.
  void _showForegroundPush(PushMessage message) {
    final text = [message.title, message.body]
        .whereType<String>()
        .where((t) => t.trim().isNotEmpty)
        .join('\n');
    if (text.isEmpty) return;
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _openPush(message),
        ),
      ));
  }

  /// El backend rechazó el refreshToken: la sesión ya se cerró. Se lleva al
  /// login y se explica por qué, en lugar de dejar la pantalla fallando.
  void _onSessionExpired(String message) {
    if (!mounted) return;
    _router.goNamed(SignInWidget.routeName);
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'DOVIA',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', ''), Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
