import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frs/src/features/common/widgets/app_progress_indicator.dart';
import 'package:frs/src/features/common/widgets/connection_error_widget.dart';
import 'package:frs/src/features/common/widgets/binary_headed_scroll_view.dart';
import 'package:frs/src/features/common/widgets/responsive_safe_area.dart';
import 'package:frs/src/features/common/widgets/show_hide_widget.dart';
import 'package:frs/src/features/home/data/models/session.dart';
import 'package:frs/src/features/session/data/models/session_record.dart';
import 'package:frs/src/features/session/widgets/session_appbar.dart';
import 'package:frs/src/features/session/widgets/session_record_widget.dart';
import 'package:frs/src/core/meta/app_colors.dart';
import 'package:frs/src/core/utils/export_excel.dart';
import 'package:frs/src/core/utils/trier.dart';

class SessionScreen extends StatefulWidget {
  final Session session;

  const SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _recordsStream;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _streamSubscription;

  final ValueNotifier<QuerySnapshot<Map<String, dynamic>>?> recordsNotifier =
      ValueNotifier(null);

  List<SessionRecord>? lastRecords;

  @override
  void initState() {
    super.initState();

    _recordsStream = FirebaseFirestore.instance
        .collection('records')
        .where('session_id', isEqualTo: widget.session.id)
        .snapshots();

    _streamSubscription = _recordsStream.listen((event) {
      recordsNotifier.value = event;
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    recordsNotifier.dispose();
    super.dispose();
  }

  List<SessionRecord>? get currentRecords {
    final snapshot = recordsNotifier.value;

    return distinctFingerSessionsFromDocs(docs: snapshot?.docs);
  }

  static List<SessionRecord>? distinctFingerSessionsFromDocs({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs,
  }) {
    if (docs == null) return null;

    final sessions =
        docs
            .map(
              (e) => Trier(
                () => SessionRecord.fromFirebaseMap({...e.data(), 'id': e.id}),
              ).invoke,
            )
            .whereType<SessionRecord>()
            .toList()
          ..sort((a, b) {
            final aDate = a.createdAt;
            final bDate = b.createdAt;

            if (aDate == null) return 1;
            if (bDate == null) return -1;

            return bDate.compareTo(aDate);
          });

    final seenFingerIds = <int>{};

    sessions.removeWhere((e) => !seenFingerIds.add(e.fingerprintId));

    return sessions;
  }

  void onExport() async {
    final records = currentRecords;

    if (records == null) return;

    ExportExcel.exportAndShareRecords(
      sessionName: widget.session.name,
      records: records,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double minHeight = 75;
    const double maxHeight = 275;

    final appbar = SessionAppbar(
      minHeight: minHeight,
      maxHeight: maxHeight,
      title: widget.session.name,
      onExport: onExport,
    );

    return Scaffold(
      backgroundColor: AppColors.contrastBg,
      body: ResponsiveSafeArea(
        child: ColoredBox(
          color: AppColors.bg,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _recordsStream,
            builder: (context, snapshot) {
              final records = distinctFingerSessionsFromDocs(
                docs: snapshot.data?.docs,
              );

              final preRecords = lastRecords;
              lastRecords = records;

              return BinaryHeadedScrollView(
                maxHeight: maxHeight,
                minHeight: minHeight,
                header: appbar,
                child: _buildListView(
                  hasError: snapshot.hasError,
                  error: '${snapshot.error}',
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting,
                  records: records,
                  preRecords: preRecords,
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
    required List<SessionRecord>? preRecords,
    required List<SessionRecord>? records,
  }) {
    if (isLoading) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(40),
          child: AppProgressIndicator(),
        ),
      );
    }

    if (hasError) {
      return const ConnectionErrorWidget();
    }

    if (records == null) {
      return const ConnectionErrorWidget();
    }

    Widget builder(int index) {
      final record = records[index];
      final preIndex = preRecords?.indexOf(record);
      final preRecord = (preIndex == null || preIndex < 0)
          ? null
          : preRecords?.elementAtOrNull(preIndex);
      final preExists = preRecord != null;
      final edited = preRecord?.isIdentical(record) == false;

      return ShowHideWidget(
        isUpdated: edited,
        isVisible: true,
        wasPresent: preExists,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: SessionRecordWidget(record: record),
        ),
      );
    }

    if (records.length < 15) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(records.length, builder),
        ),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, index) => builder(index),
    );
  }
}
