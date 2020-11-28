part of 'task.dart';

Task _$TaskFromJson(Map<String, dynamic> json) => new Task(
    id: json['id'] as String,
    title: json['title'] as String,
    completed: json['completed'] as bool);

abstract class _$TaskSerializerMixin {
  String get id;
  String get title;
  bool get completed;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'title': title, 'completed': completed};
}