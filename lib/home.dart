import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:interactive_box/interactive_box.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frame Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FrameEditorScreen(),
    );
  }
}

class FrameEditorScreen extends StatefulWidget {
  @override
  _FrameEditorScreenState createState() => _FrameEditorScreenState();
}

class _FrameEditorScreenState extends State<FrameEditorScreen> {
  // List of available frames
  final List<Color> frames = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  // Selected frame index
  int selectedFrameIndex = 0;

  // Map to store InteractiveBox widgets with unique IDs
  final Map<int, InteractiveBox> interactiveWidgets = {};
  int _nextId = 0; // Counter for generating unique IDs

  // Controller for text input
  final TextEditingController _textController = TextEditingController();

  // Function to add a new frame with content
  void _addFrameWithContent(Widget content) {
    setState(() {
      int id = _nextId++;
      interactiveWidgets[id] = InteractiveBox(
        key: UniqueKey(),
        initialSize: Size(200, 200),
        includedActions: [
          ControlActionType.delete,
          ControlActionType.rotate,
          ControlActionType.scale,
          ControlActionType.copy,
          ControlActionType.move,
        ],
        onActionSelected: (actionType, info) {
          if (actionType == ControlActionType.delete) {
            _deleteFrame(id);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: frames[selectedFrameIndex],
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: content,
          ),
        ),
      );
    });
  }

  // Function to delete a frame
  void _deleteFrame(int id) {
    setState(() {
      interactiveWidgets.remove(id);
    });
  }

  // Function to show a dialog for adding text
  void _showAddTextDialog() {
    showDialog(
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
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _addFrameWithContent(
                    Text(
                      _textController.text,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                  _textController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to show a dialog for adding an image
  void _showAddImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Image'),
          content: Text('Select an image from your gallery or camera.'),
          actions: [
            TextButton(
              onPressed: () {
                // Simulate image selection (replace with actual image picker logic)
                _addFrameWithContent(
                  Icon(Icons.image, size: 50, color: Colors.white),
                );
                Navigator.pop(context);
              },
              child: Text('Add Placeholder Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frame Editor'),
        actions: [
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: _showAddTextDialog,
            tooltip: 'Add Text',
          ),
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _showAddImageDialog,
            tooltip: 'Add Image',
          ),
        ],
      ),
      body: Column(
        children: [



        
          // Frame selection bar
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: frames.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFrameIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: frames[index],
                      border: Border.all(
                        color: selectedFrameIndex == index
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Interactive frames area
          Expanded(
            child: Stack(
              children: [
                ...interactiveWidgets.values, // Render all InteractiveBox widgets
              ],
            ),
          ),
        ],
      ),
    );
  }
}