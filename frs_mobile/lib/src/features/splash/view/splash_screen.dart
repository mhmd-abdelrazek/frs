import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frs/firebase_options.dart';
import 'package:frs/main.dart';
import 'package:frs/src/features/splash/widgets/splash_animated_icon.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/meta/text_styles.dart';
import 'package:frs/src/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialize().then((_) {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    });
  }

  Future<void> initialize() async {
    final minDuration = const Duration(seconds: 4);
    final clock = Stopwatch();

    clock.start();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    clock.stop();

    final restDuration = minDuration - clock.elapsed;

    if (!restDuration.isNegative) {
      await Future.delayed(restDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(flex: 3),
            const SplashAnimatedIcon(),
            const Spacer(flex: 5),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: "POWERED BY ", style: TextStyles.ssiiText2400),
                TextSpan(text: "TechSoft", style: TextStyles.ssiiPrimary600),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Version ${packageInfo.version} (Build ${packageInfo.buildNumber})",
            style: TextStyles.ssText2300,
          ),
        ],
      ),
    );
  }
}
