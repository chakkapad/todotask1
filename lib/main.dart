import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const TodaApp(),
    );
  }
}

class TodaApp extends StatefulWidget {
  const TodaApp({super.key});

  @override
  State<TodaApp> createState() => _TodaAppState();
}

class _TodaAppState extends State<TodaApp> {
  late TextEditingController _texteditController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _texteditController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void addTodoHandle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new task"),
          content: SizedBox(
            width: 120,
            height: 140,
            child: Column(
              children: [
                TextField(
                  controller: _texteditController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Input your task"),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                CollectionReference tasks =
                    FirebaseFirestore.instance.collection("tasks");
                tasks.add({
                  'name': _texteditController.text,
                  'note': _descriptionController.text,
                  'isCompleted': false,
                }).then((res) {
                  print(res);
                }).catchError((onError) {
                  print("Failed to add new Task");
                });
                setState(() {});
                _texteditController.text = "";
                _descriptionController.text = "";
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void editTodoHandle(String id, String currentName, String currentNote) {
    _texteditController.text = currentName;
    _descriptionController.text = currentNote;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit task"),
          content: SizedBox(
            width: 120,
            height: 140,
            child: Column(
              children: [
                TextField(
                  controller: _texteditController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Edit your task"),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                CollectionReference tasks =
                    FirebaseFirestore.instance.collection("tasks");
                tasks.doc(id).update({
                  'name': _texteditController.text,
                  'note': _descriptionController.text,
                }).then((res) {
                  print("Task updated");
                }).catchError((onError) {
                  print("Failed to update Task");
                });
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void deleteTodoHandle(String id) {
    FirebaseFirestore.instance.collection('tasks').doc(id).delete().then((res) {
      print("Task deleted");
    }).catchError((onError) {
      print("Failed to delete Task");
    });
  }

  void toggleCompletion(String id, bool isCompleted) {
    FirebaseFirestore.instance.collection('tasks').doc(id).update({
      'isCompleted': !isCompleted,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("tasks").snapshots(),
        builder: (context, snapshot) {
          return snapshot.data != null
              ? ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    var task = snapshot.data?.docs[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task?['isCompleted'],
                            onChanged: (value) {
                              toggleCompletion(task!.id, task['isCompleted']);
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task?['name'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    decoration: task?['isCompleted']
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (task?['note'] != null) Text(task?['note']),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editTodoHandle(
                                  task!.id, task['name'], task['note']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteTodoHandle(task!.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Text("No data");
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTodoHandle(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
