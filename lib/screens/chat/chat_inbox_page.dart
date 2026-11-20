import 'package:material_ui/material_ui.dart';

import '../../models/chat.dart';
import '../../services/chat_api.dart';
import '../../services/katalog_api.dart';
import '../../theme.dart';
import 'chat_conversation_page.dart';

class ChatInboxPage extends StatefulWidget {
  const ChatInboxPage({super.key, this.api, this.katalogApi});

  final ChatApi? api;
  final KatalogApi? katalogApi;

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {
  late final ChatApi _api = widget.api ?? ChatApi();
  late final KatalogApi _katalogApi = widget.katalogApi ?? KatalogApi();
  List<ChatConversation> _conversations = const [];
  bool _loading = true;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _api.fetchConversations();
      if (!mounted) return;
      setState(() {
        _conversations = rows;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _open(ChatConversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationPage(conversation: conversation, chatApi: _api, katalogApi: _katalogApi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading && _conversations.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null && _conversations.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text(_error!.needsLogin ? 'Masuk dulu untuk melihat pesan.' : _error!.message, textAlign: TextAlign.center)),
                  if (!_error!.needsLogin)
                    Center(
                      child: TextButton(onPressed: _load, child: const Text('Coba lagi')),
                    ),
                ],
              )
            : _conversations.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(Icons.chat_bubble_outline, size: 44, color: AppColors.muted),
                  SizedBox(height: 12),
                  Center(child: Text('Belum ada percakapan.')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _conversations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return _ConversationTile(conversation: conversation, onTap: () => _open(conversation));
                },
              ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: AppColors.greenTint, foregroundColor: AppColors.greenDark, child: Icon(Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.itemName,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text('${conversation.buyer} · ${conversation.seller}', style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                    const SizedBox(height: 6),
                    Text(
                      conversation.latestMessage ?? 'Belum ada pesan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
