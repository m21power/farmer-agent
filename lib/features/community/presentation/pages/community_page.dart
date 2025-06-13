import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../bloc/community_bloc.dart';
import '../widgets/ask_question_view.dart';
import '../widgets/post_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool asking = false;

  void toggleAskMode() => setState(() => asking = !asking);

  ScrollController scrollController = ScrollController();
  ItemScrollController itemScrollController = ItemScrollController();
  String response = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: asking
          ? AskQuestionView(onCancel: toggleAskMode)
          : RefreshIndicator(
              onRefresh: () async {
                context.read<CommunityBloc>().add(GetPostsEvent());
              },
              child: BlocConsumer<CommunityBloc, CommunityState>(
                  listener: (context, state) {
                if (state is PostingLoadingState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!.posting)),
                  );
                } else if (state is PostQuestionSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.postedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // posts.insert(0, state.post);
                } else if (state is CommunityError) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text(state.message)),
                  // );
                }
                if (state is DeletePostSuccessState) {
                  setState(() {});
                }
                if (state is CommunityLoaded) {
                  print("test: $state");
                  setState(() {});
                }
                if (state.posts.isEmpty) {
                  response = AppLocalizations.of(context)!.noPostsYet;
                  if (state is InternetConnectedState) {
                    if (!state.isConnected) {
                      response =
                          AppLocalizations.of(context)!.noInternetConnection;
                    }
                  }
                }
                if (state is ReplyFailedState) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text(state.message)),
                  // );
                }
                print("response: $response");
              }, builder: (context, state) {
                if (state is CommunityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return state.posts.isEmpty
                    ? Center(
                        child: Text(textAlign: TextAlign.center, response),
                      )
                    : ScrollablePositionedList.builder(
                        // padding: const EdgeInsets.only(16),
                        itemCount: state.posts.length,
                        itemScrollController: itemScrollController,
                        itemBuilder: (context, index) {
                          return PostItem(
                            key: ValueKey(state.posts[index].id),
                            post: state.posts[index],
                          );
                        });
              }),
            ),
      floatingActionButton: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          print("state: $state");
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (state.notifications.isNotEmpty)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    FloatingActionButton(
                      mini: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      onPressed: () {
                        final index = state.posts.indexWhere((post) =>
                            post.id == state.notifications[0].questionId);
                        context.read<CommunityBloc>().add(SeenNotificationEvent(
                            notificationId: state.notifications[0].id));
                        setState(() {
                          state.notifications.removeAt(0);
                        });
                        print("index: $index");
                        if (index != -1) scrollToPostIndex(index);
                      },
                      child: const Icon(Icons.notifications,
                          color: Colors.red, size: 30),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Text(
                        state.notifications.length < 9
                            ? state.notifications.length.toString()
                            : "9+",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                heroTag: null,
                backgroundColor: const Color.fromARGB(255, 23, 165, 28),
                onPressed: toggleAskMode,
                icon: Icon(asking ? Icons.arrow_back : Icons.edit,
                    color: asking ? Colors.white : Colors.white),
                label: Text(
                    asking
                        ? AppLocalizations.of(context)!.back
                        : AppLocalizations.of(context)!.ask_question,
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void scrollToPostIndex(int index) {
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
