import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final String apiUrl =
      "https://crudcrud.com/api/bce4de12e5a3448e979a16e8fbde2c5c/unicorns";
  List<dynamic> tasks = [];

  @override
  void initState() {
    super.initState();
    loadLocalTasks(); // Load tasks from SharedPreferences on startup
    fetchTasks(); // Fetch tasks from API
  }

  // Save tasks to SharedPreferences
  Future<void> saveTasksLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(tasks));
  }

  // Load tasks from SharedPreferences
  Future<void> loadLocalTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTasks = prefs.getString('tasks');
    if (storedTasks != null) {
      setState(() {
        tasks = json.decode(storedTasks);
      });
    }
  }

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      try {
        setState(() {
          tasks = json.decode(response.body);
        });
        await saveTasksLocally(); // Save fetched tasks locally
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
      fetchTasks(); // Refresh and save tasks locally
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
        "isWishList": isWishList,
      }),
    );
    if (response.statusCode == 200) {
      fetchTasks(); // Refresh and save tasks locally
    } else {
      print('Failed to update task: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse("$apiUrl/$id"));
    if (response.statusCode == 200) {
      fetchTasks(); // Refresh and save tasks locally
    } else {
      print('Failed to delete task: ${response.statusCode}');
    }
  }

  void showEditTaskDialog(
      String id, String task, String priority, bool isWishList) {
    TextEditingController taskController = TextEditingController(text: task);
    String updatedPriority = priority;
    bool updatedIsWishList = isWishList;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: 'Task'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: updatedPriority,
                decoration: InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: <String>['High', 'Medium', 'Low']
                    .map<DropdownMenuItem<String>>((String value) {
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
              const SizedBox(height: 16),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateTask(id, taskController.text, updatedPriority,
                    updatedIsWishList);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController taskController = TextEditingController();
    String priority = "Low";
    bool isWishList = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Add Task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  addTask(taskController.text, priority, isWishList);
                  taskController.clear();
                }
              },
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isNotEmpty
                  ? ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          title: Text(task['task'] ?? 'No task'),
                          subtitle:
                              Text('Priority: ${task['priority'] ?? 'N/A'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteTask(task['_id']);
                            },
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No tasks yet!')),
            ),
          ],
        ),
      ),
    );
  }
}
