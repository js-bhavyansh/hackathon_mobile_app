import 'package:equatable/equatable.dart';

class SlotModel extends Equatable {
  final String id;
  final String venueId;
  final String date;
  final String startTime;
  final String endTime;
  final String status; // 'available' | 'booked'

  const SlotModel({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  bool get isAvailable => status == 'available';

  // Format "06:00:00" → "6:00 AM"
  String get formattedTime {
    final parts = startTime.split(':');
    final hour = int.parse(parts[0]);
    final suffix = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:00 $suffix';
  }

  // venueId and date are injected from the call site — not returned by the API
  factory SlotModel.fromJson(Map<String, dynamic> json, {String venueId = '', String date = ''}) => SlotModel(
        id: json['id'] as String,
        venueId: json['venue_id'] as String? ?? venueId,
        date: json['date'] as String? ?? date,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        status: json['status'] as String? ?? 'booked',
      );

  SlotModel copyWith({String? status}) => SlotModel(
        id: id,
        venueId: venueId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [id, venueId, date, startTime, endTime, status];
}
