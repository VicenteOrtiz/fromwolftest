import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fromwolf_test/models/task.dart';
import 'package:fromwolf_test/secret/constants.dart';

class TaskService {

  static const CHANNEL_NAME = 'p77ffnilmbfgxg5uotm4rcbqfm';
  static const QUERY_GET_ALL_TASKS = 'listTasks';
  static const MUTATION_NEW_TASK = 'createTask';
  static const MUTATION_DELETE_TASK = 'deleteTask';


  static const SUBSCRIBE_NEW_MESSAGE = 'onCreateTask';
  static const SUBSCRIBE_NEW_MESSAGE_RESULT = 'onCreateTaskResult';

  static const Map<String, dynamic> _DEFAULT_PARAMS = <String, dynamic> {
    'endpoint': AWS_APP_SYNC_ENDPOINT,
    'apiKey': AWS_APP_SYNC_KEY
  };

  static const MethodChannel APP_SYNC_CHANNEL = const MethodChannel(CHANNEL_NAME);

  TaskService() {
    APP_SYNC_CHANNEL.setMethodCallHandler(_handleMethod);
  }

  final StreamController<Task> taskBroadcast = new StreamController<Task>.broadcast();
  
  Future<List<Task>> getAllTasks() async {
    String jsonString = await APP_SYNC_CHANNEL.invokeMethod(QUERY_GET_ALL_TASKS, _buildParams());
    List<dynamic> values = json.decode(jsonString);
    return values.map((value) => Task.fromJson(value)).toList();
  }

  Future<Task> sendTask(String title, bool completed) async {
    final params = {
      "title": title,
      "completed": completed
    };
    String jsonString = await APP_SYNC_CHANNEL.invokeMethod(MUTATION_NEW_TASK, _buildParams(otherParams: params));
    Map<String, dynamic> values = json.decode(jsonString);
    return Task.fromJson(values);
  }

  Future<Task> deleteTask(String id) async {
    final params = {
      "id": id,
    };
    String jsonString = await APP_SYNC_CHANNEL.invokeMethod(MUTATION_NEW_TASK, _buildParams(otherParams: params));
    Map<String, dynamic> values = json.decode(jsonString);
    return Task.fromJson(values);
  }

  void subscribeNewTask() {
    APP_SYNC_CHANNEL.invokeMethod(SUBSCRIBE_NEW_MESSAGE, _buildParams());
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == SUBSCRIBE_NEW_MESSAGE_RESULT) {
      String jsonString = call.arguments;
      try {
        Map<String, dynamic> values = json.decode(jsonString);
        Task message = Task.fromJson(values);
        taskBroadcast.add(message);
      } catch(e) {
        print(e);
      }
    }
    return null;
  }

  Map<String, dynamic> _buildParams({Map<String, dynamic> otherParams}) {
    final params = new Map<String, dynamic>.from(_DEFAULT_PARAMS);
    if (otherParams != null) {
      params.addAll(otherParams);
    }
    return params;
  }
  
}