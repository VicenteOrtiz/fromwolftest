import 'package:flutter/material.dart';
import 'package:fromwolf_test/views/maintest.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 137, 75, 224)
      ),
      home: TaskList(),
      title: "From Wolf Test",
    )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  

  @override
  Widget build(BuildContext context) {

    final HttpLink httpLink =
    HttpLink(uri: "https://irt3dvvrsva2hlaldthczxsvyq.appsync-api.us-east-2.amazonaws.com/graphql");

    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        )

      )
    );

    return GraphQLProvider(
      client: client,
      child: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  //const HomePage({Key key}) : super(key: key);

  String query = r'''

    mutation insertTask($title:String!, $completed:Boolean){
      insert_task(objects: [(title: $title, completed: $completed)]) {
        returning {
          title
          completed
        }
      }
    }


  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FromWolf Test"),
      ),
      body: Mutation(
        options: MutationOptions(
          document: query, 
        ),
        builder: (RunMutation insert, QueryResult result) {
          return Column(
            children: [
              TextField(
                decoration: InputDecoration(hintText: "title"),
              ),
              TextField(
                decoration: InputDecoration(hintText: "Completed"),
              )
            ],
          );
        },
      ),

    );
  }
}

class TaskList extends StatefulWidget {
  @override
  createState() => new TaskListState();
}

class TaskListState extends State<TaskList> {
  List<String> _taskItems = [];

  void _addTaskItem(String task) {
    // Only add the task if the user actually entered something
    if(task.length > 0) {
      // Putting our code inside "setState" tells the app that our state has changed, and
      // it will automatically re-render the list
      setState(() => _taskItems.add(task));
    }
  }

  void _removeTaskItem(int index) {
    setState(() => _taskItems.removeAt(index));
  }

  void _promptRemoveTaskItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Mark "${_taskItems[index]}" as done?'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('CANCEL'),
              // The alert is actually part of the navigation stack, so to close it, we
              // need to pop it.
              onPressed: () => Navigator.of(context).pop()
            ),
            new FlatButton(
              child: new Text('MARK AS DONE'),
              onPressed: () {
                _removeTaskItem(index);
                Navigator.of(context).pop();
              }
            )
          ]
        );
      }
    );
  }

  // Build the whole list of task items
  Widget _buildTaskList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of task items we have. So, we need to check the index is OK.
        if(index < _taskItems.length) {
          return _buildTaskItem(_taskItems[index], index);
        }
      },
    );
  }

  // Build a single task item
  Widget _buildTaskItem(String taskText, int index) {
    return new ListTile(
      leading: Icon(Icons.playlist_add_check),
      title: new Text(taskText),
      onTap: () => _promptRemoveTaskItem(index)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Task List')
      ),
      body: _buildTaskList(),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: _pushAddTaskScreen,
        tooltip: 'Add task',
        child: new Icon(Icons.add)
      ),
    );
  }

  void _pushAddTaskScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well as adding
      // a back button to close it
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Add a new task')
            ),
            body: new TextField(
              autofocus: true,
              onSubmitted: (val) {
                _addTaskItem(val);
                Navigator.pop(context); // Close the add task screen
              },
              decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)
              ),
            )
          );
        }
      )
    );
  }
}