import 'package:flutter/material.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/domain/offer_json.dart' show firstPropertyPhotoUrl;
import '/flutter_flow/flutter_flow_util.dart';

/// Portada de una carpeta de favoritos: las fotos de las primeras casas que
/// tiene (hasta 4). Con 1 casa ocupa todo; con 2, una arriba de la otra; con 3, una
/// grande a la izquierda y dos apiladas; con 4, una grilla de 2x2.
class FavoriteFolderCollageWidget extends StatefulWidget {
  const FavoriteFolderCollageWidget({super.key, required this.folderId});

  final String folderId;

  /// Avisa a las portadas visibles que el contenido de alguna carpeta cambió
  /// (se agregó o sacó una casa), para que vuelvan a cargar sus fotos.
  static final ValueNotifier<int> changes = ValueNotifier(0);
  static void invalidate() => changes.value++;

  @override
  State<FavoriteFolderCollageWidget> createState() =>
      _FavoriteFolderCollageWidgetState();
}

class _FavoriteFolderCollageWidgetState
    extends State<FavoriteFolderCollageWidget> {
  late Future<List<String>> _photos = _load();

  @override
  void initState() {
    super.initState();
    FavoriteFolderCollageWidget.changes.addListener(_reload);
  }

  @override
  void dispose() {
    FavoriteFolderCollageWidget.changes.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (mounted) setState(() => _photos = _load());
  }

  @override
  void didUpdateWidget(FavoriteFolderCollageWidget old) {
    super.didUpdateWidget(old);
    if (old.folderId != widget.folderId) _photos = _load();
  }

  Future<List<String>> _load() async {
    final res =
        await DOVIAAPIFavoriteContextGroup.getFavoritesInFolderCall.call(
      folderId: widget.folderId,
      page: '1',
      limit: '4',
      authToken: currentAuthenticationToken,
    );
    final list = getJsonField(res.jsonBody, r'''$.data.favorites''');
    if (list is! List) return const [];
    final urls = <String>[];
    for (final item in list) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final nested = map['property'];
      final url = firstPropertyPhotoUrl(map) ??
          (nested is Map
              ? firstPropertyPhotoUrl(Map<String, dynamic>.from(nested))
              : null);
      if (url != null && url.isNotEmpty) urls.add(url);
      if (urls.length == 4) break;
    }
    return urls;
  }

  Widget _photo(String url) => Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE9EFF2)),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _photos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(color: const Color(0xFFF1F4F5));
        }
        final p = snapshot.data!;
        const gap = SizedBox(width: 2, height: 2);
        switch (p.length) {
          case 0:
            return Container(
              color: const Color(0xFFE9EFF2),
              alignment: Alignment.center,
              child: const Icon(Icons.folder_outlined,
                  size: 40, color: Color(0xFF7FA9AA)),
            );
          case 1:
            return _photo(p[0]);
          case 2:
            return Column(children: [
              Expanded(child: _photo(p[0])),
              gap,
              Expanded(child: _photo(p[1])),
            ]);
          case 3:
            return Row(children: [
              Expanded(child: _photo(p[0])),
              gap,
              Expanded(
                child: Column(children: [
                  Expanded(child: _photo(p[1])),
                  gap,
                  Expanded(child: _photo(p[2])),
                ]),
              ),
            ]);
          default:
            return Column(children: [
              Expanded(
                child: Row(children: [
                  Expanded(child: _photo(p[0])),
                  gap,
                  Expanded(child: _photo(p[1])),
                ]),
              ),
              gap,
              Expanded(
                child: Row(children: [
                  Expanded(child: _photo(p[2])),
                  gap,
                  Expanded(child: _photo(p[3])),
                ]),
              ),
            ]);
        }
      },
    );
  }
}
