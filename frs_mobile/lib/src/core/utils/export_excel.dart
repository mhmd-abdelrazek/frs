import 'dart:io';

import 'package:excel/excel.dart';
import 'package:frs/src/features/session/data/models/session_record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportExcel {
  static Future<void> exportAndShareRecords({
    required String sessionName,
    required List<SessionRecord> records,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Header
    sheet.appendRow([
      TextCellValue('National ID'),
      TextCellValue('name'),
      TextCellValue('Time'),
      TextCellValue('Year'),
      TextCellValue('Month'),
      TextCellValue('Day'),
    ]);

    // Rows
    for (final record in records) {
      sheet.appendRow([
        TextCellValue(record.nationalId ?? ""),
        TextCellValue(record.name),
        TextCellValue(
          record.createdAt == null
              ? ""
              : "${record.createdAt!.hour}:${record.createdAt!.minute}",
        ),
        TextCellValue((record.createdAt?.year ?? 0).toString()),
        TextCellValue((record.createdAt?.month ?? 0).toString()),
        TextCellValue((record.createdAt?.day ?? 0).toString()),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${Uri.encodeComponent(sessionName)}.xlsx');

    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Excel Report'),
    );
  }
}
