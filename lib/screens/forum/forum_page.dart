import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../models/forum_post.dart';
import '../../services/forum_api.dart';
import '../../theme.dart';

const _forumSearchDebounce = Duration(milliseconds: 350);

class ForumPage extends StatefulWidget {
  const ForumPage({super.key, this.api});

  final ForumApi? api;

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late final ForumApi _api = widget.api ?? ForumApi();
  final _searchController = TextEditingController();
  Timer? _debounce;
  late Future<List<ForumPost>> _posts;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _posts = _api.fetchPosts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _load({String? search}) {
    final nextSearch = search ?? _search;
    setState(() {
      _search = nextSearch;
      _posts = _api.fetchPosts(search: nextSearch);
    });
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(_forumSearchDebounce, () => _load(search: value));
  }

  Future<void> _openCreatePost() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => ForumCreatePage(api: _api)),
    );
    if (created == true && mounted) _load(search: '');
  }

  Future<void> _refresh() async {
    final future = _api.fetchPosts(search: _search);
    setState(() => _posts = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder renders the request error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Komunitas'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.subtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_outlined, color: AppColors.greenDark, size: 24),
                  const SizedBox(height: 18),
                  Text(
                    'Berbagi, bertanya, dan tumbuh bersama',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Temukan inspirasi dan diskusikan gaya hidup berkelanjutan bersama komunitas UIKembali.',
                    style: TextStyle(color: AppColors.inkSoft, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari diskusi',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          _load(search: '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openCreatePost,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.ink,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Buat postingan'),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ForumPost>>(
              future: _posts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ForumMessage(
                    icon: Icons.cloud_off_outlined,
                    message: snapshot.error is ForumApiException
                        ? (snapshot.error! as ForumApiException).message
                        : 'Forum belum dapat dimuat. Periksa koneksi dan alamat API.',
                    actionLabel: 'Coba lagi',
                    onAction: _refresh,
                  );
                }
                final posts = snapshot.data ?? const <ForumPost>[];
                if (posts.isEmpty) {
                  return _ForumMessage(
                    icon: Icons.forum_outlined,
                    message: _search.isEmpty
                        ? 'Belum ada diskusi.'
                        : 'Tidak ada diskusi yang cocok dengan pencarian.',
                    actionLabel: _search.isEmpty ? null : 'Hapus pencarian',
                    onAction: _search.isEmpty
                        ? null
                        : () {
                            _searchController.clear();
                            _load(search: '');
                          },
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _ForumPostCard(
                      post: posts[index],
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => ForumDetailPage(
                            api: _api,
                            post: posts[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumPostCard extends StatelessWidget {
  const _ForumPostCard({required this.post, required this.onTap});

  final ForumPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = forumCategoryLabels[post.category] ?? 'Lainnya';
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.greenTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: AppColors.greenDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (post.createdAt != null)
                    Text(
                      _shortDate(post.createdAt!),
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.inkSoft, height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      post.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.favorite_border, size: 16, color: AppColors.inkSoft),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  const Icon(Icons.mode_comment_outlined, size: 16, color: AppColors.inkSoft),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForumCreatePage extends StatefulWidget {
  const ForumCreatePage({super.key, required this.api});

  final ForumApi api;

  @override
  State<ForumCreatePage> createState() => _ForumCreatePageState();
}

class _ForumCreatePageState extends State<ForumCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'TANYA';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.api.createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _category,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ForumApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat posting')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Mulai percakapan baru',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bagikan pertanyaan, tips, atau pengalamanmu dengan komunitas.',
              style: TextStyle(color: AppColors.inkSoft, height: 1.45),
            ),
            const SizedBox(height: 28),
            const _ForumFieldLabel('Kategori'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _forumInputDecoration('Pilih kategori'),
              items: forumCategoryLabels.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 22),
            const _ForumFieldLabel('Judul postingan'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: _forumInputDecoration('Tulis judul yang jelas'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Judul wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 12),
            const _ForumFieldLabel('Isi diskusi'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              minLines: 7,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: _forumInputDecoration('Ceritakan hal yang ingin kamu diskusikan'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Isi diskusi wajib diisi.'
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.ink,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publikasikan postingan'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumFieldLabel extends StatelessWidget {
  const _ForumFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      );
}

InputDecoration _forumInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
    );

class ForumDetailPage extends StatefulWidget {
  const ForumDetailPage({super.key, required this.api, required this.post});

  final ForumApi api;
  final ForumPost post;

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  late Future<ForumPost> _detail;
  late Future<List<ForumComment>> _comments;

  @override
  void initState() {
    super.initState();
    _detail = widget.api.fetchPost(widget.post.id);
    _comments = widget.api.fetchComments(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diskusi')),
      body: FutureBuilder<ForumPost>(
        future: _detail,
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (postSnapshot.hasError) {
            return _ForumMessage(
              icon: Icons.cloud_off_outlined,
              message: postSnapshot.error is ForumApiException
                  ? (postSnapshot.error! as ForumApiException).message
                  : 'Detail diskusi belum dapat dimuat.',
            );
          }
          final post = postSnapshot.data ?? widget.post;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.greenTint,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              forumCategoryLabels[post.category] ?? 'Lainnya',
              style: const TextStyle(
                color: AppColors.greenDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            post.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.greenTint,
                child: Text(
                  post.author.isEmpty ? '?' : post.author[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              if (post.createdAt != null)
                Text(
                  _shortDate(post.createdAt!),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(post.content, style: const TextStyle(color: AppColors.ink, height: 1.5)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Komentar', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 8),
              Text('(${post.commentCount})', style: const TextStyle(color: AppColors.inkSoft)),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<ForumComment>>(
            future: _comments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  snapshot.error is ForumApiException
                      ? (snapshot.error! as ForumApiException).message
                      : 'Komentar belum dapat dimuat.',
                  style: const TextStyle(color: AppColors.inkSoft),
                );
              }
              final comments = snapshot.data ?? const <ForumComment>[];
              if (comments.isEmpty) {
                return const Text(
                  'Belum ada komentar.',
                  style: TextStyle(color: AppColors.inkSoft),
                );
              }
              return Column(
                children: comments
                    .map((comment) => _ForumCommentTile(comment: comment))
                    .toList(),
              );
            },
          ),
            ],
          );
        },
      ),
    );
  }
}

class _ForumCommentTile extends StatelessWidget {
  const _ForumCommentTile({required this.comment});

  final ForumComment comment;

  @override
  Widget build(BuildContext context) {
    final isReply = comment.parentId != null;
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 24 : 0, bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.subtle,
            child: Icon(
              isReply ? Icons.subdirectory_arrow_right : Icons.person_outline,
              color: AppColors.green,
            ),
          ),
          title: Text(comment.author, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(comment.content),
          ),
          trailing: comment.likeCount == 0
              ? null
              : Text('♥ ${comment.likeCount}', style: const TextStyle(color: AppColors.inkSoft)),
        ),
      ),
    );
  }
}

class _ForumMessage extends StatelessWidget {
  const _ForumMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.inkSoft)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

String _shortDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}
