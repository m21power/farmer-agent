import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maize_guard/features/help/presentation/bloc/bloc/history_bloc.dart';
import 'package:maize_guard/features/help/presentation/bloc/help_bloc.dart';
import 'dart:io';
import '../../domain/entities/history_entities.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<HistoryModel> historyList = [];
  File? selectedImage;

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo,
                color: const Color.fromARGB(255, 23, 165, 28),
              ),
              title: const Text(
                'Pick from Gallery',
                style: TextStyle(color: const Color.fromARGB(255, 23, 165, 28)),
              ),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => selectedImage = File(pickedFile.path));
                  confirmImage();
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: const Color.fromARGB(255, 23, 165, 28),
              ),
              title: const Text(
                'Take a Picture',
                style: TextStyle(color: const Color.fromARGB(255, 23, 165, 28)),
              ),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => selectedImage = File(pickedFile.path));
                  confirmImage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void confirmImage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Image"),
        content: Image.file(selectedImage!),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF0A65AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<HelpBloc>()
                  .add(AskEvent(imagePath: selectedImage!.path));
            },
            child: const Text("Send", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void showMenuOptions(HistoryModel model) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.copy,
              color: const Color(0xFF0A65AF),
            ),
            title: const Text(
              "Copy Response",
              style: TextStyle(color: const Color(0xFF0A65AF)),
            ),
            onTap: () {
              final copyText =
                  "Name: ${model.name}\nScientific Name: ${model.scientificName}\nProbability: ${model.probability}\nDescription: ${model.description ?? 'N/A'}";
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: copyText));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Copied!")));
            },
          ),
        ],
      ),
    );
  }

  Widget buildHistoryItem(HistoryModel model) {
    final isLowProbability = model.probability < 50;
    return model.uploading == true
        ? const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 193, 196, 14)),
          )
        : Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: model.imageLink,
                      imageBuilder: (context, imageProvider) => AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.08 * 255).toInt()),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      progressIndicatorBuilder: (context, url, progress) =>
                          AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          ),
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.08),
                          ),
                          child: const Icon(Icons.error,
                              color: Colors.black, size: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            model.isNew == true
                                ? IconButton(
                                    icon: const Icon(Icons.bookmark,
                                        color: Colors.white),
                                    onPressed: () {
                                      context.read<HelpBloc>().add(
                                          SaveHistoryEvent(history: model));
                                    },
                                  )
                                : SizedBox(),
                            IconButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: () => showMenuOptions(model),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${model.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Scientific Name: ${model.scientificName}"),
                      Text(
                        "Probability: ${model.probability.toStringAsFixed(2)}%",
                        style: TextStyle(
                            color:
                                isLowProbability ? Colors.red : Colors.green),
                      ),
                      if (model.description != null &&
                          model.description!.isNotEmpty)
                        Text("Description: ${model.description}"),
                      Text(
                          "Created: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(model.createdAt))}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpBloc, HelpState>(listener: (context, state) {
      print("state: $state");
      if (state is SaveHistorySuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        context.read<HistoryBloc>().add(GetHistoryEvent());
      }

      if (state is HistoryErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error occurred while saving,try again!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, builder: (context, state) {
      final isHistoryEmpty = state.history.isEmpty;

      return Scaffold(
        floatingActionButton: isHistoryEmpty
            ? null // Don't show FAB when history is empty
            : FloatingActionButton.extended(
                onPressed: pickImage,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Scan Maize",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white)),
                backgroundColor: const Color.fromARGB(255, 23, 165, 28),
              ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/crop.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            isHistoryEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Welcome to Maize Guard! Scan your maize to receive expert assistance and guidance.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 23, 165, 28),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: pickImage,
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text(
                            "Scan Maize",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      // context.read<HelpBloc>().add(GetHistoryEvent());
                    },
                    child: ListView.builder(
                      itemCount: state.history.length,
                      itemBuilder: (context, index) =>
                          buildHistoryItem(state.history[index]),
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
