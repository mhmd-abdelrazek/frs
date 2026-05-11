import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/features/common/widgets/app_progress_indicator.dart';
import 'package:frs/src/features/common/widgets/show_hide_widget.dart';
import 'package:frs/src/features/home/data/models/session.dart';
import 'package:frs/src/features/common/widgets/connection_error_widget.dart';
import 'package:frs/src/features/common/widgets/binary_headed_scroll_view.dart';
import 'package:frs/src/features/common/widgets/responsive_safe_area.dart';
import 'package:frs/src/features/home/widgets/home_appbar.dart';
import 'package:frs/src/features/home/widgets/session_widget.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/utils/trier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Session>? lastSessions;

  @override
  Widget build(BuildContext context) {
    const double minHeight = 75.0;
    const double maxHeight = 275.0;

    final appbar = const HomeAppbar(minHeight: minHeight, maxHeight: maxHeight);

    return Scaffold(
      backgroundColor: AppColors.contrastBg,
      body: ResponsiveSafeArea(
        child: ColoredBox(
          color: AppColors.bg,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("sessions")
                .snapshots(),
            builder: (context, snapshot) {
              final sessions = snapshot.data?.docs
                  .map(
                    (e) => Trier(
                      () => Session.fromFirebaseMap({...e.data(), "id": e.id}),
                    ).invoke,
                  )
                  .whereType<Session>()
                  .toList();
              sessions?.sort((a, b) {
                final aDate = a.createdAt;
                final bDate = b.createdAt;

                if (aDate == null) return 1;
                if (bDate == null) return -1;

                return bDate.compareTo(aDate);
              });
              final preSessions = lastSessions;
              lastSessions = sessions;

              return BinaryHeadedScrollView(
                maxHeight: maxHeight,
                minHeight: minHeight,
                header: appbar,
                child: _buildListView(
                  hasError: snapshot.hasError,
                  error: "${snapshot.error}",
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                  sessions: sessions,
                  preSessions: preSessions,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListView({
    required bool hasError,
    required String error,
    required bool isLoading,
    required List<Session>? preSessions,
    required List<Session>? sessions,
  }) {
    if (isLoading) {
      return const Align(
        alignment: .topCenter,
        child: Padding(
          padding: EdgeInsetsGeometry.all(40),
          child: AppProgressIndicator(),
        ),
      );
    }

    if (sessions == null) return const ConnectionErrorWidget();

    Widget builder(int index) {
      final session = sessions[index];
      final preIndex = preSessions?.indexOf(session);
      final preSession = (preIndex == null || preIndex < 0)
          ? null
          : preSessions?.elementAtOrNull(preIndex);
      final preExists = preSession != null;
      final edited = preSession?.isIdentical(session) == false;

      return ShowHideWidget(
        isUpdated: edited,
        isVisible: true,
        wasPresent: preExists,

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SessionWidget(session: sessions[index]),
        ),
      );
    }

    if (sessions.length < 15) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: .start,
          children: List.generate(sessions.length, builder),
        ),
      );
    }

    // for bigger length return [ListView.builder] to be parsable
    // in [CoreBinaryHeadedScrollView]
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      itemCount: sessions.length,
      itemBuilder: (_, index) => builder(index),
    );
  }
}
