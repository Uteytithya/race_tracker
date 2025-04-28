class Participant {
  final int bib;
  final String name;
  final int age;
  final String gender;

  Participant({
    required this.bib,
    required this.name,
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'bib': bib,
      'name': name,
      'age': age,
      'gender': gender,
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      bib: map['bib'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
    );
  }
}
