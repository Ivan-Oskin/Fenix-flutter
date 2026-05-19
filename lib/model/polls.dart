class Poll {
  final int? id;
  final String? title;
  final String? url;
  final String? eventId;

  Poll({
    this.id,
    this.eventId,
    this.title,
    this.url
  });

  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'],
      title: map['title'],
      eventId: map['meeting_id'],
      url: map["url"]
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'meeting_id': eventId,
      'url' : url
    };
  }
}