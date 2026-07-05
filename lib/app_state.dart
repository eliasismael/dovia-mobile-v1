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
