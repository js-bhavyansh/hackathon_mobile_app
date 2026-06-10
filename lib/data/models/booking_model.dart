import 'package:booking_slot_app/data/models/slot_model.dart';
import 'package:booking_slot_app/data/models/venue_model.dart';
import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String id;
  final String slotId;
  final String userId;
  final String bookedAt;
  final String status; // 'confirmed' | 'cancelled'
  final SlotModel? slot;
  final VenueModel? venue;

  const BookingModel({
    required this.id,
    required this.slotId,
    required this.userId,
    required this.bookedAt,
    required this.status,
    this.slot,
    this.venue,
  });

  bool get isConfirmed => status == 'confirmed';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Backend returns nested: slots → venues
    final slotJson = json['slots'] as Map<String, dynamic>?;
    final venueJson = slotJson?['venues'] as Map<String, dynamic>?;

    SlotModel? slot;
    VenueModel? venue;

    if (slotJson != null) {
      slot = SlotModel.fromJson({
        ...slotJson,
        'venue_id': venueJson?['id'] ?? '',
      });
    }
    if (venueJson != null) {
      venue = VenueModel.fromJson(venueJson);
    }

    return BookingModel(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      userId: json['user_id'] as String,
      bookedAt: json['booked_at'] as String,
      status: json['status'] as String,
      slot: slot,
      venue: venue,
    );
  }

  @override
  List<Object?> get props => [id, slotId, userId, bookedAt, status];
}
