import 'package:equatable/equatable.dart';

/// A half‑open interval **[start, end)** using local `DateTime`s.
///
/// - `start` *must* be strictly before `end`.
///
/// - All comparisons are done with `DateTime.isBefore / isAfter`,
///   so milliseconds are honoured.
///
class TimeSlot extends Equatable {
  final String? id;
  final String? name;
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end, this.id, this.name})
    : assert(start.isBefore(end), '`start` must be before `end`.');

  /// Convenience check (mostly redundant thanks to the assert).
  bool get isValid => start.isBefore(end);

  /// Encode as JSON‑friendly map (using ISO‑8601 strings).
  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'id': id,
    'name': name,
  };

  /// Re‑hydrate from the map produced by [toJson].
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final startRaw = json['start'];
    final endRaw = json['end'];

    if (startRaw is! String || endRaw is! String) {
      throw ArgumentError(
        '"start" and "end" must be ISO‑8601 strings in the JSON map.',
      );
    }

    final startDt = DateTime.parse(startRaw);
    final endDt = DateTime.parse(endRaw);

    if (!startDt.isBefore(endDt)) {
      throw ArgumentError('`start` must be before `end`.');
    }

    return TimeSlot(start: startDt, end: endDt, id: id, name: name);
  }

  /// Returns `true` when the two intervals share **any** instant in time.
  bool overlaps(TimeSlot other) =>
      start.isBefore(other.end) && end.isAfter(other.start);

  @override
  List<Object?> get props => [id, name, start, end];

  @override
  bool get stringify => true;
}
