import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  Future<void> _startNewChat(BuildContext context) async {
    final colors = context.colors;
    final controller = TextEditingController();

    final userId = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Start a chat'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'User ID',
            helperText: 'Temporary — replace with a proper user search later',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(int.tryParse(controller.text.trim())),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (userId == null || !context.mounted) return;

    final conversation =
        await context.read<ChatProvider>().startPrivateChat(userId);

    if (!context.mounted) return;

    if (conversation != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversation.id,
            title: conversation.displayName,
          ),
        ),
      );
    } else {
      final error = context.read<ChatProvider>().conversationsError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Could not start chat.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final chatProvider = context.watch<ChatProvider>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgBottom,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context),
        backgroundColor: colors.primaryStart,
        child:
            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<ChatProvider>().loadConversations(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hey, ${user.name.split(' ').first} 👋',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${user.username}',
                                  style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            _IconAction(
                              icon: Icons.settings_outlined,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: Text('Chats',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    if (chatProvider.isLoadingConversations)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (chatProvider.conversationsError != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            chatProvider.conversationsError!,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      )
                    else if (chatProvider.conversations.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              'No conversations yet.\nTap the button below to start one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList.separated(
                          itemCount: chatProvider.conversations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => _ChatTile(
                              conversation: chatProvider.conversations[index]),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ConversationModel conversation;
  const _ChatTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUnread = conversation.unreadCount > 0;
    final preview = conversation.lastMessage?.body ?? 'No messages yet';
    final time = conversation.lastMessage != null
        ? _formatTime(conversation.lastMessage!.createdAt)
        : '';
    final avatarColor = colors.primaryStart;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conversation.id,
                title: conversation.displayName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor.withOpacity(0.16),
                child: Text(
                  conversation.displayName.isNotEmpty
                      ? conversation.displayName.characters.first.toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? colors.primaryStart
                                : colors.textSecondary,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: hasUnread
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                              fontWeight:
                                  hasUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: colors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${dt.day}/${dt.month}';
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: colors.textPrimary),
        ),
      ),
    );
  }
}
