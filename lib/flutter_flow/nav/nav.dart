import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

import '/auth/custom_auth/custom_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  DoviaAuthUser? initialUser;
  DoviaAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(DoviaAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.loggedIn
          ? const DOVIACLIENTHomePageWidget()
          : const QueEsDoviaWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.loggedIn
              ? const DOVIACLIENTHomePageWidget()
              : const QueEsDoviaWidget(),
        ),
        FFRoute(
          name: QueEsDoviaWidget.routeName,
          path: QueEsDoviaWidget.routePath,
          builder: (context, params) => const QueEsDoviaWidget(),
        ),
        FFRoute(
          name: InicioWidget.routeName,
          path: InicioWidget.routePath,
          builder: (context, params) => const InicioWidget(),
        ),
        FFRoute(
          name: SignInWidget.routeName,
          path: SignInWidget.routePath,
          builder: (context, params) => const SignInWidget(),
        ),
        FFRoute(
          name: CreateAccountWidget.routeName,
          path: CreateAccountWidget.routePath,
          builder: (context, params) => const CreateAccountWidget(),
        ),
        FFRoute(
          name: CreateAccount2Widget.routeName,
          path: CreateAccount2Widget.routePath,
          builder: (context, params) => const CreateAccount2Widget(),
        ),
        FFRoute(
          name: DatosWidget.routeName,
          path: DatosWidget.routePath,
          builder: (context, params) => const DatosWidget(),
        ),
        FFRoute(
          name: Datos2Widget.routeName,
          path: Datos2Widget.routePath,
          builder: (context, params) => const Datos2Widget(),
        ),
        FFRoute(
          name: Datos3Widget.routeName,
          path: Datos3Widget.routePath,
          builder: (context, params) => const Datos3Widget(),
        ),
        FFRoute(
          name: RecoverPassword1Widget.routeName,
          path: RecoverPassword1Widget.routePath,
          builder: (context, params) => const RecoverPassword1Widget(),
        ),
        FFRoute(
          name: RecoverPassword2Widget.routeName,
          path: RecoverPassword2Widget.routePath,
          builder: (context, params) => const RecoverPassword2Widget(),
        ),
        FFRoute(
          name: DOVIACLIENTHomePageWidget.routeName,
          path: DOVIACLIENTHomePageWidget.routePath,
          builder: (context, params) => const DOVIACLIENTHomePageWidget(),
        ),
        FFRoute(
          name: DHASSOCIATECreateAccountWidget.routeName,
          path: DHASSOCIATECreateAccountWidget.routePath,
          builder: (context, params) => const DHASSOCIATECreateAccountWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEBienvenidaWidget.routeName,
          path: DHASSOCIATEBienvenidaWidget.routePath,
          builder: (context, params) => const DHASSOCIATEBienvenidaWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEServiciosWidget.routeName,
          path: DHASSOCIATEServiciosWidget.routePath,
          builder: (context, params) => const DHASSOCIATEServiciosWidget(),
        ),
        FFRoute(
          name: DHASSOCIATENotificacionesWidget.routeName,
          path: DHASSOCIATENotificacionesWidget.routePath,
          builder: (context, params) => const DHASSOCIATENotificacionesWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEAjustesWidget.routeName,
          path: DHASSOCIATEAjustesWidget.routePath,
          builder: (context, params) => const DHASSOCIATEAjustesWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEHomePageWidget.routeName,
          path: DHASSOCIATEHomePageWidget.routePath,
          builder: (context, params) => const DHASSOCIATEHomePageWidget(),
        ),
        FFRoute(
          name: DHASSOCIATETrabajosDisponiblesWidget.routeName,
          path: DHASSOCIATETrabajosDisponiblesWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATETrabajosDisponiblesWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEProximosTrabajosWidget.routeName,
          path: DHASSOCIATEProximosTrabajosWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATEProximosTrabajosWidget(),
        ),
        FFRoute(
          name: DHASSOCIATETrabajoRealizadoWidget.routeName,
          path: DHASSOCIATETrabajoRealizadoWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATETrabajoRealizadoWidget(),
        ),
        FFRoute(
          name: DHASSOCIATETuTrabajoWidget.routeName,
          path: DHASSOCIATETuTrabajoWidget.routePath,
          builder: (context, params) => const DHASSOCIATETuTrabajoWidget(),
        ),
        FFRoute(
          name: DHASSOCIATETrabajoARealizarWidget.routeName,
          path: DHASSOCIATETrabajoARealizarWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATETrabajoARealizarWidget(),
        ),
        FFRoute(
          name: DHASSOCIATETrabajoFinalizadoWidget.routeName,
          path: DHASSOCIATETrabajoFinalizadoWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATETrabajoFinalizadoWidget(),
        ),
        FFRoute(
          name: DHASSOCIATETrabajoAdicionalWidget.routeName,
          path: DHASSOCIATETrabajoAdicionalWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATETrabajoAdicionalWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEFueraDeAlcanceWidget.routeName,
          path: DHASSOCIATEFueraDeAlcanceWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATEFueraDeAlcanceWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEEmpresaHomePageWidget.routeName,
          path: DHASSOCIATEEmpresaHomePageWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATEEmpresaHomePageWidget(),
        ),
        FFRoute(
          name: DHASSOCIATECotizacionesWidget.routeName,
          path: DHASSOCIATECotizacionesWidget.routePath,
          builder: (context, params) => const DHASSOCIATECotizacionesWidget(),
        ),
        FFRoute(
          name: DHASSOCIATECotizacionWidget.routeName,
          path: DHASSOCIATECotizacionWidget.routePath,
          builder: (context, params) => const DHASSOCIATECotizacionWidget(),
        ),
        FFRoute(
          name: DHASSOCIATEPropuestaEnviadaWidget.routeName,
          path: DHASSOCIATEPropuestaEnviadaWidget.routePath,
          builder: (context, params) =>
              const DHASSOCIATEPropuestaEnviadaWidget(),
        ),
        FFRoute(
          name: DHCLIENTBienvenidaWidget.routeName,
          path: DHCLIENTBienvenidaWidget.routePath,
          builder: (context, params) => const DHCLIENTBienvenidaWidget(),
        ),
        FFRoute(
          name: DHCLIENTPlanesPageWidget.routeName,
          path: DHCLIENTPlanesPageWidget.routePath,
          builder: (context, params) => const DHCLIENTPlanesPageWidget(),
        ),
        FFRoute(
          name: DHCLIENTUbicacionWidget.routeName,
          path: DHCLIENTUbicacionWidget.routePath,
          builder: (context, params) => const DHCLIENTUbicacionWidget(),
        ),
        FFRoute(
          name: DHCLIENTValorVisitaPageWidget.routeName,
          path: DHCLIENTValorVisitaPageWidget.routePath,
          builder: (context, params) => const DHCLIENTValorVisitaPageWidget(),
        ),
        FFRoute(
          name: DHCLIENTHomepageWidget.routeName,
          path: DHCLIENTHomepageWidget.routePath,
          builder: (context, params) => const DHCLIENTHomepageWidget(),
        ),
        FFRoute(
          name: DHCLIENTEmergenciasWidget.routeName,
          path: DHCLIENTEmergenciasWidget.routePath,
          builder: (context, params) => const DHCLIENTEmergenciasWidget(),
        ),
        FFRoute(
          name: DHCLIENTCostoEmergenciaWidget.routeName,
          path: DHCLIENTCostoEmergenciaWidget.routePath,
          builder: (context, params) => const DHCLIENTCostoEmergenciaWidget(),
        ),
        FFRoute(
          name: DHCLIENTInstalacionWidget.routeName,
          path: DHCLIENTInstalacionWidget.routePath,
          builder: (context, params) => const DHCLIENTInstalacionWidget(),
        ),
        FFRoute(
          name: DHCLIENTCotizacionWidget.routeName,
          path: DHCLIENTCotizacionWidget.routePath,
          builder: (context, params) => const DHCLIENTCotizacionWidget(),
        ),
        FFRoute(
          name: DHCLIENTAgendaWidget.routeName,
          path: DHCLIENTAgendaWidget.routePath,
          builder: (context, params) => const DHCLIENTAgendaWidget(),
        ),
        FFRoute(
          name: DHCLIENTCasaAWidget.routeName,
          path: DHCLIENTCasaAWidget.routePath,
          builder: (context, params) => const DHCLIENTCasaAWidget(),
        ),
        FFRoute(
          name: DHCLIENTProximasVisitasListaWidget.routeName,
          path: DHCLIENTProximasVisitasListaWidget.routePath,
          builder: (context, params) =>
              const DHCLIENTProximasVisitasListaWidget(),
        ),
        FFRoute(
          name: DHCLIENTVisitasFinalizadasListaWidget.routeName,
          path: DHCLIENTVisitasFinalizadasListaWidget.routePath,
          builder: (context, params) =>
              const DHCLIENTVisitasFinalizadasListaWidget(),
        ),
        FFRoute(
          name: DHCLIENTOtraUbicacionWidget.routeName,
          path: DHCLIENTOtraUbicacionWidget.routePath,
          builder: (context, params) => const DHCLIENTOtraUbicacionWidget(),
        ),
        FFRoute(
          name: DHCLIENTCotizacionesRecibidasWidget.routeName,
          path: DHCLIENTCotizacionesRecibidasWidget.routePath,
          builder: (context, params) =>
              const DHCLIENTCotizacionesRecibidasWidget(),
        ),
        FFRoute(
          name: DHCLIENTMaterialesWidget.routeName,
          path: DHCLIENTMaterialesWidget.routePath,
          builder: (context, params) => const DHCLIENTMaterialesWidget(),
        ),
        FFRoute(
          name: DHCLIENTFueraDeAlcanceWidget.routeName,
          path: DHCLIENTFueraDeAlcanceWidget.routePath,
          builder: (context, params) => const DHCLIENTFueraDeAlcanceWidget(),
        ),
        FFRoute(
          name: DHCLIENTTrabajoFinalizadoWidget.routeName,
          path: DHCLIENTTrabajoFinalizadoWidget.routePath,
          builder: (context, params) => const DHCLIENTTrabajoFinalizadoWidget(),
        ),
        FFRoute(
          name: DHCLIENTReportarProblemaWidget.routeName,
          path: DHCLIENTReportarProblemaWidget.routePath,
          builder: (context, params) => const DHCLIENTReportarProblemaWidget(),
        ),
        FFRoute(
          name: DHCLIENTCalificarWidget.routeName,
          path: DHCLIENTCalificarWidget.routePath,
          builder: (context, params) => const DHCLIENTCalificarWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisFavoritosWidget.routeName,
          path: DOVIACLIENTMisFavoritosWidget.routePath,
          builder: (context, params) => const DOVIACLIENTMisFavoritosWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesWidget.routeName,
          path: DOVIACLIENTMisPropiedadesWidget.routePath,
          builder: (context, params) => const DOVIACLIENTMisPropiedadesWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisVisitasWidget.routeName,
          path: DOVIACLIENTMisVisitasWidget.routePath,
          builder: (context, params) => const DOVIACLIENTMisVisitasWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTNotificacionesWidget.routeName,
          path: DOVIACLIENTNotificacionesWidget.routePath,
          builder: (context, params) => const DOVIACLIENTNotificacionesWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTAjustesWidget.routeName,
          path: DOVIACLIENTAjustesWidget.routePath,
          builder: (context, params) => const DOVIACLIENTAjustesWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTSobreMiVisitaWidget.routeName,
          path: DOVIACLIENTSobreMiVisitaWidget.routePath,
          builder: (context, params) => DOVIACLIENTSobreMiVisitaWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
            visitId: params.getParam(
              'visitId',
              ParamType.String,
            ),
            showingAgentId: params.getParam(
              'showingAgentId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTVisitaAceptadaWidget.routeName,
          path: DOVIACLIENTVisitaAceptadaWidget.routePath,
          builder: (context, params) => DOVIACLIENTVisitaAceptadaWidget(
            propertyId: params.getParam(
                  'propertyId',
                  ParamType.String,
                ) ??
                '',
            visitId: params.getParam(
                  'visitId',
                  ParamType.String,
                ) ??
                '',
          ),
        ),
        FFRoute(
          name: DOVIACLIENTOfertarWidget.routeName,
          path: DOVIACLIENTOfertarWidget.routePath,
          builder: (context, params) => DOVIACLIENTOfertarWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTOfertaRentaWidget.routeName,
          path: DOVIACLIENTOfertaRentaWidget.routePath,
          builder: (context, params) => DOVIACLIENTOfertaRentaWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTRentaWidget.routeName,
          path: DOVIACLIENTRentaWidget.routePath,
          builder: (context, params) => const DOVIACLIENTRentaWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTOfertaCompraWidget.routeName,
          path: DOVIACLIENTOfertaCompraWidget.routePath,
          builder: (context, params) => DOVIACLIENTOfertaCompraWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
            offerType: params.getParam(
                  'offerType',
                  ParamType.String,
                ) ??
                'compra',
            fromSelectionScreen: params.getParam(
                  'fromSelectionScreen',
                  ParamType.bool,
                ) ??
                false,
            isAmbosFlow: params.getParam(
                  'isAmbosFlow',
                  ParamType.bool,
                ) ??
                false,
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisVisitasTuPropuestaWidget.routeName,
          path: DOVIACLIENTMisVisitasTuPropuestaWidget.routePath,
          builder: (context, params) => DOVIACLIENTMisVisitasTuPropuestaWidget(
            propuestaState: params.getParam('propuestaState', ParamType.String),
            paymentMethod: params.getParam('paymentMethod', ParamType.String),
            offerId: params.getParam('offerId', ParamType.String),
          ),
        ),
        FFRoute(
          name: DCFormaPagoSuscripcion2Widget.routeName,
          path: DCFormaPagoSuscripcion2Widget.routePath,
          builder: (context, params) => const DCFormaPagoSuscripcion2Widget(),
        ),
        FFRoute(
          name: DCFormaPagoSuscripcion1Widget.routeName,
          path: DCFormaPagoSuscripcion1Widget.routePath,
          builder: (context, params) => const DCFormaPagoSuscripcion1Widget(),
        ),
        FFRoute(
          name: DOVIACLIENTHomePage2MapaWidget.routeName,
          path: DOVIACLIENTHomePage2MapaWidget.routePath,
          builder: (context, params) => const DOVIACLIENTHomePage2MapaWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTPropiedadSeleccionadaWidget.routeName,
          path: DOVIACLIENTPropiedadSeleccionadaWidget.routePath,
          builder: (context, params) => DOVIACLIENTPropiedadSeleccionadaWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTHomepageBusquedaWidget.routeName,
          path: DOVIACLIENTHomepageBusquedaWidget.routePath,
          builder: (context, params) =>
              const DOVIACLIENTHomepageBusquedaWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisFavoritosCarpetasWidget.routeName,
          path: DOVIACLIENTMisFavoritosCarpetasWidget.routePath,
          builder: (context, params) =>
              const DOVIACLIENTMisFavoritosCarpetasWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget.routeName,
          path: DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTMisFavoritosCarpetaSeleccionadaWidget(
            folderName: params.getParam(
              'folderName',
              ParamType.String,
            ),
            folderId: params.getParam(
              'folderId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTComoFuncionaWidget.routeName,
          path: DOVIACLIENTComoFuncionaWidget.routePath,
          builder: (context, params) => const DOVIACLIENTComoFuncionaWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesAccionesARealizarWidget.routeName,
          path: DOVIACLIENTMisPropiedadesAccionesARealizarWidget.routePath,
          builder: (context, params) =>
              const DOVIACLIENTMisPropiedadesAccionesARealizarWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesVenderWidget.routeName,
          path: DOVIACLIENTMisPropiedadesVenderWidget.routePath,
          builder: (context, params) =>
              const DOVIACLIENTMisPropiedadesVenderWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesRentarWidget.routeName,
          path: DOVIACLIENTMisPropiedadesRentarWidget.routePath,
          builder: (context, params) =>
              const DOVIACLIENTMisPropiedadesRentarWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesAgendarVisitaWidget.routeName,
          path: DOVIACLIENTMisPropiedadesAgendarVisitaWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTMisPropiedadesAgendarVisitaWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesVisita1Widget.routeName,
          path: DOVIACLIENTMisPropiedadesVisita1Widget.routePath,
          builder: (context, params) => DOVIACLIENTMisPropiedadesVisita1Widget(
            visitId: params.getParam(
              'visitId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget.routeName,
          path: DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTMisPropiedadesPropiedadPublicadaWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
            propertyStatus: params.getParam(
              'propertyStatus',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTPropuestasRecientesWidget.routeName,
          path: DOVIACLIENTPropuestasRecientesWidget.routePath,
          builder: (context, params) =>
              const DOVIACLIENTPropuestasRecientesWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTPropuestasListaWidget.routeName,
          path: DOVIACLIENTPropuestasListaWidget.routePath,
          builder: (context, params) => DOVIACLIENTPropuestasListaWidget(
            lane: params.getParam(
              'lane',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesPropuestaWidget.routeName,
          path: DOVIACLIENTMisPropiedadesPropuestaWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTMisPropiedadesPropuestaWidget(
            proposalType: params.getParam(
              'proposalType',
              ParamType.String,
            ),
            offerId: params.getParam(
              'offerId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTPropuestaDeVisitaWidget.routeName,
          path: DOVIACLIENTPropuestaDeVisitaWidget.routePath,
          builder: (context, params) => DOVIACLIENTPropuestaDeVisitaWidget(
            propertyId: params.getParam(
                  'propertyId',
                  ParamType.String,
                ) ??
                '',
            visitId: params.getParam(
                  'visitId',
                  ParamType.String,
                ) ??
                '',
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesContraofertarWidget.routeName,
          path: DOVIACLIENTMisPropiedadesContraofertarWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTMisPropiedadesContraofertarWidget(
            proposalType: params.getParam('proposalType', ParamType.String),
            offerId: params.getParam('offerId', ParamType.String),
            initialAmount: params.getParam('initialAmount', ParamType.String),
            currency: params.getParam('currency', ParamType.String),
            paymentMethod: params.getParam('paymentMethod', ParamType.String),
            considerations: params.getParam('considerations', ParamType.String),
            bankName: params.getParam('bankName', ParamType.String),
            downPayment: params.getParam('downPayment', ParamType.String),
            initialReserve: params.getParam('initialReserve', ParamType.String),
            finalPayment: params.getParam('finalPayment', ParamType.String),
            promiseTimeMonths:
                params.getParam('promiseTimeMonths', ParamType.String),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesAcuerdoWidget.routeName,
          path: DOVIACLIENTMisPropiedadesAcuerdoWidget.routePath,
          builder: (context, params) => DOVIACLIENTMisPropiedadesAcuerdoWidget(
            negociationStep: params.getParam(
              'negociationStep',
              ParamType.double,
            ),
            paymentMethod: params.getParam(
              'paymentMethod',
              ParamType.String,
            ),
            proposedAmount: params.getParam(
              'proposedAmount',
              ParamType.String,
            ),
            offerId: params.getParam(
              'offerId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: OPERATIVELISTINGHomeWidget.routeName,
          path: OPERATIVELISTINGHomeWidget.routePath,
          builder: (context, params) => const OPERATIVELISTINGHomeWidget(),
        ),
        FFRoute(
          name: OPERATIVELISTINGPrimeraVisitaWidget.routeName,
          path: OPERATIVELISTINGPrimeraVisitaWidget.routePath,
          builder: (context, params) => OPERATIVELISTINGPrimeraVisitaWidget(
            visitId: params.getParam('visitId', ParamType.String) ?? '',
            isPrimeraVisita:
                params.getParam('isPrimeraVisita', ParamType.bool) ?? true,
            propertyName:
                params.getParam('propertyName', ParamType.String) ?? '',
            isReadOnly: params.getParam('isReadOnly', ParamType.bool) ?? false,
          ),
        ),
        FFRoute(
          name: OPERATIVELISTINGProfileWidget.routeName,
          path: OPERATIVELISTINGProfileWidget.routePath,
          builder: (context, params) => const OPERATIVELISTINGProfileWidget(),
        ),
        FFRoute(
          name: OPERATIVELISTINGChecklistWidget.routeName,
          path: OPERATIVELISTINGChecklistWidget.routePath,
          builder: (context, params) => const OPERATIVELISTINGChecklistWidget(),
        ),
        FFRoute(
          name: OPERATIVELISTINGChecklistFormWidget.routeName,
          path: OPERATIVELISTINGChecklistFormWidget.routePath,
          builder: (context, params) => OPERATIVELISTINGChecklistFormWidget(
            visitId: params.getParam('visitId', ParamType.String) ?? '',
          ),
        ),
        FFRoute(
          name: OPERATIVELISTINGAgendaWidget.routeName,
          path: OPERATIVELISTINGAgendaWidget.routePath,
          builder: (context, params) => const OPERATIVELISTINGAgendaWidget(),
        ),
        FFRoute(
          name: OPERATIVELISTINGNotificationsWidget.routeName,
          path: OPERATIVELISTINGNotificationsWidget.routePath,
          builder: (context, params) =>
              const OPERATIVELISTINGNotificationsWidget(),
        ),
        FFRoute(
          name: LISTINGHQHomeWidget.routeName,
          path: LISTINGHQHomeWidget.routePath,
          builder: (context, params) => const LISTINGHQHomeWidget(),
        ),
        FFRoute(
          name: LISTINGHQBusquedaPropiedadWidget.routeName,
          path: LISTINGHQBusquedaPropiedadWidget.routePath,
          builder: (context, params) =>
              const LISTINGHQBusquedaPropiedadWidget(),
        ),
        FFRoute(
          name: LISTINGHQDocumentosPendientesWidget.routeName,
          path: LISTINGHQDocumentosPendientesWidget.routePath,
          builder: (context, params) =>
              const LISTINGHQDocumentosPendientesWidget(),
        ),
        FFRoute(
          name: LISTINGHQPropiedadArchivosPendientesWidget.routeName,
          path: LISTINGHQPropiedadArchivosPendientesWidget.routePath,
          builder: (context, params) =>
              LISTINGHQPropiedadArchivosPendientesWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LISTINGHQNotificationsWidget.routeName,
          path: LISTINGHQNotificationsWidget.routePath,
          builder: (context, params) => const LISTINGHQNotificationsWidget(),
        ),
        FFRoute(
          name: LISTINGHQProfileWidget.routeName,
          path: LISTINGHQProfileWidget.routePath,
          builder: (context, params) => const LISTINGHQProfileWidget(),
        ),
        FFRoute(
          name: LISTINGHQPropiedadesWidget.routeName,
          path: LISTINGHQPropiedadesWidget.routePath,
          builder: (context, params) => const LISTINGHQPropiedadesWidget(),
        ),
        FFRoute(
          name: LISTINGHQPropiedadAsignadaWidget.routeName,
          path: LISTINGHQPropiedadAsignadaWidget.routePath,
          builder: (context, params) => LISTINGHQPropiedadAsignadaWidget(
            visitId: params.getParam(
              'visitId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LISTINGHQDocumentosWidget.routeName,
          path: LISTINGHQDocumentosWidget.routePath,
          builder: (context, params) => const LISTINGHQDocumentosWidget(),
        ),
        FFRoute(
          name: LISTINGHQPropiedadWidget.routeName,
          path: LISTINGHQPropiedadWidget.routePath,
          builder: (context, params) => LISTINGHQPropiedadWidget(
            visitId: params.getParam(
              'visitId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LISTINGHQPropiedadRechazadaWidget.routeName,
          path: LISTINGHQPropiedadRechazadaWidget.routePath,
          builder: (context, params) => LISTINGHQPropiedadRechazadaWidget(
            processId: params.getParam(
                  'processId',
                  ParamType.String,
                ) ??
                '',
          ),
        ),
        FFRoute(
          name: LISTINGHQDocumentos2Widget.routeName,
          path: LISTINGHQDocumentos2Widget.routePath,
          builder: (context, params) => LISTINGHQDocumentos2Widget(
            propiedad: params.getParam(
              'propiedad',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LISTINGHQDocumentos3Widget.routeName,
          path: LISTINGHQDocumentos3Widget.routePath,
          builder: (context, params) => LISTINGHQDocumentos3Widget(
            propiedad: params.getParam(
              'propiedad',
              ParamType.String,
            ),
            nombreDocumento: params.getParam(
              'nombreDocumento',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SHOWINGHomeWidget.routeName,
          path: SHOWINGHomeWidget.routePath,
          builder: (context, params) => const SHOWINGHomeWidget(),
        ),
        FFRoute(
          name: SHOWINGVisitaDelDiaWidget.routeName,
          path: SHOWINGVisitaDelDiaWidget.routePath,
          builder: (context, params) => const SHOWINGVisitaDelDiaWidget(),
        ),
        FFRoute(
          name: SHOWINGNotificationsWidget.routeName,
          path: SHOWINGNotificationsWidget.routePath,
          builder: (context, params) => const SHOWINGNotificationsWidget(),
        ),
        FFRoute(
          name: SHOWINGProfileWidget.routeName,
          path: SHOWINGProfileWidget.routePath,
          builder: (context, params) => const SHOWINGProfileWidget(),
        ),
        FFRoute(
          name: SHOWINGPropiedadesAMostrarWidget.routeName,
          path: SHOWINGPropiedadesAMostrarWidget.routePath,
          builder: (context, params) =>
              const SHOWINGPropiedadesAMostrarWidget(),
        ),
        FFRoute(
          name: SHOWINGPropiedadAMostrarWidget.routeName,
          path: SHOWINGPropiedadAMostrarWidget.routePath,
          builder: (context, params) => SHOWINGPropiedadAMostrarWidget(
            visitId: params.getParam(
              'visitId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SHOWINGPropiedadDetalleWidget.routeName,
          path: SHOWINGPropiedadDetalleWidget.routePath,
          builder: (context, params) => SHOWINGPropiedadDetalleWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SHOWINGAgendaWidget.routeName,
          path: SHOWINGAgendaWidget.routePath,
          builder: (context, params) => const SHOWINGAgendaWidget(),
        ),
        FFRoute(
          name: SHOWINGRegistroDeVisitaWidget.routeName,
          path: SHOWINGRegistroDeVisitaWidget.routePath,
          builder: (context, params) => const SHOWINGRegistroDeVisitaWidget(),
        ),
        FFRoute(
          name: SHOWINGRegistroDeVisita2Widget.routeName,
          path: SHOWINGRegistroDeVisita2Widget.routePath,
          builder: (context, params) => SHOWINGRegistroDeVisita2Widget(
            visitId: params.getParam('visitId', ParamType.String),
          ),
        ),
        FFRoute(
          name: BienvenidaWidget.routeName,
          path: BienvenidaWidget.routePath,
          builder: (context, params) => const BienvenidaWidget(),
        ),
        FFRoute(
          name: Datos3NewWidget.routeName,
          path: Datos3NewWidget.routePath,
          builder: (context, params) => const Datos3NewWidget(),
        ),
        FFRoute(
          name: ElegirRolAsociadoWidget.routeName,
          path: ElegirRolAsociadoWidget.routePath,
          builder: (context, params) => const ElegirRolAsociadoWidget(),
        ),
        FFRoute(
          name: FormAssociateWidget.routeName,
          path: FormAssociateWidget.routePath,
          builder: (context, params) => const FormAssociateWidget(),
        ),
        FFRoute(
          name: LegalAssociateHomeWidget.routeName,
          path: LegalAssociateHomeWidget.routePath,
          builder: (context, params) => const LegalAssociateHomeWidget(),
        ),
        FFRoute(
          name: LEGALASSOCIATEDocumentosWidget.routeName,
          path: LEGALASSOCIATEDocumentosWidget.routePath,
          builder: (context, params) => const LEGALASSOCIATEDocumentosWidget(),
        ),
        FFRoute(
          name: LEGALASSOCAITEDocumentos2Widget.routeName,
          path: LEGALASSOCAITEDocumentos2Widget.routePath,
          builder: (context, params) => LEGALASSOCAITEDocumentos2Widget(
            selectedProperty: params.getParam(
              'selectedProperty',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LEGALASSOCIATEProcesosWidget.routeName,
          path: LEGALASSOCIATEProcesosWidget.routePath,
          builder: (context, params) => const LEGALASSOCIATEProcesosWidget(),
        ),
        FFRoute(
          name: LEGALASSOCIATEProcesos2Widget.routeName,
          path: LEGALASSOCIATEProcesos2Widget.routePath,
          builder: (context, params) => const LEGALASSOCIATEProcesos2Widget(),
        ),
        FFRoute(
          name: LEGALASSOCIATENotificationsWidget.routeName,
          path: LEGALASSOCIATENotificationsWidget.routePath,
          builder: (context, params) =>
              const LEGALASSOCIATENotificationsWidget(),
        ),
        FFRoute(
          name: LEGALASSOCIATEAjustesWidget.routeName,
          path: LEGALASSOCIATEAjustesWidget.routePath,
          builder: (context, params) => const LEGALASSOCIATEAjustesWidget(),
        ),
        FFRoute(
          name: LEGALHQHomeWidget.routeName,
          path: LEGALHQHomeWidget.routePath,
          builder: (context, params) => const LEGALHQHomeWidget(),
        ),
        FFRoute(
          name: LEGALHQProcesosCasosConHipotecaWidget.routeName,
          path: LEGALHQProcesosCasosConHipotecaWidget.routePath,
          builder: (context, params) => LEGALHQProcesosCasosConHipotecaWidget(
            processId: params.getParam(
              'processId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LEGALHQAjustesWidget.routeName,
          path: LEGALHQAjustesWidget.routePath,
          builder: (context, params) => const LEGALHQAjustesWidget(),
        ),
        FFRoute(
          name: LEGALHQNotificacionesWidget.routeName,
          path: LEGALHQNotificacionesWidget.routePath,
          builder: (context, params) => const LEGALHQNotificacionesWidget(),
        ),
        FFRoute(
          name: LEGALHQProcesosWidget.routeName,
          path: LEGALHQProcesosWidget.routePath,
          builder: (context, params) => const LEGALHQProcesosWidget(),
        ),
        FFRoute(
          name: LEGALHQRevisionDocumentosPropiedadesWidget.routeName,
          path: LEGALHQRevisionDocumentosPropiedadesWidget.routePath,
          builder: (context, params) =>
              LEGALHQRevisionDocumentosPropiedadesWidget(
            processId: params.getParam(
              'processId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LEGALHQDocumentoWidget.routeName,
          path: LEGALHQDocumentoWidget.routePath,
          builder: (context, params) => LEGALHQDocumentoWidget(
            nombreDocumento: params.getParam(
              'nombreDocumento',
              ParamType.String,
            ),
            processId: params.getParam(
              'processId',
              ParamType.String,
            ),
            documentId: params.getParam(
              'documentId',
              ParamType.String,
            ),
            documentUrl: params.getParam(
              'documentUrl',
              ParamType.String,
            ),
            propertyName: params.getParam(
              'propertyName',
              ParamType.String,
            ),
            category: params.getParam(
              'category',
              ParamType.String,
            ),
            readOnly: params.getParam(
              'readOnly',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: LEGALHQPostVentaWidget.routeName,
          path: LEGALHQPostVentaWidget.routePath,
          builder: (context, params) => LEGALHQPostVentaWidget(
            processId: params.getParam(
              'processId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DOVIACLIENTMisPropiedadesVenderRentarWidget.routeName,
          path: DOVIACLIENTMisPropiedadesVenderRentarWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTMisPropiedadesVenderRentarWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
            transactionType: params.getParam<PropertyPublicationType>(
              'transactionType',
              ParamType.Enum,
            ),
          ),
        ),
        FFRoute(
          name: ComoUsarasTuCuentaWidget.routeName,
          path: ComoUsarasTuCuentaWidget.routePath,
          builder: (context, params) => const ComoUsarasTuCuentaWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTPropiedadSeleccionadaNewWidget.routeName,
          path: DOVIACLIENTPropiedadSeleccionadaNewWidget.routePath,
          builder: (context, params) =>
              DOVIACLIENTPropiedadSeleccionadaNewWidget(
            propertyId: params.getParam(
              'propertyId',
              ParamType.String,
            ),
            isReadOnly: params.getParam(
                  'isReadOnly',
                  ParamType.bool,
                ) ??
                false,
          ),
        ),
        FFRoute(
          name: MapWithHousesTestWidget.routeName,
          path: MapWithHousesTestWidget.routePath,
          builder: (context, params) => const MapWithHousesTestWidget(),
        ),
        FFRoute(
          name: DatosCustomWidget.routeName,
          path: DatosCustomWidget.routePath,
          builder: (context, params) => const DatosCustomWidget(),
        ),
        FFRoute(
          name: DOVIACLIENTVerMasPropiedadesWidget.routeName,
          path: DOVIACLIENTVerMasPropiedadesWidget.routePath,
          builder: (context, params) => DOVIACLIENTVerMasPropiedadesWidget(
            title: params.getParam(
              'title',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: MapWidgetPageTestWidget.routeName,
          path: MapWidgetPageTestWidget.routePath,
          builder: (context, params) => const MapWidgetPageTestWidget(),
        ),
        FFRoute(
          name: RecoverPasswordStep1Widget.routeName,
          path: RecoverPasswordStep1Widget.routePath,
          builder: (context, params) => const RecoverPasswordStep1Widget(),
        ),
        FFRoute(
          name: RecoverPasswordStep2Widget.routeName,
          path: RecoverPasswordStep2Widget.routePath,
          builder: (context, params) => RecoverPasswordStep2Widget(
            email: params.getParam(
              'email',
              ParamType.String,
            ),
          ),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/queEsDovia';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: FlutterFlowTheme.of(context).primary,
                  child: Center(
                    child: Image.asset(
                      'assets/images/D-blanca.svg',
                      height: 200.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() =>
      const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
