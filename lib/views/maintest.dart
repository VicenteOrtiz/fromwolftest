import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fromwolf_test/models/task.dart';
import 'package:fromwolf_test/services/task_service.dart';

class MainTest extends StatefulWidget {
  MainTest({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainTestState createState() => new _MainTestState();
}

class _MainTestState extends State<MainTest> {
  String _sender;

  final textEditingController = new TextEditingController();

  final taskService = new TaskService();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    taskService.subscribeNewTask();
    _tasks.addAll(await taskService.getAllTasks());
    if (mounted) {
      setState(() {
        // refresh
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: (_sender == null) ? _buildConfigurationSender() : _buildTchat());
  }

  Widget _buildConfigurationSender() {
    return new Padding(
      padding: const EdgeInsets.all(32.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: 'Enter your sender name',
            ),
          ),
          new SizedBox(height: 16.0),
          new RaisedButton(
            child: new Text("Validate"),
            onPressed: () {
              setState(() {
                if (textEditingController.text.isEmpty) {
                  final snackBar = SnackBar(
                      content: Text('Error, your sender name is empty'));
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  return;
                }
                _sender = textEditingController.text;
                textEditingController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  StreamSubscription<Task> _streamSubscription;

  List<Task> _tasks = [];

  final GlobalKey<AnimatedListState> _animateListKey =
      new GlobalKey<AnimatedListState>();

  Widget _buildTchat() {
    if (_streamSubscription == null) {
      _streamSubscription =
          taskService.taskBroadcast.stream.listen((task) {
        _tasks.insert(0, task);
        _animateListKey.currentState?.insertItem(0);
      }, cancelOnError: false, onError: (e) => debugPrint(e));
    }

    return new Column(
      children: <Widget>[
        new Expanded(
          child: _buildList(),
        ),
        new Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextFormField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Saisir votre task',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _sendTask,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendTask() {
    final content = textEditingController.text;
    if (content.trim().isEmpty) {
      final snackBar = SnackBar(content: Text('Error, your task is empty'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }
    taskService.sendTask(content, true);
    textEditingController.clear();
  }

  Widget _buildList() {
    return new AnimatedList(
      key: _animateListKey,
      reverse: true,
      initialItemCount: _tasks.length,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        final task = _tasks[index];
        return new Directionality(
          textDirection:
              TextDirection.rtl,
          child: new SizeTransition(
            axis: Axis.vertical,
            sizeFactor: animation,
            child: _buildTaskItem(task),
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return new ListTile(
      title: new Text(task.title),
      subtitle: new Text('Test Sub'),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    textEditingController.dispose();
    super.dispose();
  }
}