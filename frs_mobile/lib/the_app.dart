import 'package:flutter/material.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/routing/app_routes.dart';

class TheApp extends StatelessWidget {
  const TheApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      routerConfig: AppRoutes.routerConfig,
      title: 'FRS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Quicksand",
        colorScheme: .fromSeed(seedColor: AppColors.primary),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
