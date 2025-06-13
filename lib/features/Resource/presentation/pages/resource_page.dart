import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maize_guard/features/Resource/domain/entities/disease.dart';
import 'package:maize_guard/features/Resource/presentation/bloc/info_bloc.dart';
import 'package:maize_guard/features/Resource/presentation/pages/add_edit_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../dependency_injection.dart';

class ResourcePage extends StatelessWidget {
  ResourcePage({super.key});

  final String? role = sl<SharedPreferences>().getString('role');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<InfoBloc, InfoState>(
        listener: (context, state) {
          if (state is InfoErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          if (state is InfoSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green,
                content:
                    Text(AppLocalizations.of(context)!.operationSuccessful)));
          }
        },
        builder: (context, state) {
          if (state is InfoLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InfoSuccessState) {
            final diseases = state.info;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<InfoBloc>().add(GetInfoEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: diseases.length,
                itemBuilder: (context, index) {
                  final disease = diseases[index];
                  return DiseaseCard(
                    disease: disease,
                    isAdmin: role == 'admin',
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditDiseasePage(
                            disease: disease,
                            onSave: (updated) {
                              context
                                  .read<InfoBloc>()
                                  .add(UpdateDiseaseEvent(updated));
                            },
                          ),
                        ),
                      );
                    },
                    onDelete: () => showDeleteConfirmation(context, () {
                      context
                          .read<InfoBloc>()
                          .add(DeleteDiseaseEvent(disease.id));
                    }),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.failedToLoad,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        },
      ),
      floatingActionButton: role == "admin"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditDiseasePage(
                      onSave: (newDisease) {
                        context
                            .read<InfoBloc>()
                            .add(AddDiseaseEvent(newDisease));
                      },
                    ),
                  ),
                );
              },
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              elevation: 6,
              tooltip: AppLocalizations.of(context)!.add_disease,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : const SizedBox(),
    );
  }

  void showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirm_delete),
        content: Text(AppLocalizations.of(context)!.are_you_sure_delete),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}

class DiseaseCard extends StatefulWidget {
  final Disease disease;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DiseaseCard({
    super.key,
    required this.disease,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _DiseaseCardState createState() => _DiseaseCardState();
}

class _DiseaseCardState extends State<DiseaseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.disease.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (widget.isAdmin)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit();
                      } else if (value == 'delete') {
                        widget.onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          AppLocalizations.of(context)!.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.disease.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      "Signs: ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      widget.disease.signs,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Prevention: ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      widget.disease.prevention,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Treatments: ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      widget.disease.treatments,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('yyyy-MM-dd – kk:mm').format(
                          DateTime.parse(widget.disease.createdAt.toString())),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded
                    ? AppLocalizations.of(context)!.see_less
                    : AppLocalizations.of(context)!.see_more,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
