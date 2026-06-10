import 'package:booking_slot_app/data/models/slot_model.dart';
import 'package:booking_slot_app/data/models/venue_model.dart';
import 'package:equatable/equatable.dart';

abstract class VenueState extends Equatable {
  const VenueState();
  @override
  List<Object?> get props => [];
}

class VenueInitial extends VenueState {}

class VenueLoading extends VenueState {}

class VenueListLoaded extends VenueState {
  final List<VenueModel> venues;
  final String filter; // 'all' | 'badminton' | 'turf'
  const VenueListLoaded(this.venues, {this.filter = 'all'});
  @override
  List<Object?> get props => [venues, filter];
}

class SlotsLoaded extends VenueState {
  final List<SlotModel> slots;
  final String selectedDate;
  const SlotsLoaded(this.slots, this.selectedDate);
  @override
  List<Object?> get props => [slots, selectedDate];
}

class VenueError extends VenueState {
  final String message;
  const VenueError(this.message);
  @override
  List<Object?> get props => [message];
}
