import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final String apiUrl =
      "https://crudcrud.com/api/6a6ed3123b1a44d29878ae57d3c12780/unicorns";
  List<dynamic> tasks = [];

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse(apiUrl));
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      try {
        setState(() {
          tasks = json.decode(response.body);
        });
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<void> addTask(String task, String priority, bool isWishList) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
          {"task": task, "priority": priority, "isWishList": isWishList}),
    );
    if (response.statusCode == 201) {
      fetchTasks();
    } else {
      print('Failed to add task: ${response.statusCode}');
    }
  }

  Future<void> updateTask(
      String id, String updatedTask, String priority, bool isWishList) async {
    final response = await http.put(
      Uri.parse("$apiUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "task": updatedTask,
        "priority": priority,
        "isWishList": isWishList
      }),
    );
    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      print('Failed to update task: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse("$apiUrl/$id"));
    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      print('Failed to delete task: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController taskController = TextEditingController();
    String priority = "Low"; // Default priority
    bool isWishList = false; // Default wish list status

    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Add a Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          DropdownButton<String>(
            value: priority,
            items: <String>['High', 'Medium', 'Low']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                priority = newValue!;
              });
            },
          ),
          Row(
            children: [
              Checkbox(
                value: isWishList,
                onChanged: (bool? newValue) {
                  setState(() {
                    isWishList = newValue!;
                  });
                },
              ),
              const Text("Add to Wish List"),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                addTask(taskController.text, priority, isWishList);
                taskController.clear();
              }
            },
            child: const Text('Add Task'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['task'] ?? 'No task found'),
                  subtitle: Text('Priority: ${task['priority'] ?? 'N/A'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController updateController =
                                  TextEditingController();
                              updateController.text = task['task'] ?? '';
                              String updatedPriority =
                                  task['priority'] ?? 'Low';
                              bool updatedIsWishList =
                                  task['isWishList'] ?? false;

                              return AlertDialog(
                                title: const Text("Update Task"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: updateController,
                                    ),
                                    DropdownButton<String>(
                                      value: updatedPriority,
                                      items: <String>['High', 'Medium', 'Low']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          updatedPriority = newValue!;
                                        });
                                      },
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: updatedIsWishList,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              updatedIsWishList = newValue!;
                                            });
                                          },
                                        ),
                                        const Text("Add to Wish List"),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateTask(
                                          task['_id'],
                                          updateController.text,
                                          updatedPriority,
                                          updatedIsWishList);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Update"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteTask(task['_id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
