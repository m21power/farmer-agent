import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maize_guard/features/Resource/presentation/bloc/info_bloc.dart';

import '../../domain/entities/disease.dart';

class ResourcePage extends StatelessWidget {
  ResourcePage({super.key});
  List<Disease> diseases = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfoBloc, InfoState>(
      listener: (context, state) {
        print("State: $state");
        if (state is InfoSuccessState) {
          diseases = List.from(state.info);
        }
        if (state is InfoErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is InfoLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InfoErrorState) {
          return const Center(child: Text("Failed to load diseases"));
        }
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<InfoBloc>().add(GetInfoEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diseases.length,
              itemBuilder: (context, index) {
                final disease = diseases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disease.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        InfoSection(title: 'Signs', content: disease.signs),
                        InfoSection(
                            title: 'Treatments', content: disease.treatments),
                        InfoSection(
                            title: 'Prevention', content: disease.prevention),
                        const SizedBox(height: 8),
                        Text(
                          'Added on: ${DateFormat.yMMMMd().format(disease.createdAt)}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const InfoSection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
          children: [
            TextSpan(
                text: '$title: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
