import '/auth/registration_progress.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/custom_auth/auth_util.dart';
import 'auth/custom_auth/custom_auth_user_provider.dart';
import 'auth/custom_auth/session_restore.dart';

import 'flutter_flow/flutter_flow_util.dart';
import 'repositories/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await authManager.initialize();
  await restoreSession();

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

class _MyAppState extends State<MyApp> {
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

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = doviaAuthUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        // Cerrar sesión no pasa por un solo lugar: cada vertical tiene su
        // propia pantalla de ajustes con su propio botón. Este stream sí es
        // común a todos, así que el estado de pagos se limpia acá. Dejarlo con
        // la suscripción del usuario anterior le daría beneficios Premium a
        // quien inicie sesión después en el mismo dispositivo.
        if (!user.loggedIn && mounted) {
          context.read<PaymentsRepository>().clear();
        }
        // Tambien cubre un cambio directo de cuenta sin un evento de logout.
        if (mounted && (!user.loggedIn || _notificationsUserId != user.uid)) {
          context.read<NotificationsRepository>().clear();
        }
        _notificationsUserId = user.loggedIn ? user.uid : null;
      });

    Future.delayed(
      const Duration(milliseconds: 500),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
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
