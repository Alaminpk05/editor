import 'package:editor/home.dart';
import 'package:flutter/material.dart';
import 'package:interactive_box/interactive_box.dart';

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
  // Map to store InteractiveBox widgets with unique IDs
  final Map<int, InteractiveBox> interactiveWidgets = {};
  int _nextId = 0; // Counter for generating unique IDs

  void _addInteractiveBox() {
    setState(() {
      // Create a new InteractiveBox with a unique ID
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
        child: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
          child: Center(
            child: Text(
              'Box ${id + 1}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    });
  }

  void _deleteInteractiveBox(int id) {
    setState(() {
      // Remove the widget with the specified ID
      interactiveWidgets.remove(id);
    });
  }

  void _copyInteractiveBox(int id) {
    setState(() {
      // Find the widget with the specified ID and create a copy
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
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: Center(
              child: Text(
                'Box ${newId + 1}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
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
          ...interactiveWidgets.values, // Render all InteractiveBox widgets
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInteractiveBox,
        child: Icon(Icons.add),
      ),
    );
  }
}