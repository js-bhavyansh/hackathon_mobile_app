import 'package:equatable/equatable.dart';

class VenueModel extends Equatable {
  final String id;
  final String name;
  final String sportType;
  final String location;
  final String? imageUrl;

  const VenueModel({
    required this.id,
    required this.name,
    required this.sportType,
    required this.location,
    this.imageUrl,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) => VenueModel(
        id: json['id'] as String,
        name: json['name'] as String,
        sportType: json['sport_type'] as String,
        location: json['location'] as String,
        imageUrl: json['image_url'] as String?,
      );

  @override
  List<Object?> get props => [id, name, sportType, location, imageUrl];
}
