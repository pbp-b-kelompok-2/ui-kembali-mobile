class ForumPost {
  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isSaved,
  });

  final int id;
  final String title;
  final String content;
  final String category;
  final String author;
  final DateTime? createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        category: json['category'] as String? ?? 'LAINNYA',
        author: json['author'] as String? ?? 'Pengguna',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
        likeCount: json['like_count'] as int? ?? 0,
        commentCount: json['comment_count'] as int? ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        isSaved: json['is_saved'] as bool? ?? false,
      );
}

class ForumComment {
  const ForumComment({
    required this.id,
    required this.parentId,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.likeCount,
  });

  final int id;
  final int? parentId;
  final String content;
  final String author;
  final DateTime? createdAt;
  final int likeCount;

  factory ForumComment.fromJson(Map<String, dynamic> json) => ForumComment(
        id: json['id'] as int,
        parentId: json['parent'] as int?,
        content: json['content'] as String? ?? '',
        author: json['author'] as String? ?? 'Pengguna',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
        likeCount: json['like_count'] as int? ?? 0,
      );
}

const forumCategoryLabels = <String, String>{
  'TIPS': 'Tips',
  'TANYA': 'Tanya',
  'PENGALAMAN': 'Pengalaman',
  'LAINNYA': 'Lainnya',
};
