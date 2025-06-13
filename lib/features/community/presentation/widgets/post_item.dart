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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class PostItem extends StatefulWidget {
  final PostModel post;

  const PostItem({
    super.key,
    required this.post,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem>
    with SingleTickerProviderStateMixin {
  bool showComments = false;
  List<ReplyModel> allReplies = [];
  final int commentsPerPage = 5;
  int visibleCommentsCount = 5;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    allReplies = List.from(widget.post.replies);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleComments() {
    setState(() {
      showComments = !showComments;
      if (showComments) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showMoreComments() {
    setState(() {
      visibleCommentsCount += commentsPerPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty;
    final String currentUserName = "You";
    final repliesToShow = allReplies.take(visibleCommentsCount).toList();
    final sl = GetIt.instance;

    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CommunityLoaded) {
          final updatedPost = state.posts.firstWhere(
            (p) => p.id == widget.post.id,
            orElse: () => widget.post,
          );
          setState(() {
            allReplies = List.from(updatedPost.replies);
          });
        }
      },
      builder: (context, state) {
        if (widget.post.isPosting == true) {
          return const LinearProgressIndicator(
            color: Colors.amber,
            backgroundColor: Colors.amberAccent,
          );
        }
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggleComments,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        foregroundImage: Image.asset(
                          "assets/${widget.post.role.toLowerCase()}.png",
                        ).image,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.post.author} | ${getTranslatedRole(context, widget.post.role)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                            ),
                            Text(
                              timeAgo(widget.post.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.post.autorId ==
                              sl<SharedPreferences>().getString("userid") ||
                          sl<SharedPreferences>().getString("role") == "admin")
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert,
                              color: Colors.grey.shade600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit,
                                    color: Colors.green.shade700),
                                title: Text(AppLocalizations.of(context)!.edit),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete,
                                    color: Colors.red.shade700),
                                title:
                                    Text(AppLocalizations.of(context)!.delete),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCaptionDialog();
                            } else if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(AppLocalizations.of(context)!
                                      .delete_question),
                                  content: Text(AppLocalizations.of(context)!
                                      .confirm_delete_question),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(
                                          AppLocalizations.of(context)!.cancel),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade700,
                                      ),
                                      onPressed: () {
                                        context.read<CommunityBloc>().add(
                                              DeletePostEvent(
                                                  questionId: widget.post.id),
                                            );
                                        Navigator.pop(ctx);
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.delete),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Image
                  if (hasImage) ...[
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImagePage(image: widget.post.imageUrl!),
                        ),
                      ),
                      child: Hero(
                        tag: widget.post.imageUrl!,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.post.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(
                                  child: CupertinoActivityIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Question
                  Text(
                    widget.post.question,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.post.replies.length} ${AppLocalizations.of(context)!.reply}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (sl<SharedPreferences>().getString("role") ==
                              "expert" ||
                          sl<SharedPreferences>().getString("userid") ==
                              widget.post.autorId)
                        TextButton.icon(
                          onPressed: () {
                            _showReplySheet(widget.post.id);
                          },
                          icon: Icon(Icons.reply,
                              color: Colors.green.shade700, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.reply,
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                    ],
                  ),
                  // Comments section
                  if (showComments && allReplies.isNotEmpty) ...[
                    const Divider(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          ...repliesToShow.map((reply) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Align(
                                  alignment: reply.authorId ==
                                          sl<SharedPreferences>()
                                              .getString("userid")
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    child: ReplyItem(
                                      reply: reply,
                                      currentUserName: currentUserName,
                                      onEdit: () => _showEditReplyDialog(reply),
                                      onDelete: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .delete_reply),
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .confirm_delete_reply),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .cancel),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade700,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    allReplies.removeWhere(
                                                        (r) =>
                                                            r.commentId ==
                                                            reply.commentId);
                                                  });
                                                  context
                                                      .read<CommunityBloc>()
                                                      .add(
                                                        DeleteReplyEvent(
                                                          questionId:
                                                              widget.post.id,
                                                          commentId:
                                                              reply.commentId,
                                                        ),
                                                      );
                                                  Navigator.pop(ctx);
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .delete),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )),
                          if (allReplies.length > visibleCommentsCount)
                            TextButton(
                              onPressed: _showMoreComments,
                              child: Text(
                                "${AppLocalizations.of(context)!.see_more} ...",
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String getTranslatedRole(BuildContext context, String role) {
    switch (role) {
      case 'farmer':
        return AppLocalizations.of(context)!.farmer;
      case 'expert':
        return AppLocalizations.of(context)!.expert;
      case 'admin':
        return AppLocalizations.of(context)!.admin;
      default:
        return role;
    }
  }

  void _showEditCaptionDialog() {
    String updatedCaption = widget.post.question;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.edit_caption),
        content: TextFormField(
          initialValue: updatedCaption,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: AppLocalizations.of(context)!.edit_your_caption,
          ),
          onChanged: (val) => updatedCaption = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(
              AppLocalizations.of(context)!.save,
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
        title: Text(AppLocalizations.of(context)!.edit_reply),
        content: TextFormField(
          initialValue: updatedMessage,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: AppLocalizations.of(context)!.edit_your_reply,
          ),
          onChanged: (val) => updatedMessage = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(
              AppLocalizations.of(context)!.save,
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
              Text(AppLocalizations.of(context)!.write_reply,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                onChanged: (val) => replyText = val,
                decoration: InputDecoration(
                  hintText:
                      "${AppLocalizations.of(context)!.type_reply_here} . . .",
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
                    Navigator.pop(ctx);
                  }
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                label: Text(
                  AppLocalizations.of(context)!.submit_reply,
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
