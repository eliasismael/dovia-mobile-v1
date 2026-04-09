// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Data used in card for associates but also for clients or houses owners
class UserCardDataStruct extends BaseStruct {
  UserCardDataStruct({
    /// Dovia Showing, Dovia Legal HQ, Información del propietario, etc
    String? roleLabel,
    String? nombre,
    String? sexo,
    String? nacionalidad,
    String? edad,
    String? telefono,
    String? imageUrl,
  })  : _roleLabel = roleLabel,
        _nombre = nombre,
        _sexo = sexo,
        _nacionalidad = nacionalidad,
        _edad = edad,
        _telefono = telefono,
        _imageUrl = imageUrl;

  // "roleLabel" field.
  String? _roleLabel;
  String get roleLabel => _roleLabel ?? '';
  set roleLabel(String? val) => _roleLabel = val;

  bool hasRoleLabel() => _roleLabel != null;

  // "nombre" field.
  String? _nombre;
  String get nombre => _nombre ?? '';
  set nombre(String? val) => _nombre = val;

  bool hasNombre() => _nombre != null;

  // "sexo" field.
  String? _sexo;
  String get sexo => _sexo ?? '';
  set sexo(String? val) => _sexo = val;

  bool hasSexo() => _sexo != null;

  // "nacionalidad" field.
  String? _nacionalidad;
  String get nacionalidad => _nacionalidad ?? '';
  set nacionalidad(String? val) => _nacionalidad = val;

  bool hasNacionalidad() => _nacionalidad != null;

  // "edad" field.
  String? _edad;
  String get edad => _edad ?? '';
  set edad(String? val) => _edad = val;

  bool hasEdad() => _edad != null;

  // "telefono" field.
  String? _telefono;
  String get telefono => _telefono ?? '';
  set telefono(String? val) => _telefono = val;

  bool hasTelefono() => _telefono != null;

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;

  bool hasImageUrl() => _imageUrl != null;

  static UserCardDataStruct fromMap(Map<String, dynamic> data) =>
      UserCardDataStruct(
        roleLabel: data['roleLabel'] as String?,
        nombre: data['nombre'] as String?,
        sexo: data['sexo'] as String?,
        nacionalidad: data['nacionalidad'] as String?,
        edad: data['edad'] as String?,
        telefono: data['telefono'] as String?,
        imageUrl: data['imageUrl'] as String?,
      );

  static UserCardDataStruct? maybeFromMap(dynamic data) => data is Map
      ? UserCardDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'roleLabel': _roleLabel,
        'nombre': _nombre,
        'sexo': _sexo,
        'nacionalidad': _nacionalidad,
        'edad': _edad,
        'telefono': _telefono,
        'imageUrl': _imageUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'roleLabel': serializeParam(
          _roleLabel,
          ParamType.String,
        ),
        'nombre': serializeParam(
          _nombre,
          ParamType.String,
        ),
        'sexo': serializeParam(
          _sexo,
          ParamType.String,
        ),
        'nacionalidad': serializeParam(
          _nacionalidad,
          ParamType.String,
        ),
        'edad': serializeParam(
          _edad,
          ParamType.String,
        ),
        'telefono': serializeParam(
          _telefono,
          ParamType.String,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserCardDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserCardDataStruct(
        roleLabel: deserializeParam(
          data['roleLabel'],
          ParamType.String,
          false,
        ),
        nombre: deserializeParam(
          data['nombre'],
          ParamType.String,
          false,
        ),
        sexo: deserializeParam(
          data['sexo'],
          ParamType.String,
          false,
        ),
        nacionalidad: deserializeParam(
          data['nacionalidad'],
          ParamType.String,
          false,
        ),
        edad: deserializeParam(
          data['edad'],
          ParamType.String,
          false,
        ),
        telefono: deserializeParam(
          data['telefono'],
          ParamType.String,
          false,
        ),
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserCardDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserCardDataStruct &&
        roleLabel == other.roleLabel &&
        nombre == other.nombre &&
        sexo == other.sexo &&
        nacionalidad == other.nacionalidad &&
        edad == other.edad &&
        telefono == other.telefono &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([roleLabel, nombre, sexo, nacionalidad, edad, telefono, imageUrl]);
}

UserCardDataStruct createUserCardDataStruct({
  String? roleLabel,
  String? nombre,
  String? sexo,
  String? nacionalidad,
  String? edad,
  String? telefono,
  String? imageUrl,
}) =>
    UserCardDataStruct(
      roleLabel: roleLabel,
      nombre: nombre,
      sexo: sexo,
      nacionalidad: nacionalidad,
      edad: edad,
      telefono: telefono,
      imageUrl: imageUrl,
    );
