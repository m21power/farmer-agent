import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maize_guard/features/community/presentation/bloc/community_bloc.dart';

class AskQuestionView extends StatefulWidget {
  final VoidCallback onCancel;
  const AskQuestionView({super.key, required this.onCancel});

  @override
  State<AskQuestionView> createState() => _AskQuestionViewState();
}

class _AskQuestionViewState extends State<AskQuestionView> {
  final TextEditingController questionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: const Color.fromARGB(255, 23, 165, 28),
              ),
              title: const Text(
                "Take a Photo",
                style: TextStyle(color: const Color.fromARGB(255, 23, 165, 28)),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() {
                    _selectedImage = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo,
                color: const Color.fromARGB(255, 23, 165, 28),
              ),
              title: const Text(
                "Choose from Gallery",
                style: TextStyle(color: const Color.fromARGB(255, 23, 165, 28)),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() {
                    _selectedImage = File(picked.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your Question",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: questionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Describe your issue here...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Attach Image + Preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 23, 165, 28),
                    ),
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: const Text("Attach Image",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final text = questionController.text.trim();
                  if (text.isNotEmpty) {
                    context.read<CommunityBloc>().add(
                          PostQuestionEvent(
                            image: _selectedImage,
                            question: text,
                          ),
                        );

                    widget.onCancel();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please describe your issue!"),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Submit Question",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 165, 28),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
