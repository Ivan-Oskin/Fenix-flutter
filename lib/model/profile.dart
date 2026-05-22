class Profile {
  final int? id;
  final String? token;
  final String? username;
  final String? name;
  final String? surname;
  final String? patronymic;

  Profile({
    this.id,
    this.username,
    this.name,
    this.surname,
    this.patronymic,
    this.token,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      token: map['token'],
      username: map['username'],
      name: map['name'],
      surname: map['surname'],
      patronymic: map['patronymic'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'username': username,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
    };
  }
}
