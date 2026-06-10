import 'package:booking_slot_app/bloc/venue/venue_state.dart';
import 'package:booking_slot_app/data/models/venue_model.dart';
import 'package:booking_slot_app/data/services/api/venue_service.dart';
import 'package:booking_slot_app/utils/api_error_handler.dart';
import 'package:booking_slot_app/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Loads venue list (with sport filter) and slots for a given venue+date
class VenueCubit extends Cubit<VenueState> {
  final VenueService _venueService;
  List<VenueModel> _allVenues = [];

  VenueCubit(this._venueService) : super(VenueInitial());

  Future<void> loadVenues() async {
    emit(VenueLoading());
    try {
      _allVenues = await _venueService.getVenues();
      emit(VenueListLoaded(_allVenues));
    } catch (e) {
      Log.e('loadVenues: $e');
      emit(VenueError(ApiErrorHandler.message(e)));
    }
  }

  void filterVenues(String filter) {
    if (_allVenues.isEmpty) return;
    final filtered = filter == 'all'
        ? _allVenues
        : _allVenues.where((v) => v.sportType.toLowerCase() == filter).toList();
    emit(VenueListLoaded(filtered, filter: filter));
  }

  Future<void> loadSlots(String venueId, String date) async {
    emit(VenueLoading());
    try {
      final slots = await _venueService.getSlots(venueId, date);
      emit(SlotsLoaded(slots, date));
    } catch (e) {
      Log.e('loadSlots: $e');
      emit(VenueError(ApiErrorHandler.message(e)));
    }
  }
}
