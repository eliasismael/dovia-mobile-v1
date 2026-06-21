import 'package:flutter/material.dart';
import 'recorrido_360_view_stub.dart'
    if (dart.library.html) 'recorrido_360_view_web.dart'
    if (dart.library.io) 'recorrido_360_view_mobile.dart';

Widget getRecorrido360View(String url) => Recorrido360View(url: url);
