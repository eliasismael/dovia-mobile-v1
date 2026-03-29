import 'package:collection/collection.dart';

enum Roles {
  CLIENT,
  VISITOR,
  SHOWING,
  OPERATIVE_LISTER,
  LISTER_HQ,
  ASSOCIATE,
  LEGAL_ASSOCIATE,
  LEGAL_HQ,
}

enum TipoDeOfertaDeCompra {
  Hipoteca,
  Contado,
  PromesaDeCompra,
}

enum PropertyPublicationType {
  SALE,
  RENT,
  SALE_AND_RENT,
}

/// Usario o asociado
enum UserType {
  usuario,
  asociado,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (Roles):
      return Roles.values.deserialize(value) as T?;
    case (TipoDeOfertaDeCompra):
      return TipoDeOfertaDeCompra.values.deserialize(value) as T?;
    case (PropertyPublicationType):
      return PropertyPublicationType.values.deserialize(value) as T?;
    case (UserType):
      return UserType.values.deserialize(value) as T?;
    default:
      return null;
  }
}
