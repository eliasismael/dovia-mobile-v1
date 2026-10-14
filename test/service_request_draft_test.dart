import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dovia/auth/custom_auth/auth_util.dart';
import 'package:dovia/dovia_home_client/service_request_draft.dart';
import 'package:dovia/flutter_flow/uploaded_file.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.dir);
  final Directory dir;

  @override
  Future<String?> getApplicationSupportPath() async => dir.path;
}

FFUploadedFile _photo(int byte) => FFUploadedFile(
      name: 'foto_$byte.jpg',
      bytes: Uint8List.fromList([byte, byte, byte]),
      width: 10,
      height: 20,
    );

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('draft_test');
    PathProviderPlatform.instance = _FakePathProvider(tmp);
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await authManager.initialize();
    await authManager.signIn(authenticationToken: 't', authUid: 'user-1');
  });

  tearDown(() async {
    await ServiceRequestDraftStore.clear();
    await tmp.delete(recursive: true);
  });

  test('recupera descripción, categoría y fotos del mismo servicio', () async {
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Plomería',
      categoryId: 'cat-1',
      description: 'Pierde la canilla',
      photos: [_photo(1), _photo(2)],
    );

    final draft = await ServiceRequestDraftStore.load('Plomería');
    expect(draft, isNotNull);
    expect(draft!.categoryId, 'cat-1');
    expect(draft.description, 'Pierde la canilla');
    expect(draft.photos.map((p) => p.bytes!.first), [1, 2]);
    expect(draft.photos.first.name, 'foto_1.jpg');
    expect(draft.photos.first.height, 20);
  });

  test('cambiar solo el texto conserva las fotos guardadas', () async {
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Plomería',
      categoryId: null,
      description: 'a',
      photos: [_photo(7)],
    );
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Plomería',
      categoryId: null,
      description: 'ab',
    );

    final draft = await ServiceRequestDraftStore.load('Plomería');
    expect(draft!.description, 'ab');
    expect(draft.photos, hasLength(1));
  });

  test('no se ofrece en otro servicio, ni a otro usuario', () async {
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Plomería',
      categoryId: null,
      description: 'x',
      photos: [_photo(1)],
    );
    expect(await ServiceRequestDraftStore.load('Electricidad'), isNull);

    await authManager.signOut();
    await authManager.signIn(authenticationToken: 't', authUid: 'user-2');
    expect(await ServiceRequestDraftStore.load('Plomería'), isNull);
  });

  test('otro servicio sin fotos nuevas no hereda las del anterior', () async {
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Plomería',
      categoryId: null,
      description: 'x',
      photos: [_photo(1)],
    );
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Electricidad',
      categoryId: null,
      description: 'y',
    );
    expect((await ServiceRequestDraftStore.load('Electricidad'))!.photos,
        isEmpty);
  });

  test('un borrador vencido no se ofrece', () async {
    final old = DateTime.now()
        .subtract(ServiceRequestDraftStore.maxAge + const Duration(hours: 1));
    SharedPreferences.setMockInitialValues({
      'dh_service_request_draft_user-1':
          '{"serviceTitle":"Plomería","description":"x","photos":[],'
              '"savedAt":${old.millisecondsSinceEpoch}}',
    });
    expect(await ServiceRequestDraftStore.load('Plomería'), isNull);
  });

  test('clear borra el texto y las fotos', () async {
    await ServiceRequestDraftStore.save(
      serviceTitle: 'Plomería',
      categoryId: null,
      description: 'x',
      photos: [_photo(1)],
    );
    await ServiceRequestDraftStore.clear();
    expect(await ServiceRequestDraftStore.load('Plomería'), isNull);
    expect(
        Directory('${tmp.path}/service_request_draft/user-1').existsSync(),
        isFalse);
  });
}
