import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:maize_guard/features/help/presentation/bloc/bloc/history_bloc.dart';
import 'package:maize_guard/features/help/presentation/pages/help_page.dart';

import '../../domain/entities/history_entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryModel> historyList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HistoryBloc>().add(GetHistoryEvent());
        },
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            print("history: $state");
            if (state is GetHistoryLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetHistorySuccessState) {
              historyList = List.from(state.history);
              if (historyList.isEmpty) {
                return Center(
                    child: Text(AppLocalizations.of(context)!.noSavedHistory));
              }

              return ListView.builder(
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  return buildHistoryItem(context, historyList[index]);
                },
              );
            } else if (state is GetHistoryErrorState) {
              return Center(
                  child:
                      Text(AppLocalizations.of(context)!.failedToLoadHistory));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget buildHistoryItem(BuildContext context, HistoryModel model) {
    final isLowProbability = model.probability < 50;
    return model.uploading == true
        ? const LinearProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 193, 196, 14),
            ),
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
                        child: IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () => showMenuOptions(model),
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
                      if (model.treatments != null &&
                          model.treatments!.isNotEmpty)
                        const SizedBox(height: 8),
                      if (model.treatments != null &&
                          model.treatments!.isNotEmpty)
                        ExpandableTreatments(model.treatments!),
                      const SizedBox(height: 12),
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

  void showMenuOptions(HistoryModel model) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy, color: Color(0xFF0A65AF)),
            title: Text(AppLocalizations.of(context)!.copyResponse,
                style: TextStyle(color: Color(0xFF0A65AF))),
            onTap: () {
              final treatmentsText =
                  (model.treatments != null && model.treatments!.isNotEmpty)
                      ? "\nTreatments:\n- ${model.treatments!.join("\n- ")}"
                      : "";

              final copyText = "Name: ${model.name}\n"
                  "Scientific Name: ${model.scientificName}\n"
                  "Probability: ${model.probability}%\n"
                  "Description: ${model.description ?? 'N/A'}"
                  "$treatmentsText";

              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: copyText));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.copied)));
            },
          ),
          if (model.isNew != true)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.delete,
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<HistoryBloc>()
                    .add(DeleteHistoryEvent(id: model.id!));
                context.read<HistoryBloc>().add(GetHistoryEvent());
              },
            ),
        ],
      ),
    );
  }
}
