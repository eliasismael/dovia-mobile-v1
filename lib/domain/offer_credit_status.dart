// Vocabulario de `creditStatus`, el estado del crédito de una oferta con
// hipoteca.
//
// El contrato lo define como un enum acotado —`approved`, `in_process`,
// `not_started`— y opcional, presente sólo cuando `paymentMethod` es
// `mortgage`. Se escribía a mano en el formulario, así que cualquier texto
// libre salía hacia un campo que sólo acepta esos tres valores. La lista y sus
// etiquetas viven acá para que el desplegable que los ofrece y las pantallas
// que los muestran lean lo mismo.

/// Los valores que acepta la API, en el orden en que se ofrecen.
const List<String> kCreditStatusValues = [
  'approved',
  'in_process',
  'not_started',
];

const Map<String, String> _labels = {
  'approved': 'Aprobado',
  'in_process': 'En proceso',
  'not_started': 'No iniciado',
};

/// Etiquetas en el orden de [kCreditStatusValues], para un desplegable.
List<String> get creditStatusLabels =>
    kCreditStatusValues.map((value) => _labels[value]!).toList();

/// Traduce el valor del contrato a la etiqueta que ve el usuario. Devuelve
/// `null` si el backend manda algo que no está en el enum, para que quien
/// llama decida si mostrar el crudo o un guion.
String? creditStatusLabel(String? value) {
  if (value == null) return null;
  return _labels[value.toLowerCase()];
}

/// Traduce la etiqueta elegida en el desplegable al valor del contrato.
String? creditStatusValueFromLabel(String? label) {
  if (label == null) return null;
  for (final entry in _labels.entries) {
    if (entry.value == label) return entry.key;
  }
  return null;
}
