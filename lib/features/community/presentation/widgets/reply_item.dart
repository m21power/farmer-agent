import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../dependency_injection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/post_entities.dart';

class ReplyItem extends StatelessWidget {
  final ReplyModel reply;
  final String currentUserName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReplyItem({
    super.key,
    required this.reply,
    required this.currentUserName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        reply.authorId == sl<SharedPreferences>().getString("userid");
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7, // 75% width
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  isCurrentUser ? const Radius.circular(12) : Radius.zero,
              bottomRight:
                  isCurrentUser ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 20,
                            child: Image(
                                image: AssetImage(
                                    "assets/${reply.role.toLowerCase()}.png"))),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          isCurrentUser
                              ? "You"
                              : "${reply.author} | ${getTranslatedRole(context, reply.role)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 23, 165, 28),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(reply.message),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo(reply.createdAt),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color.fromARGB(255, 161, 159, 159)),
                    ),
                  ],
                ),
              ),
              if (isCurrentUser ||
                  sl<SharedPreferences>().getString("role") == "admin")
                Positioned(
                  top: -15,
                  right: -20,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: const Color.fromARGB(255, 23, 165, 28),
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.edit,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 23, 165, 28)),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.delete,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 18), // smaller icon
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hours ago";
  if (diff.inDays < 7) return "${diff.inDays} days ago";
  return "${date.day}/${date.month}/${date.year}";
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
      return role; // fallback
  }
}
