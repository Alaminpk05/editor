import 'package:flutter/material.dart';
import 'package:interactive_box/interactive_box.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InteractiveBoxExample(),
    );
  }
}

class InteractiveBoxExample extends StatefulWidget {
  @override
  _InteractiveBoxExampleState createState() => _InteractiveBoxExampleState();
}

class _InteractiveBoxExampleState extends State<InteractiveBoxExample> {
  final Map<int, InteractiveBox> interactiveWidgets = {};
  int _nextId = 0;

  final ImagePicker _picker = ImagePicker();

  void _addText() async {
    final TextEditingController _textController = TextEditingController();

    // Show the text input dialog
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Text'),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: 'Enter text'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  // Add the text as an interactive box
                  _addInteractiveBox(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.transparent,
                      child: Center(
                        child: Text(
                          _textController.text,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  );
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _addInteractiveBox(
        child: Image.file(
          File(image.path),
          fit: BoxFit.cover,
        ),
      );
    }
  }

  void _addContainer() {
    _addInteractiveBox(
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
        child: Center(
          child: Text(
            'Box ${_nextId + 1}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _addInteractiveBox({required Widget child}) {
    setState(() {
      int id = _nextId++;
      interactiveWidgets[id] = InteractiveBox(
        key: UniqueKey(),
        initialSize: Size(100, 100),
        includedActions: [
          ControlActionType.copy,
          ControlActionType.delete,
          ControlActionType.rotate,
          ControlActionType.scale,
          ControlActionType.move,
        ],
        onActionSelected: (actionType, info) {
          if (actionType == ControlActionType.delete) {
            _deleteInteractiveBox(id);
          } else if (actionType == ControlActionType.copy) {
            _copyInteractiveBox(id);
          }
        },
        child: child,
      );
    });
  }

  void _deleteInteractiveBox(int id) {
    setState(() {
      interactiveWidgets.remove(id);
    });
  }

  void _copyInteractiveBox(int id) {
    setState(() {
      if (interactiveWidgets.containsKey(id)) {
        int newId = _nextId++;
        interactiveWidgets[newId] = InteractiveBox(
          key: UniqueKey(),
          initialSize: Size(100, 100),
          includedActions: [
            ControlActionType.copy,
            ControlActionType.delete,
            ControlActionType.rotate,
            ControlActionType.scale,
            ControlActionType.move,
          ],
          onActionSelected: (actionType, info) {
            if (actionType == ControlActionType.delete) {
              _deleteInteractiveBox(newId);
            } else if (actionType == ControlActionType.copy) {
              _copyInteractiveBox(newId);
            }
          },
          child: interactiveWidgets[id]!.child,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Box Example'),
      ),
      body: Stack(
        children: [
          ...interactiveWidgets.values,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.text_fields),
                    title: Text('Add Text'),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _addText(); // Open the text dialog
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Add Image'),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _addImage(); // Open the image picker
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.widgets),
                    title: Text('Add Container'),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _addContainer(); // Add a container
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}