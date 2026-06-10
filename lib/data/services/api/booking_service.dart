import 'package:booking_slot_app/data/models/booking_model.dart';
import 'package:booking_slot_app/data/services/api/api_client.dart';
import 'package:dio/dio.dart';

// Calls POST /bookings, GET /bookings/my-bookings, DELETE /bookings/:id
class BookingService {
  final Dio _dio = ApiClient.client;

  Future<String> bookSlot(String slotId) async {
    final res = await _dio.post('/bookings', data: {'slot_id': slotId});
    return res.data['booking_id'] as String;
  }

  Future<List<BookingModel>> getMyBookings() async {
    final res = await _dio.get('/bookings/my-bookings');
    final List data = res.data as List;
    return data.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _dio.delete('/bookings/$bookingId');
  }
}
