import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../models/chat.dart';
import '../../models/item.dart';
import '../../services/chat_api.dart';
import '../../services/katalog_api.dart';
import '../../theme.dart';

const _messagePollingInterval = Duration(seconds: 3);

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({
    super.key,
    required this.conversation,
    this.item,
    this.chatApi,
    this.katalogApi,
    this.autoRefresh = true,
  });

  final ChatConversation conversation;
  final Item? item;
  final ChatApi? chatApi;
  final KatalogApi? katalogApi;
  final bool autoRefresh;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  late final ChatApi _chatApi = widget.chatApi ?? ChatApi();
  late final KatalogApi _katalogApi = widget.katalogApi ?? KatalogApi();
  late final Future<Item?> _itemFuture = widget.item == null
      ? _katalogApi.fetchItem(widget.conversation.itemId)
      : Future.value(widget.item);
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  bool _refreshing = false;
  ApiException? _error;
  Timer? _polling;
  String _counterpart = '';
  bool _isSeller = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    if (widget.autoRefresh) {
      _polling = Timer.periodic(_messagePollingInterval, (_) => _loadMessages(quiet: true));
    }
  }

  @override
  void dispose() {
    _polling?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool quiet = false}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (!quiet && mounted) {
      setState(() {
        if (_messages.isEmpty) _loading = true;
        _error = null;
      });
    }
    try {
      final messages = await _chatApi.fetchMessages(widget.conversation.id);
      if (!mounted) return;
      final changed =
          messages.length != _messages.length ||
          (messages.isNotEmpty && _messages.isNotEmpty && messages.last.id != _messages.last.id);
      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      if (changed || _messages.length <= 1) _scrollToBottom();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!quiet || _messages.isEmpty) _error = error;
      });
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _send() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      final message = await _chatApi.sendMessage(widget.conversation.id, body);
      if (!mounted) return;
      _messageController.clear();
      setState(() {
        _messages = [..._messages, message];
        _sending = false;
      });
      _scrollToBottom();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.needsLogin ? 'Masuk dulu untuk mengirim pesan.' : error.message)));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _timeLabel(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Item?>(
      future: _itemFuture,
      builder: (context, snapshot) {
        final item = snapshot.data;
        _isSeller = item?.isOwner ?? false;
        _counterpart = widget.conversation.counterpart(isSeller: _isSeller);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 30),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_counterpart, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Text('Chat barang', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
              ],
            ),
          ),
          body: Column(
            children: [
              _ItemSummary(item: item, conversation: widget.conversation),
              Expanded(child: _messageBody()),
              _composer(),
            ],
          ),
        );
      },
    );
  }

  Widget _messageBody() {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!.needsLogin ? 'Masuk dulu untuk membuka percakapan.' : _error!.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (!_error!.needsLogin) TextButton(onPressed: _loadMessages, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return ListView(
        controller: _scrollController,
        children: const [
          SizedBox(height: 40),
          Center(child: Text('Mulai percakapan dengan mengirim pesan.')),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final showDate = index == 0 || !_sameDay(message.sentAt, _messages[index - 1].sentAt);
          final mine = message.senderName != _counterpart;
          return Column(
            children: [
              if (showDate) _DateDivider(date: message.sentAt),
              Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: _MessageBubble(message: message, mine: mine, time: _timeLabel(message.sentAt)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        decoration: const BoxDecoration(color: AppColors.canvas),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pesan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 3,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Tulis pesan...',
                counterText: '',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.ink,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(_sending ? 'Mengirim...' : 'Kirim pesan'),
            ),
          ],
        ),
      ),
    );
  }
}

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month && first.day == second.day;

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${date.day} ${months[date.month - 1]} ${date.year}',
          style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.mine, required this.time});

  final ChatMessage message;
  final bool mine;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .84),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: mine ? AppColors.greenTint : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.body, style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.ink)),
          const SizedBox(height: 6),
          Text(
            mine && message.isRead ? '$time · Dibaca' : time,
            style: const TextStyle(fontSize: 10, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _ItemSummary extends StatelessWidget {
  const _ItemSummary({required this.item, required this.conversation});

  final Item? item;
  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item != null && item!.photoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Image.network(
                  item!.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _ItemPhotoPlaceholder(),
                ),
              ),
            )
          else
            const _ItemPhotoPlaceholder(height: 84),
          const SizedBox(height: 10),
          Text(
            item?.name ?? conversation.itemName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          if (item != null) ...[
            const SizedBox(height: 4),
            Text(
              '${item!.priceLabel} · ${conversation.seller}',
              style: const TextStyle(fontSize: 12, color: AppColors.greenDark),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemPhotoPlaceholder extends StatelessWidget {
  const _ItemPhotoPlaceholder({this.height = 84});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const ColoredBox(
      color: AppColors.subtle,
      child: Center(child: Icon(Icons.image_outlined, color: AppColors.muted)),
    ),
  );
}
