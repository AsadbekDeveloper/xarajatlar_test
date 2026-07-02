import 'package:equatable/equatable.dart';

class Person extends Equatable {
  const Person({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

const _unknownPerson = Person(id: '', name: '—');

extension PersonLookup on List<Person> {
  /// Looks up a person by id, degrading to a placeholder instead of
  /// throwing if the id is ever stale — a whole screen failing to render is
  /// worse than one label showing a placeholder.
  Person findById(String id) =>
      firstWhere((person) => person.id == id, orElse: () => _unknownPerson);
}
