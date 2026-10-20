import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/uploaded_file.dart';

/// Levantamiento de una solicitud de Dovia Home (categoría, descripción y
/// fotos) que el cliente todavía no envió.
class ServiceRequestDraft {
  const ServiceRequestDraft({
    required this.serviceTitle,
    required this.categoryId,
    required this.description,
    required this.photos,
  });

  final String serviceTitle;
  final String? categoryId;
  final String description;
  final List<FFUploadedFile> photos;
}

/// Guarda en disco el levantamiento mientras el cliente lo completa.
///
/// El formulario viaja entre pantallas en campos estáticos, que se pierden si
/// Android o iOS cierran la app en segundo plano (pasa seguido al abrir la
/// cámara). Con esto, al volver a entrar al mismo servicio se recupera lo que
/// había cargado.
///
/// Hay un solo borrador por usuario: empezar otro servicio lo reemplaza. El
/// texto va a las preferencias y las fotos a archivos en el directorio de la
/// app, porque los bytes no caben bien en las preferencias.
class ServiceRequestDraftStore {
  ServiceRequestDraftStore._();

  /// Un borrador más viejo que esto ya no se ofrece.
  static const maxAge = Duration(days: 7);

  /// Las operaciones se encadenan: dos guardados seguidos (Ej: tipear y
  /// agregar una foto) no se pisan a mitad de escribir los archivos.
  static Future<void> _queue = Future.value();

  static Future<T> _enqueue<T>(Future<T> Function() op) {
    final result = _queue.then((_) => op());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Carpeta del usuario conectado. Se toma al llamar a [save], [load] o
  /// [clear], no cuando la operación corre en la cola: si entretanto cambió
  /// la cuenta, el borrador de A terminaba guardado bajo B.
  static String get _userSegment {
    final uid = currentUserUid;
    return uid.isEmpty ? 'anon' : uid.replaceAll(RegExp(r'[^\w-]'), '_');
  }

  static String _prefsKey(String user) => 'dh_service_request_draft_$user';

  static Future<Directory?> _photosDir(String user) async {
    if (kIsWeb) return null;
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/service_request_draft/$user');
  }

  /// Guarda el borrador. [photos] en null conserva las fotos ya guardadas
  /// (cuando sólo cambió el texto no hace falta reescribirlas).
  static Future<void> save({
    required String serviceTitle,
    required String? categoryId,
    required String description,
    List<FFUploadedFile>? photos,
  }) {
    final user = _userSegment;
    return _enqueue(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final previous = _decode(prefs.getString(_prefsKey(user)));
        final sameService = previous?['serviceTitle'] == serviceTitle;

        List<dynamic> photoEntries;
        if (photos != null) {
          photoEntries = await _writePhotos(user, photos);
        } else if (sameService) {
          photoEntries = previous?['photos'] as List? ?? const [];
        } else {
          photoEntries = await _writePhotos(user, const []);
        }

        await prefs.setString(
          _prefsKey(user),
          jsonEncode({
            'serviceTitle': serviceTitle,
            'categoryId': categoryId,
            'description': description,
            'photos': photoEntries,
            'savedAt': DateTime.now().millisecondsSinceEpoch,
          }),
        );
      } catch (e) {
        debugPrint('[Borrador] No se pudo guardar: $e');
      }
    });
  }

  /// El borrador del servicio [serviceTitle], o null si no hay, es de otro
  /// servicio o ya venció.
  static Future<ServiceRequestDraft?> load(String serviceTitle) {
    final user = _userSegment;
    return _enqueue(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final json = _decode(prefs.getString(_prefsKey(user)));
        if (json == null || json['serviceTitle'] != serviceTitle) {
          return null;
        }
        final savedAt = DateTime.fromMillisecondsSinceEpoch(
            (json['savedAt'] as num?)?.toInt() ?? 0);
        if (DateTime.now().difference(savedAt) > maxAge) return null;

        return ServiceRequestDraft(
          serviceTitle: serviceTitle,
          categoryId: json['categoryId'] as String?,
          description: json['description'] as String? ?? '',
          photos: await _readPhotos(user, json['photos'] as List? ?? const []),
        );
      } catch (e) {
        debugPrint('[Borrador] No se pudo leer: $e');
        return null;
      }
    });
  }

  /// Descarta el borrador (al enviar la solicitud o si el cliente lo pide).
  static Future<void> clear() {
    final user = _userSegment;
    return _enqueue(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefsKey(user));
        final dir = await _photosDir(user);
        if (dir != null && await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (e) {
        debugPrint('[Borrador] No se pudo borrar: $e');
      }
    });
  }

  static Map<String, dynamic>? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }

  /// Reemplaza las fotos guardadas por [photos] y devuelve cómo encontrarlas.
  static Future<List<Map<String, dynamic>>> _writePhotos(
      String user, List<FFUploadedFile> photos) async {
    final dir = await _photosDir(user);
    if (dir == null) return const [];
    if (await dir.exists()) await dir.delete(recursive: true);
    if (photos.isEmpty) return const [];
    await dir.create(recursive: true);

    final entries = <Map<String, dynamic>>[];
    for (var i = 0; i < photos.length; i++) {
      final bytes = photos[i].bytes;
      if (bytes == null) continue;
      final file = '$i.img';
      await File('${dir.path}/$file').writeAsBytes(bytes, flush: true);
      entries.add({
        'file': file,
        'name': photos[i].name,
        'originalFilename': photos[i].originalFilename,
        'width': photos[i].width,
        'height': photos[i].height,
      });
    }
    return entries;
  }

  static Future<List<FFUploadedFile>> _readPhotos(
      String user, List<dynamic> entries) async {
    final dir = await _photosDir(user);
    if (dir == null) return const [];

    final photos = <FFUploadedFile>[];
    for (final entry in entries.whereType<Map>()) {
      final file = File('${dir.path}/${entry['file']}');
      if (!await file.exists()) continue;
      photos.add(FFUploadedFile(
        name: entry['name'] as String?,
        originalFilename: entry['originalFilename'] as String? ?? '',
        bytes: await file.readAsBytes(),
        width: (entry['width'] as num?)?.toDouble(),
        height: (entry['height'] as num?)?.toDouble(),
      ));
    }
    return photos;
  }
}
