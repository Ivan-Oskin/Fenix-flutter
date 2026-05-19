import 'dart:typed_data';

class Event {
  final String? id;
  final String title;
  final String? description;
  final String? location;
  final String startDate;
  final int? speakerId;
  Uint8List? photoBytes;

  Event({
    this.id,
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    this.speakerId,
    this.photoBytes
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      startDate: map['start_date'],
      speakerId: map['speaker_id'],
      photoBytes: map['photo'] as Uint8List?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'start_date': startDate,
      'speaker_id': speakerId,
    };
  }
}