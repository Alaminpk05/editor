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
  String? _selectedFrameImagePath;
  final ImagePicker _picker = ImagePicker();

  void _addText() async {
    final TextEditingController _textController = TextEditingController();

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
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
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
    if (_selectedFrameImagePath == null) return;

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

  void _selectFrame(String imagePath) {
    setState(() {
      _selectedFrameImagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Box Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Add widgets behind the frame
                  ...interactiveWidgets.values,
        
                  // Add the frame on top
                  if (_selectedFrameImagePath != null)
                    Center(
                      child: ClipRect(
                        child: Image.asset(
                          _selectedFrameImagePath!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFrameOption('lib/assets/1.png'),
                  _buildFrameOption('lib/assets/2.png'),
                  _buildFrameOption('lib/assets/3.png'),
                ],
              ),
            ),
          ],
        ),
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
                      Navigator.pop(context);
                      _addText();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Add Image'),
                    onTap: () {
                      Navigator.pop(context);
                      _addImage();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.widgets),
                    title: Text('Add Container'),
                    onTap: () {
                      Navigator.pop(context);
                      _addContainer();
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

  Widget _buildFrameOption(String imagePath) {
    return GestureDetector(
      onTap: () => _selectFrame(imagePath),
      child: Container(
        margin: EdgeInsets.all(8),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedFrameImagePath == imagePath ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}