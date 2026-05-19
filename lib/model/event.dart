class Event {
  final String? id;
  final String title;
  final String? description;
  final String? location;
  final String startDate;
  final int? speakerId;

  Event({
    this.id,
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    this.speakerId,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      startDate: map['start_date'],
      speakerId: map['speaker_id'],
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