import 'package:cloud_firestore/cloud_firestore.dart';

class ParsingUtils {
  static DateTime? parseAsDateTime(dynamic value) {
    if (value == null) return null;

    try {
      // Firestore Timestamp
      if (value is Timestamp) {
        return value.toDate();
      }

      // int (milliseconds or seconds)
      if (value is int) {
        return _fromEpoch(value);
      }

      // double (milliseconds or seconds)
      if (value is double) {
        return _fromEpoch(value.toInt());
      }

      // String (ISO 8601 or other parseable formats)
      if (value is String) {
        return DateTime.tryParse(value);
      }
    } catch (_) {
      // swallow errors safely
    }

    return null;
  }

  /// Detects if epoch is in seconds or milliseconds
  static DateTime _fromEpoch(int value) {
    // auto-detect (seconds are usually 10 digits)
    if (value.toString().length <= 10) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }

    return DateTime.fromMillisecondsSinceEpoch(value);
  }
}
