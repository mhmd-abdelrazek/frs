import 'package:equatable/equatable.dart';
import 'package:frs/src/core/utils/parsing_utils.dart';

class Session extends Equatable {
  final String id;
  final String name;
  final DateTime? createdAt;

  const Session({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  bool isIdentical(Session session) {
    return id == session.id &&
        name == session.name &&
        createdAt == session.createdAt;
  }

  factory Session.fromFirebaseMap(Map map) {
    return Session(
      id: map["id"],
      name: map["name"] ?? "Unknown",
      createdAt: ParsingUtils.parseAsDateTime(map["start_time"]),
    );
  }

  @override
  List<Object?> get props => [id];
}
