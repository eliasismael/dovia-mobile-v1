// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserDataFromRegisterFormStruct extends BaseStruct {
  UserDataFromRegisterFormStruct({
    String? name,
    String? lastname,
    int? birthdayDay,
    int? birthdayMonth,
    int? birthdayYear,
    String? gender,
    String? nationality,
    String? phoneCode,
    String? phoneNumber,
  })  : _name = name,
        _lastname = lastname,
        _birthdayDay = birthdayDay,
        _birthdayMonth = birthdayMonth,
        _birthdayYear = birthdayYear,
        _gender = gender,
        _nationality = nationality,
        _phoneCode = phoneCode,
        _phoneNumber = phoneNumber;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "lastname" field.
  String? _lastname;
  String get lastname => _lastname ?? '';
  set lastname(String? val) => _lastname = val;

  bool hasLastname() => _lastname != null;

  // "birthdayDay" field.
  int? _birthdayDay;
  int get birthdayDay => _birthdayDay ?? 0;
  set birthdayDay(int? val) => _birthdayDay = val;

  void incrementBirthdayDay(int amount) => birthdayDay = birthdayDay + amount;

  bool hasBirthdayDay() => _birthdayDay != null;

  // "birthdayMonth" field.
  int? _birthdayMonth;
  int get birthdayMonth => _birthdayMonth ?? 0;
  set birthdayMonth(int? val) => _birthdayMonth = val;

  void incrementBirthdayMonth(int amount) =>
      birthdayMonth = birthdayMonth + amount;

  bool hasBirthdayMonth() => _birthdayMonth != null;

  // "birthdayYear" field.
  int? _birthdayYear;
  int get birthdayYear => _birthdayYear ?? 0;
  set birthdayYear(int? val) => _birthdayYear = val;

  void incrementBirthdayYear(int amount) =>
      birthdayYear = birthdayYear + amount;

  bool hasBirthdayYear() => _birthdayYear != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  set gender(String? val) => _gender = val;

  bool hasGender() => _gender != null;

  // "nationality" field.
  String? _nationality;
  String get nationality => _nationality ?? '';
  set nationality(String? val) => _nationality = val;

  bool hasNationality() => _nationality != null;

  // "phoneCode" field.
  String? _phoneCode;
  String get phoneCode => _phoneCode ?? '';
  set phoneCode(String? val) => _phoneCode = val;

  bool hasPhoneCode() => _phoneCode != null;

  // "phoneNumber" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  set phoneNumber(String? val) => _phoneNumber = val;

  bool hasPhoneNumber() => _phoneNumber != null;

  static UserDataFromRegisterFormStruct fromMap(Map<String, dynamic> data) =>
      UserDataFromRegisterFormStruct(
        name: data['name'] as String?,
        lastname: data['lastname'] as String?,
        birthdayDay: castToType<int>(data['birthdayDay']),
        birthdayMonth: castToType<int>(data['birthdayMonth']),
        birthdayYear: castToType<int>(data['birthdayYear']),
        gender: data['gender'] as String?,
        nationality: data['nationality'] as String?,
        phoneCode: data['phoneCode'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
      );

  static UserDataFromRegisterFormStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? UserDataFromRegisterFormStruct.fromMap(data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'lastname': _lastname,
        'birthdayDay': _birthdayDay,
        'birthdayMonth': _birthdayMonth,
        'birthdayYear': _birthdayYear,
        'gender': _gender,
        'nationality': _nationality,
        'phoneCode': _phoneCode,
        'phoneNumber': _phoneNumber,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'lastname': serializeParam(
          _lastname,
          ParamType.String,
        ),
        'birthdayDay': serializeParam(
          _birthdayDay,
          ParamType.int,
        ),
        'birthdayMonth': serializeParam(
          _birthdayMonth,
          ParamType.int,
        ),
        'birthdayYear': serializeParam(
          _birthdayYear,
          ParamType.int,
        ),
        'gender': serializeParam(
          _gender,
          ParamType.String,
        ),
        'nationality': serializeParam(
          _nationality,
          ParamType.String,
        ),
        'phoneCode': serializeParam(
          _phoneCode,
          ParamType.String,
        ),
        'phoneNumber': serializeParam(
          _phoneNumber,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserDataFromRegisterFormStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      UserDataFromRegisterFormStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        lastname: deserializeParam(
          data['lastname'],
          ParamType.String,
          false,
        ),
        birthdayDay: deserializeParam(
          data['birthdayDay'],
          ParamType.int,
          false,
        ),
        birthdayMonth: deserializeParam(
          data['birthdayMonth'],
          ParamType.int,
          false,
        ),
        birthdayYear: deserializeParam(
          data['birthdayYear'],
          ParamType.int,
          false,
        ),
        gender: deserializeParam(
          data['gender'],
          ParamType.String,
          false,
        ),
        nationality: deserializeParam(
          data['nationality'],
          ParamType.String,
          false,
        ),
        phoneCode: deserializeParam(
          data['phoneCode'],
          ParamType.String,
          false,
        ),
        phoneNumber: deserializeParam(
          data['phoneNumber'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserDataFromRegisterFormStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserDataFromRegisterFormStruct &&
        name == other.name &&
        lastname == other.lastname &&
        birthdayDay == other.birthdayDay &&
        birthdayMonth == other.birthdayMonth &&
        birthdayYear == other.birthdayYear &&
        gender == other.gender &&
        nationality == other.nationality &&
        phoneCode == other.phoneCode &&
        phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode => const ListEquality().hash([
        name,
        lastname,
        birthdayDay,
        birthdayMonth,
        birthdayYear,
        gender,
        nationality,
        phoneCode,
        phoneNumber
      ]);
}

UserDataFromRegisterFormStruct createUserDataFromRegisterFormStruct({
  String? name,
  String? lastname,
  int? birthdayDay,
  int? birthdayMonth,
  int? birthdayYear,
  String? gender,
  String? nationality,
  String? phoneCode,
  String? phoneNumber,
}) =>
    UserDataFromRegisterFormStruct(
      name: name,
      lastname: lastname,
      birthdayDay: birthdayDay,
      birthdayMonth: birthdayMonth,
      birthdayYear: birthdayYear,
      gender: gender,
      nationality: nationality,
      phoneCode: phoneCode,
      phoneNumber: phoneNumber,
    );
