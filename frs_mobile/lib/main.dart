import 'package:flutter/material.dart';
import 'package:frs/the_app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final PackageInfo packageInfo;
late final SharedPreferences preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// The project is too small to use Injection
  /// So I will prefer to be lazy this time:))
  packageInfo = await PackageInfo.fromPlatform();
  // preferences = await SharedPreferences.getInstance();

  /// Initialize Firebase App inside Splash Screen

  runApp(const TheApp());
}
