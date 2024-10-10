import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice_code/models/models.dart';
import 'dart:convert';

Future<List<Task>> getApi() async {
  List<Task> data = [];
  var url = Uri.parse(
      'https://crudcrud.com/api/b989d7098db64f65bde8e3c6e3682d88/unicorns');
  var response = await http.get(url);
  var responseBody = jsonDecode(response.body);

  for (var element in responseBody) {
    data.add(Task.fromJson(element));
  }
  return data;
}

Future<void> addTask(Task task) async {
  var url = Uri.parse(
      'https://crudcrud.com/api/b989d7098db64f65bde8e3c6e3682d88/unicorns');
  var response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()));

  if (response.statusCode == 201) {
    print("Task added successfully");
  } else {
    print("Failed to add task");
  }
}

Future<void> updateTask(String id, Task task) async {
  var url = Uri.parse(
      'https://crudcrud.com/api/b989d7098db64f65bde8e3c6e3682d88/unicorns/$id');
  var response = await http.put(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()));

  if (response.statusCode == 200) {
    print("Task updated successfully");
  } else {
    print("Failed to update task");
  }
}

Future<void> deleteTask(String id) async {
  var url = Uri.parse(
      'https://crudcrud.com/api/b989d7098db64f65bde8e3c6e3682d88/unicorns/$id');
  var response = await http.delete(url);

  if (response.statusCode == 200) {
    print("Task deleted successfully");
  } else {
    print("Failed to delete task");
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getApi(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${snapshot.data![index].name}"),
                  subtitle: Text("Age: ${snapshot.data![index].age}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteTask(snapshot.data![index].sId!);
                      setState(() {});
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Task newTask = Task(name: "New Task", age: "25", colour: "Red");
          addTask(newTask);
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
