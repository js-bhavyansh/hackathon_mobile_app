import 'package:booking_slot_app/bloc/booking/booking_state.dart';
import 'package:booking_slot_app/data/services/api/api_error_handler.dart';
import 'package:booking_slot_app/data/services/api/booking_service.dart';
import 'package:booking_slot_app/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Handles book slot, fetch my-bookings, and cancel booking
class BookingCubit extends Cubit<BookingState> {
  final BookingService _bookingService;

  BookingCubit(this._bookingService) : super(BookingInitial());

  Future<void> bookSlot(String slotId) async {
    emit(BookingLoading());
    try {
      final bookingId = await _bookingService.bookSlot(slotId);
      emit(BookingSuccess(bookingId));
    } catch (e) {
      Log.e('bookSlot: $e');
      final msg = ApiErrorHandler.parse(e);
      // 409 means slot already taken
      emit(BookingError(msg));
    }
  }

  Future<void> loadMyBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await _bookingService.getMyBookings();
      emit(BookingListLoaded(bookings));
    } catch (e) {
      Log.e('loadMyBookings: $e');
      emit(const BookingError('Failed to load bookings.'));
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    emit(BookingLoading());
    try {
      await _bookingService.cancelBooking(bookingId);
      // Reload list after cancel
      final bookings = await _bookingService.getMyBookings();
      emit(BookingListLoaded(bookings));
    } catch (e) {
      Log.e('cancelBooking: $e');
      emit(const BookingError('Failed to cancel booking.'));
    }
  }
}
