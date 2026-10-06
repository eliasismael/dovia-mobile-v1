import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _UserEmail = prefs.getString('ff_UserEmail') ?? _UserEmail;
    });
    _safeInit(() {
      _UserRole = prefs.getString('ff_UserRole') ?? _UserRole;
    });
    _safeInit(() {
      _onboardingCompleted =
          prefs.getBool('ff_onboardingCompleted') ?? _onboardingCompleted;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_UserData')) {
        try {
          final serializedData = prefs.getString('ff_UserData') ?? '{}';
          _UserData = UserDataFromRegisterFormStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _requestedDateChangesVisits =
          prefs.getStringList('ff_requestedDateChangesVisits') ??
              _requestedDateChangesVisits;
    });
    _safeInit(() {
      _lastActiveVisitId =
          prefs.getString('ff_lastActiveVisitId') ?? _lastActiveVisitId;
    });
    _safeInit(() {
      _routeStartedVisits =
          prefs.getStringList('ff_routeStartedVisits') ?? _routeStartedVisits;
    });
    _safeInit(() {
      _confirmedServiceRequests =
          prefs.getStringList('ff_confirmedServiceRequests') ??
              _confirmedServiceRequests;
    });
    _safeInit(() {
      _hasSeenWelcomeBanner =
          prefs.getBool('ff_hasSeenWelcomeBanner') ?? _hasSeenWelcomeBanner;
    });
    _safeInit(() {
      _seenOwnerProposals =
          prefs.getStringList('ff_seenOwnerProposals') ?? _seenOwnerProposals;
    });
    _safeInit(() {
      _seenClientOffers =
          prefs.getStringList('ff_seenClientOffers') ?? _seenClientOffers;
    });
    _safeInit(() {
      final serialized = prefs.getString('ff_mortgageBankAgents');
      if (serialized == null) return;
      final decoded = jsonDecode(serialized);
      if (decoded is Map) {
        _mortgageBankAgents = Map<String, dynamic>.from(decoded);
      }
    });
  }

  /// Borra los datos personales del usuario que cerró sesión, para que no
  /// aparezcan precargados a quien entre después en el mismo teléfono.
  ///
  /// Las listas indexadas por id (visitas, ofertas, solicitudes) se conservan:
  /// esos ids no se repiten entre cuentas y el mismo usuario los necesita al
  /// volver a entrar.
  void clearUserScopedState() {
    _UserEmail = '';
    prefs.remove('ff_UserEmail');
    _UserData = UserDataFromRegisterFormStruct();
    prefs.remove('ff_UserData');
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  /// User email used across all the app
  String _UserEmail = 'I';
  String get UserEmail => _UserEmail;
  set UserEmail(String value) {
    _UserEmail = value;
    prefs.setString('ff_UserEmail', value);
  }

  String _UserRole = 'CLIENT';
  String get UserRole => _UserRole;
  set UserRole(String value) {
    _UserRole = value;
    prefs.setString('ff_UserRole', value);
  }

  String _TestChangeOnCustomCode = 'I have no value';
  String get TestChangeOnCustomCode => _TestChangeOnCustomCode;
  set TestChangeOnCustomCode(String value) {
    _TestChangeOnCustomCode = value;
  }

  bool _onboardingCompleted = false;
  bool get onboardingCompleted => _onboardingCompleted;
  set onboardingCompleted(bool value) {
    _onboardingCompleted = value;
    prefs.setBool('ff_onboardingCompleted', value);
  }

  bool _hasSeenWelcomeBanner = false;
  bool get hasSeenWelcomeBanner => _hasSeenWelcomeBanner;
  set hasSeenWelcomeBanner(bool value) {
    _hasSeenWelcomeBanner = value;
    prefs.setBool('ff_hasSeenWelcomeBanner', value);
  }

  UserDataFromRegisterFormStruct _UserData = UserDataFromRegisterFormStruct();
  UserDataFromRegisterFormStruct get UserData => _UserData;
  set UserData(UserDataFromRegisterFormStruct value) {
    _UserData = value;
    prefs.setString('ff_UserData', value.serialize());
  }

  void updateUserDataStruct(Function(UserDataFromRegisterFormStruct) updateFn) {
    updateFn(_UserData);
    prefs.setString('ff_UserData', _UserData.serialize());
  }

  List<String> _requestedDateChangesVisits = [];
  List<String> get requestedDateChangesVisits => _requestedDateChangesVisits;
  set requestedDateChangesVisits(List<String> value) {
    _requestedDateChangesVisits = value;
    prefs.setStringList('ff_requestedDateChangesVisits', value);
  }

  void addToRequestedDateChangesVisits(String value) {
    _requestedDateChangesVisits.add(value);
    prefs.setStringList(
        'ff_requestedDateChangesVisits', _requestedDateChangesVisits);
  }

  void removeFromRequestedDateChangesVisits(String value) {
    _requestedDateChangesVisits.remove(value);
    prefs.setStringList(
        'ff_requestedDateChangesVisits', _requestedDateChangesVisits);
  }

  String _lastActiveVisitId = '';
  String get lastActiveVisitId => _lastActiveVisitId;
  set lastActiveVisitId(String value) {
    _lastActiveVisitId = value;
    prefs.setString('ff_lastActiveVisitId', value);
  }

  /// Visit IDs whose route the agent has already started ("en camino").
  /// Used to unlock the private contact info before the 2h window.
  List<String> _routeStartedVisits = [];
  List<String> get routeStartedVisits => _routeStartedVisits;
  set routeStartedVisits(List<String> value) {
    _routeStartedVisits = value;
    prefs.setStringList('ff_routeStartedVisits', value);
  }

  void addToRouteStartedVisits(String value) {
    _routeStartedVisits.add(value);
    prefs.setStringList('ff_routeStartedVisits', _routeStartedVisits);
  }

  void removeFromRouteStartedVisits(String value) {
    _routeStartedVisits.remove(value);
    prefs.setStringList('ff_routeStartedVisits', _routeStartedVisits);
  }

  /// Ids de solicitudes de Dovia Home cuya visita el cliente ya confirmó.
  ///
  /// El backend todavía no expone la confirmación del cliente (el detalle no
  /// trae ningún `confirmedAt` ni `subStatus` para eso), así que el estatus
  /// "Programada" se sostiene localmente. Persistirlo evita que la tarjeta
  /// vuelva a pedir "Confirmar" cada vez que se reinicia la app.
  /// TODO: borrar esto en cuanto exista el endpoint de confirmación.
  List<String> _confirmedServiceRequests = [];
  List<String> get confirmedServiceRequests => _confirmedServiceRequests;
  set confirmedServiceRequests(List<String> value) {
    _confirmedServiceRequests = value;
    prefs.setStringList('ff_confirmedServiceRequests', value);
  }

  void addToConfirmedServiceRequests(String value) {
    if (_confirmedServiceRequests.contains(value)) return;
    _confirmedServiceRequests.add(value);
    prefs.setStringList(
        'ff_confirmedServiceRequests', _confirmedServiceRequests);
  }

  void removeFromConfirmedServiceRequests(String value) {
    _confirmedServiceRequests.remove(value);
    prefs.setStringList(
        'ff_confirmedServiceRequests', _confirmedServiceRequests);
  }

  /// Firmas (`OwnerProposal.seenSignature`) de las propuestas recibidas que el
  /// propietario ya abrió. Sostienen el punto rojo de "Propuestas Recientes":
  /// una oferta nueva, una contraoferta sin leer o un avance del proceso legal
  /// generan una firma distinta y vuelven a encender el badge.
  ///
  /// El backend todavía no expone `readAt` sobre las ofertas; en cuanto exista,
  /// esta lista puede reemplazarse por ese campo.
  List<String> _seenOwnerProposals = [];
  List<String> get seenOwnerProposals => _seenOwnerProposals;
  set seenOwnerProposals(List<String> value) {
    _seenOwnerProposals = value;
    prefs.setStringList('ff_seenOwnerProposals', value);
  }

  bool hasSeenOwnerProposal(String signature) =>
      _seenOwnerProposals.contains(signature);

  void addToSeenOwnerProposals(String signature) {
    if (signature.isEmpty || _seenOwnerProposals.contains(signature)) return;
    _seenOwnerProposals.add(signature);
    // Sólo interesa el estado reciente: se acota para no crecer sin límite.
    if (_seenOwnerProposals.length > 200) {
      _seenOwnerProposals =
          _seenOwnerProposals.sublist(_seenOwnerProposals.length - 200);
    }
    prefs.setStringList('ff_seenOwnerProposals', _seenOwnerProposals);
  }

  /// Lo mismo que [seenOwnerProposals] pero del otro lado del mostrador:
  /// firmas (`ClientOffer.seenSignature`) de las ofertas que el usuario envió
  /// y ya revisó. Sostienen el punto rojo del carril "Contraoferta" de
  /// "Mis Ofertas".
  ///
  /// Se guarda aparte porque son negociaciones distintas: en unas el usuario
  /// es el dueño y en otras el comprador.
  List<String> _seenClientOffers = [];
  List<String> get seenClientOffers => _seenClientOffers;
  set seenClientOffers(List<String> value) {
    _seenClientOffers = value;
    prefs.setStringList('ff_seenClientOffers', value);
  }

  bool hasSeenClientOffer(String signature) =>
      _seenClientOffers.contains(signature);

  void addToSeenClientOffers(String signature) {
    if (signature.isEmpty || _seenClientOffers.contains(signature)) return;
    _seenClientOffers.add(signature);
    // Sólo interesa el estado reciente: se acota para no crecer sin límite.
    if (_seenClientOffers.length > 200) {
      _seenClientOffers =
          _seenClientOffers.sublist(_seenClientOffers.length - 200);
    }
    prefs.setStringList('ff_seenClientOffers', _seenClientOffers);
  }

  /// Gestor bancario que el Legal HQ registró en un expediente hipotecario,
  /// indexado por `processId` y con el shape de `bankAgentData`.
  ///
  /// Vive en el dispositivo porque el backend no tiene dónde guardarlo: expone
  /// `bankAgentData` como snapshot de solo lectura —lo escribe el evento
  /// `BankAgentDataSubmitted` al crear el expediente— y ninguna de sus rutas lo
  /// actualiza. Sirve para que el formulario no vuelva vacío al reentrar; el
  /// registro que sí queda del lado del servidor es la nota de
  /// `mortgage/status`. Cuando exista el endpoint, esto se borra.
  Map<String, dynamic> _mortgageBankAgents = {};
  Map<String, dynamic> get mortgageBankAgents => _mortgageBankAgents;
  set mortgageBankAgents(Map<String, dynamic> value) {
    _mortgageBankAgents = value;
    prefs.setString('ff_mortgageBankAgents', jsonEncode(value));
  }

  /// Gestor guardado para [processId], o `null` si en este dispositivo no se
  /// cargó ninguno.
  Map<String, dynamic>? mortgageBankAgent(String processId) {
    final stored = _mortgageBankAgents[processId];
    return stored is Map ? Map<String, dynamic>.from(stored) : null;
  }

  void setMortgageBankAgent(String processId, Map<String, dynamic> agent) {
    if (processId.isEmpty) return;
    _mortgageBankAgents[processId] = agent;
    prefs.setString('ff_mortgageBankAgents', jsonEncode(_mortgageBankAgents));
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
