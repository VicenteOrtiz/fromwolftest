part 'task.g.dart';

class Task extends Object with _$TaskSerializerMixin {

  final String id;
  final String title;
  final bool completed;

  Task({this.id, this.title, this.completed});


  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

}
