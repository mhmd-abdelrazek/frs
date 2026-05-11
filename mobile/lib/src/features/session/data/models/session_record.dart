import 'package:equatable/equatable.dart';
import 'package:frs/src/core/utils/parsing_utils.dart';

class SessionRecord extends Equatable {
  final String id;
  final String sessionId;
  final int fingerprintId;
  final String name;
  final String? nationalId;
  final DateTime? createdAt;

  const SessionRecord({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.fingerprintId,
    required this.nationalId,
    required this.createdAt,
  });

  bool isIdentical(SessionRecord record) {
    return id == record.id &&
        sessionId == record.sessionId &&
        fingerprintId == record.fingerprintId &&
        name == record.name &&
        nationalId == record.nationalId &&
        createdAt == record.createdAt;
  }

  factory SessionRecord.fromFirebaseMap(Map map) {
    final nationalId = map["national_id"] as String?;

    return SessionRecord(
      id: map["id"],
      sessionId: map["session_id"],
      name: map["name"] ?? "Unknown",
      createdAt: ParsingUtils.parseAsDateTime(map["time"]),
      fingerprintId: int.tryParse("${map["fingerprint_id"]}") ?? -1,
      nationalId: nationalId?.isNotEmpty == true ? nationalId : null,
    );
  }

  @override
  List<Object?> get props => [id];
}
