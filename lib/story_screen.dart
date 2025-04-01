import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<Story> stories = [
    Story(
      id: '1',
      title: 'Women in Tech Breaking Barriers',
      content: 'A group of women engineers have developed a new AI system that helps identify and prevent gender bias in hiring processes.',
      author: 'Lucy Huddleston',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 28,
      comments: [
        Comment(
          author: 'Sarah',
          content: 'This is so inspiring! Thank you for sharing this story.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Comment(
          author: 'Jessica',
          content: 'We need more initiatives like this! 👏',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
      readTime: '4min read',
    ),
    Story(
      id: '2',
      title: 'Tech companies commit to digital inclusion initiative',
      content: 'Several major tech companies announced a new coalition to improve digital access for underserved communities worldwide.',
      author: 'Samantha Chen',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 45,
      comments: [
        Comment(
          author: 'Michelle',
          content: 'This is a step in the right direction!',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
      readTime: '3min read',
    ),
    Story(
      id: '3',
      title: 'Female-led startup raises \$10M for education platform',
      content: 'A startup focused on providing STEM education to girls in rural areas has secured major funding to expand their operations.',
      author: 'Maria Rodriguez',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      likes: 67,
      comments: [],
      readTime: '5min read',
    ),
    Story(
      id: '4',
      title: 'Women\'s leadership summit announces global expansion',
      content: 'The annual women\'s leadership summit will now be held in 10 countries, bringing together female leaders from diverse backgrounds.',
      author: 'Priya Sharma',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 93,
      comments: [],
      readTime: '6min read',
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Story'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.image, color: Colors.grey),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Image picker would go here in a real app
                    },
                    child: const Text('Add Image'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _titleController.clear();
              _contentController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _uploadStory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
            ),
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _uploadStory() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    Navigator.of(context).pop();

    // Show uploading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
            ),
            SizedBox(height: 16),
            Text('Uploading your story...'),
          ],
        ),
      ),
    );

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      // Get current timestamp
      final now = DateTime.now();
      
      // Add the new story to the list
      setState(() {
        stories.insert(
          0,
          Story(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            content: _contentController.text,
            author: 'You',
            timestamp: now,
            likes: 0,
            comments: [],
            readTime: '1min read',
          ),
        );
        _isUploading = false;
      });

      // Clear the text fields
      _titleController.clear();
      _contentController.clear();

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success message
      _showUploadSuccessDialog(now);
    });
  }

  void _showUploadSuccessDialog(DateTime timestamp) {
    final formattedTime = DateFormat('MMM d, yyyy • h:mm a').format(timestamp);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFC0CB),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Story Uploaded Successfully!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Posted on $formattedTime',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFC0CB),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB6C1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFF0F5),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            return StoryCard(
              story: stories[index],
              onCommentAdded: (storyId, comment) {
                setState(() {
                  final storyIndex = stories.indexWhere((s) => s.id == storyId);
                  if (storyIndex != -1) {
                    stories[storyIndex].comments.add(comment);
                  }
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        backgroundColor: const Color(0xFFFF69B4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class Comment {
  final String author;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.author,
    required this.content,
    required this.timestamp,
  });
}

class Story {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime timestamp;
  final int likes;
  final List<Comment> comments;
  final String readTime;
  bool isLiked = false;
  bool isSaved = false;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.readTime,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

class StoryCard extends StatefulWidget {
  final Story story;
  final Function(String storyId, Comment comment) onCommentAdded;

  const StoryCard({
    super.key,
    required this.story,
    required this.onCommentAdded,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  final TextEditingController _commentController = TextEditingController();
  bool showComments = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      author: 'You',
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    widget.onCommentAdded(widget.story.id, newComment);
    _commentController.clear();

    // Show a snackbar to confirm the comment was added
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatCommentTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = DateTime.now().difference(widget.story.timestamp).inMinutes < 5;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFFFD1DC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'New',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Text(
              widget.story.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.story.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  widget.story.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: isNew ? Colors.green : Colors.black45,
                    fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Text(' • ', style: TextStyle(color: Colors.black45)),
                Text(
                  'By ${widget.story.author}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
                const Text(' • ', style: TextStyle(color: Colors.black45)),
                Text(
                  widget.story.readTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.story.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: widget.story.isLiked ? Colors.red : Colors.black54,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.story.isLiked = !widget.story.isLiked;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.story.likes.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black54,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          showComments = !showComments;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.story.comments.length.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    widget.story.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.story.isSaved = !widget.story.isSaved;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            if (showComments) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.story.comments.length})',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Comment input field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFFFF69B4)),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Comments list
                    if (widget.story.comments.isEmpty)
                      const Text(
                        'No comments yet. Be the first to comment!',
                        style: TextStyle(
                          color: Colors.black45,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.story.comments.length,
                        itemBuilder: (context, index) {
                          final comment = widget.story.comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment.author,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _formatCommentTime(comment.timestamp),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(comment.content),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

