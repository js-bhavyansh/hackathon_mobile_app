import 'package:booking_slot_app/data/models/slot_model.dart';
import 'package:booking_slot_app/data/models/venue_model.dart';
import 'package:booking_slot_app/data/services/api/api_client.dart';
import 'package:dio/dio.dart';

// Calls GET /venues and GET /venues/:id/slots?date=
class VenueService {
  final Dio _dio = ApiClient.client;

  Future<List<VenueModel>> getVenues() async {
    final res = await _dio.get('/venues');
    final List data = (res.data as Map<String, dynamic>)['data'] as List;
    return data.map((e) => VenueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SlotModel>> getSlots(String venueId, String date) async {
    final res = await _dio.get('/venues/$venueId/slots', queryParameters: {'date': date});
    final List data = (res.data as Map<String, dynamic>)['data'] as List;
    return data.map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
