import 'package:frs/src/core/routing/custom_pages/bottom_sheet_page.dart';
import 'package:frs/src/features/common/widgets/responsive_zoom.dart';
import 'package:frs/src/features/create_session/view/create_session_sheet.dart';
import 'package:frs/src/features/edit_record/view/edit_record_sheet.dart';
import 'package:frs/src/features/home/view/home_screen.dart';
import 'package:frs/src/features/session/view/session_screen.dart';
import 'package:frs/src/features/splash/view/splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String splash = "/splash";
  static const String home = "/home";
  static const String session = "/session";
  static const String createSession = "/create_session";
  static const String editRecord = "/edit_record";

  static final routerConfig = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) =>
            const ResponsiveZoom(child: SplashScreen()),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const ResponsiveZoom(child: HomeScreen()),
      ),
      GoRoute(
        path: session,
        builder: (context, state) => ResponsiveZoom(
          child: SessionScreen(session: (state.extra as Map)["session"]),
        ),
      ),
      GoRoute(
        path: createSession,
        pageBuilder: (context, state) => const BottomSheetPage(
          child: ResponsiveZoom(child: CreateSessionSheet()),
        ),
      ),
      GoRoute(
        path: editRecord,
        pageBuilder: (context, state) => BottomSheetPage(
          child: ResponsiveZoom(
            child: EditRecordSheet(record: (state.extra as Map)["record"]),
          ),
        ),
      ),
    ],
  );
}
