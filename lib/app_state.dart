import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
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
