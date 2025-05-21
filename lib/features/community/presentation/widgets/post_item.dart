import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maize_guard/features/community/presentation/bloc/community_bloc.dart';
import 'package:maize_guard/features/help/presentation/widgets/full_screen_image_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../dependency_injection.dart';
import '../../domain/entities/post_entities.dart';
import 'reply_item.dart';

class PostItem extends StatefulWidget {
  final PostModel post;

  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool showAllReplies = false;
  List<ReplyModel> allReplies = [];

  @override
  void initState() {
    super.initState();
    allReplies = List.from(widget.post.replies);
  }

  @override
  Widget build(BuildContext context) {
    final repliesToShow =
        showAllReplies ? allReplies : allReplies.take(1).toList();
    final hasImage =
        widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty;
    final String currentUserName = "You";

    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CommunityLoaded) {
          setState(() {
            allReplies = List.from(widget.post.replies);
            showAllReplies = true;
          });
        }
      },
      builder: (context, state) {
        if (widget.post.isPosting == true) {
          return LinearProgressIndicator(
            color: Colors.amber,
          );
        }
        return Card(
          color: const Color.fromARGB(255, 255, 255, 255),
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        radius: 20,
                        child: Image(
                            image: AssetImage(
                                "assets/${widget.post.role.toLowerCase()}.png"))),
                    const SizedBox(width: 8),
                    Text("${widget.post.author} | ${widget.post.role}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 23, 165, 28),
                        )),
                    Spacer(),
                    if (widget.post.autorId ==
                            sl<SharedPreferences>().getString("userid") ||
                        sl<SharedPreferences>().getString("role") == "admin")
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditCaptionDialog();
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Question"),
                                content: const Text(
                                    "Are you sure you want to delete this question?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        context.read<CommunityBloc>().add(
                                            DeletePostEvent(
                                                questionId: widget.post.id));
                                      });

                                      Navigator.pop(ctx);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.more_vert, size: 18),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: const Color.fromARGB(255, 23, 165, 28),
                              ),
                              title: Text(
                                'Edit',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 10, 101, 175)),
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo(widget.post.createdAt),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color.fromARGB(255, 161, 159, 159)),
                ),
                const SizedBox(height: 8),
                if (hasImage) ...[
                  if (hasImage) ...[
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImagePage(image: widget.post.imageUrl!),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrl!,
                          imageBuilder: (context, imageProvider) => AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withAlpha((0.08 * 255).toInt()),
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
                                color: Colors.black
                                    .withAlpha((0.08 * 255).toInt()),
                              ),
                              child: const Center(
                                  child: CupertinoActivityIndicator()),
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
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(widget.post.question,
                      style: const TextStyle(fontSize: 16)),
                ] else ...[
                  Text(widget.post.question),
                ],
                if (sl<SharedPreferences>().getString("role") == "expert" ||
                    sl<SharedPreferences>().getString("userid") ==
                        widget.post.autorId)
                  // Reply button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _showReplySheet(widget.post.id);
                      },
                      icon: const Icon(
                        Icons.reply,
                        size: 16,
                        color: const Color.fromARGB(255, 23, 165, 28),
                      ),
                      label: const Text(
                        "Reply",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 23, 165, 28)),
                      ),
                    ),
                  ),
                const Divider(),
                ...repliesToShow.map(
                  (reply) => ReplyItem(
                    reply: reply,
                    currentUserName: currentUserName,
                    onEdit: () => _showEditReplyDialog(reply),
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Reply"),
                          content: const Text(
                              "Are you sure you want to delete this reply?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              onPressed: () {
                                setState(() {
                                  allReplies.removeWhere(
                                      (r) => r.commentId == reply.commentId);
                                });

                                context.read<CommunityBloc>().add(
                                    DeleteReplyEvent(
                                        questionId: widget.post.id,
                                        commentId: reply.commentId));
                                Navigator.pop(ctx);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (allReplies.length > 1)
                  TextButton(
                    onPressed: () {
                      setState(() => showAllReplies = !showAllReplies);
                    },
                    child: Text(
                      showAllReplies ? "See less..." : "See more...",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 23, 165, 28)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditCaptionDialog() {
    String updatedCaption = widget.post.question;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Caption"),
        content: TextFormField(
          initialValue: updatedCaption,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Edit your caption",
          ),
          onChanged: (val) => updatedCaption = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 165, 28)),
            onPressed: () {
              if (updatedCaption.trim().isNotEmpty &&
                  updatedCaption != widget.post.question) {
                context.read<CommunityBloc>().add(UpdatePostEvent(
                    questionId: widget.post.id,
                    question: updatedCaption.trim()));
                setState(() {
                  widget.post.question = updatedCaption.trim();
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditReplyDialog(ReplyModel reply) {
    String updatedMessage = reply.message;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Reply"),
        content: TextFormField(
          initialValue: updatedMessage,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Edit your reply",
          ),
          onChanged: (val) => updatedMessage = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 165, 28)),
            onPressed: () {
              if (updatedMessage.trim().isNotEmpty &&
                  updatedMessage != reply.message) {
                setState(() {
                  final index = allReplies
                      .indexWhere((r) => r.commentId == reply.commentId);
                  if (index != -1) {
                    allReplies[index] = allReplies[index].copyWith(
                      message: updatedMessage.trim(),
                    );
                  }
                });
                context.read<CommunityBloc>().add(EditReplyEvent(
                    questionId: widget.post.id,
                    commentId: reply.commentId,
                    reply: updatedMessage.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showReplySheet(String questionId) {
    String replyText = '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Write your reply",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                onChanged: (val) => replyText = val,
                decoration: const InputDecoration(
                  hintText: "Type your reply here...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 23, 165, 28))),
                onPressed: () {
                  if (replyText.trim().isNotEmpty) {
                    context.read<CommunityBloc>().add(ReplyQuestionEvent(
                        questionId: questionId, reply: replyText.trim()));
                    allReplies.add(ReplyModel(
                        commentId: "",
                        message: replyText.trim(),
                        author: "You",
                        role: sl<SharedPreferences>().getString("role") ?? "",
                        authorId:
                            sl<SharedPreferences>().getString("userid") ?? "",
                        questionId: widget.post.id,
                        createdAt: DateTime.now()));
                    showAllReplies = true;
                    Navigator.pop(ctx);
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                label: const Text(
                  "Submit Reply",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
