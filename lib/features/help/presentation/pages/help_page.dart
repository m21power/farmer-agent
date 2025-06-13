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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/law_probability_warning.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  List<HistoryModel> historyList = [];
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpBloc, HelpState>(listener: (context, state) {
      print("state: $state");

      if (state is SaveHistorySuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.savedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        context.read<HistoryBloc>().add(GetHistoryEvent());
      }

      if (state is AskSuccessState || state is AskLoadingState) {
        setState(() {
          historyList = state.history;
        });
      }
      if (state is HistoryErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveError),
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
                label: Text(AppLocalizations.of(context)!.scan_maize,
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
                        Text(
                          AppLocalizations.of(context)!.welcome,
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
                          label: Text(
                            AppLocalizations.of(context)!.scan_maize,
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
                      itemCount: historyList.length,
                      itemBuilder: (context, index) =>
                          buildHistoryItem(historyList[index]),
                    ),
                  ),
          ],
        ),
      );
    });
  }

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
              title: Text(
                AppLocalizations.of(context)!.choose_fgallery,
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
              title: Text(
                AppLocalizations.of(context)!.take_photo,
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
        title: Text(AppLocalizations.of(context)!.confirmImage),
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
            child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.white)),
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
            child: Text(AppLocalizations.of(context)!.send,
                style: TextStyle(color: Colors.white)),
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
            title: Text(
              AppLocalizations.of(context)!.copyResponse,
              style: TextStyle(color: const Color(0xFF0A65AF)),
            ),
            onTap: () {
              final copyText =
                  "Name: ${model.name}\nScientific Name: ${model.scientificName}\nProbability: ${model.probability}\nDescription: ${model.description ?? 'N/A'}";
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: copyText));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.copied)));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<HelpBloc>().add(UpdateStateEvent());
            },
          ),
        ],
      ),
    );
  }

  Widget buildHistoryItem(HistoryModel model) {
    final isLowProbability = model.probability < 75;
    if (isLowProbability) {
      return LowProbabilityWarning();
    }
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
                            model.isNew == true && !isLowProbability
                                ? IconButton(
                                    icon: const Icon(Icons.bookmark,
                                        color: Colors.white),
                                    onPressed: () {
                                      context.read<HelpBloc>().add(
                                          SaveHistoryEvent(history: model));
                                    },
                                  )
                                : SizedBox(),
                            !isLowProbability
                                ? IconButton(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onPressed: () => showMenuOptions(model),
                                  )
                                : SizedBox()
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

                      // Treatments (optional and expandable)
                      if (model.treatments != null &&
                          model.treatments!.isNotEmpty)
                        const SizedBox(height: 8),
                      if (model.treatments != null &&
                          model.treatments!.isNotEmpty)
                        ExpandableTreatments(model.treatments!),

                      const SizedBox(height: 12),

                      // Created at (moved to bottom and styled)
                      Text(
                        "Created: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(model.createdAt))}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class ExpandableTreatments extends StatefulWidget {
  final List<String> treatments;

  const ExpandableTreatments(this.treatments, {Key? key}) : super(key: key);

  @override
  State<ExpandableTreatments> createState() => ExpandableTreatmentsState();
}

class ExpandableTreatmentsState extends State<ExpandableTreatments> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final displayedTreatments =
        isExpanded ? widget.treatments : widget.treatments.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Treatments:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...displayedTreatments.map((treatment) => Row(
              children: [
                const Icon(Icons.medical_services,
                    size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(treatment)),
              ],
            )),
        if (widget.treatments.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Text(
                isExpanded
                    ? AppLocalizations.of(context)!.see_less
                    : AppLocalizations.of(context)!.see_more,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }
}
