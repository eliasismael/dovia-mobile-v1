/// Subida de imágenes de Dovia Home: presign → PUT directo a S3 → confirm.
///
/// Los cinco flujos con imágenes (solicitud de servicio, cotización, evidencia
/// de cierre, materiales extra y trabajo fuera de alcance) comparten el mismo
/// contrato, así que comparten esta implementación:
///
///   1. `.../presign` recibe `uploads[]` con `fileName`, `mimeType` y
///      `sizeBytes`, y devuelve `items[]` con `clientUploadId`, `storageKey`,
///      `uploadUrl` y `requiredHeaders`.
///   2. El archivo se sube con un PUT directo a `uploadUrl`, **sin** el Bearer
///      token: la URL ya viene firmada y mandar credenciales de más la invalida.
///   3. `.../confirm` recibe los `storageKeys` que sí llegaron a S3; el backend
///      valida prefijo y existencia antes de persistir las URLs públicas.
///
/// Presignar no persiste nada: lo que cuenta es el confirm. Por eso una imagen
/// que falla en el PUT simplemente no entra en `storageKeys`, en vez de abortar
/// la tanda entera.
library;

import '/backend/api_requests/presigned_upload.dart';
import 'dart:typed_data';


import 'api_manager.dart';

/// MIME declarado a partir de la extensión.
///
/// El backend valida el tipo que se declara en el presign, así que asumir JPEG
/// para todo hace que un PNG termine rechazado o guardado con el tipo
/// equivocado.
String doviaHomeMimeTypeFor(String fileName) {
  switch (fileName.toLowerCase().split('.').last) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    case 'heif':
      return 'image/heif';
    default:
      return 'image/jpeg';
  }
}

/// Imagen lista para subir.
class DoviaHomeUpload {
  const DoviaHomeUpload({
    required this.fileName,
    required this.bytes,
    this.mimeType = 'image/jpeg',
  });

  final String fileName;
  final Uint8List bytes;

  /// Sólo se aceptan MIME de imagen (`image/jpeg`, `image/jpg`, `image/png`,
  /// `image/webp`). El límite implementado es 10 MB por archivo.
  final String mimeType;

  int get sizeBytes => bytes.length;
}

/// Resultado de una tanda de subidas.
class DoviaHomeUploadResult {
  const DoviaHomeUploadResult({
    required this.confirmedUrls,
    required this.requested,
    required this.uploaded,
  });

  /// URLs públicas que el backend persistió al confirmar.
  final List<String> confirmedUrls;

  /// Cuántas imágenes se intentaron subir.
  final int requested;

  /// Cuántas llegaron a S3. Menor que [requested] si alguna falló.
  final int uploaded;

  bool get isEmpty => confirmedUrls.isEmpty;

  /// Alguna imagen se quedó en el camino. La pantalla lo dice en vez de dar la
  /// tanda por completa.
  bool get isPartial => uploaded < requested;
}

/// Firma de un endpoint `.../presign` ya atado a su solicitud.
typedef PresignRequest = Future<ApiCallResponse> Function(
    List<Map<String, dynamic>> uploads);

/// Firma de un endpoint `.../confirm` ya atado a su solicitud.
typedef ConfirmRequest = Future<ApiCallResponse> Function(
    List<String> storageKeys);

/// Corre el ciclo completo para [uploads].
///
/// [extractItems] saca `items[]` del cuerpo del presign (cada call tiene su
/// propio getter) y [extractUrls] saca las URLs del confirm. Devuelve el
/// resultado con lo que efectivamente quedó persistido; con `uploads` vacío no
/// llama a la red, porque las imágenes son opcionales en todos estos flujos.
Future<DoviaHomeUploadResult> uploadDoviaHomeImages({
  required List<DoviaHomeUpload> uploads,
  required PresignRequest presign,
  required ConfirmRequest confirm,
  required List? Function(dynamic body) extractItems,
  List? Function(dynamic body)? extractUrls,
}) async {
  if (uploads.isEmpty) {
    return const DoviaHomeUploadResult(
      confirmedUrls: [],
      requested: 0,
      uploaded: 0,
    );
  }

  // `clientUploadId` es lo que permite volver a casar cada item del presign con
  // sus bytes: el backend no garantiza el orden de `items[]`.
  final payload = <Map<String, dynamic>>[
    for (var i = 0; i < uploads.length; i++)
      {
        'clientUploadId': 'upload_$i',
        'fileName': uploads[i].fileName,
        'mimeType': uploads[i].mimeType,
        'sizeBytes': uploads[i].sizeBytes,
      },
  ];

  final presignRes = await presign(payload);
  if (!presignRes.succeeded) {
    return DoviaHomeUploadResult(
      confirmedUrls: const [],
      requested: uploads.length,
      uploaded: 0,
    );
  }

  final items = extractItems(presignRes.jsonBody) ?? const [];
  final storageKeys = <String>[];

  for (final item in items) {
    if (item is! Map) continue;

    final index = int.tryParse(
      (item['clientUploadId']?.toString() ?? '').replaceAll('upload_', ''),
    );
    final uploadUrl = item['uploadUrl']?.toString();
    final storageKey = item['storageKey']?.toString();
    if (index == null ||
        index < 0 ||
        index >= uploads.length ||
        uploadUrl == null ||
        storageKey == null) {
      continue;
    }

    final upload = uploads[index];
    // `requiredHeaders` viene del presign y hay que reenviarlo tal cual: si la
    // firma incluyó un header y el PUT no lo manda, S3 rechaza la subida.
    final headers = <String, String>{'Content-Type': upload.mimeType};
    final required = item['requiredHeaders'];
    if (required is Map) {
      required.forEach((key, value) {
        if (key is String && value != null) headers[key] = value.toString();
      });
    }

    try {
      final putRes = await putPresigned(
        Uri.parse(uploadUrl),
        headers: headers,
        body: upload.bytes,
      );
      if (putRes.statusCode >= 200 && putRes.statusCode < 300) {
        storageKeys.add(storageKey);
      }
    } catch (_) {
      // Imagen perdida, tanda viva: se refleja en `isPartial`.
    }
  }

  if (storageKeys.isEmpty) {
    return DoviaHomeUploadResult(
      confirmedUrls: const [],
      requested: uploads.length,
      uploaded: 0,
    );
  }

  final confirmRes = await confirm(storageKeys);
  if (!confirmRes.succeeded) {
    return DoviaHomeUploadResult(
      confirmedUrls: const [],
      requested: uploads.length,
      uploaded: 0,
    );
  }

  final urls = extractUrls?.call(confirmRes.jsonBody) ?? const [];
  return DoviaHomeUploadResult(
    confirmedUrls: urls
        .map((e) => e?.toString())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList(),
    requested: uploads.length,
    uploaded: storageKeys.length,
  );
}
