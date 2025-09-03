import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable edge-to-edge so content draws behind system bars with transparency
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Make bars transparent; choose icon brightness for good contrast
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark, // for iOS
    statusBarIconBrightness: Brightness.light, // for Android
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const DocDocApp());
}
