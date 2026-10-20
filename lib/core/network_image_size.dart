import 'dart:math' as math;
import 'dart:ui' show FlutterView;

import 'package:flutter/widgets.dart';

/// Ancho en píxeles al que conviene decodificar una foto de internet que se
/// muestra en una caja de [width] × [height] (en puntos lógicos).
///
/// Sin esto cada foto se decodifica en su resolución original: una foto de
/// 4000 px en una tarjeta de 200 ocupa ~48 MB de memoria y en celulares
/// viejos traba el scroll o cierra la app. Se pasa como `cacheWidth` de
/// `Image.network` (o `memCacheWidth` de `CachedNetworkImage`); al dar solo
/// el ancho se conserva la proporción de la foto.
///
/// Se toma el lado mayor de la caja para que con `BoxFit.cover` alcance
/// aunque la caja sea más alta que ancha. Un lado infinito o desconocido
/// cuenta como el ancho de la pantalla, y nada pasa del lado mayor de la
/// pantalla. No usa `BuildContext`: sirve también en helpers sin contexto.
int networkImageCacheWidth({double? width, double? height}) {
  final view = _view();
  final dpr = view?.devicePixelRatio ?? 3.0;
  // Sin vista o antes del primer frame (tamaño 0) se asume un teléfono
  // grande, para no decodificar de menos.
  final measured =
      view == null ? Size.zero : view.physicalSize / view.devicePixelRatio;
  final screen = measured.isEmpty ? const Size(430.0, 932.0) : measured;

  double? valid(double? v) => v != null && v.isFinite && v > 0 ? v : null;
  final logical = math.max(valid(width) ?? screen.width, valid(height) ?? 0.0);
  final capped = math.min(logical, screen.longestSide);
  return math.max(1, (capped * dpr).ceil());
}

FlutterView? _view() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  return views.isEmpty ? null : views.first;
}
