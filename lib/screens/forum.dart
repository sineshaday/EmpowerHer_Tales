import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: ForumPage()));
}

// Models
class ForumUser {
  final String id;
  final String name;
  final String avatar;

  const ForumUser({required this.id, required this.name, required this.avatar});
}

class ForumPost {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final ForumUser author;
  final String category;
  int upvotes;
  final List<ForumComment> comments;
  bool isUpvotedByCurrentUser;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.author,
    required this.category,
    this.upvotes = 0,
    this.comments = const [],
    this.isUpvotedByCurrentUser = false,
  });

  ForumPost copyWith({
    int? upvotes,
    bool? isUpvotedByCurrentUser,
    List<ForumComment>? comments,
  }) {
    return ForumPost(
      id: id,
      title: title,
      content: content,
      timestamp: timestamp,
      author: author,
      category: category,
      upvotes: upvotes ?? this.upvotes,
      comments: comments ?? this.comments,
      isUpvotedByCurrentUser:
          isUpvotedByCurrentUser ?? this.isUpvotedByCurrentUser,
    );
  }
}

class ForumComment {
  final String id;
  final String content;
  final DateTime timestamp;
  final ForumUser author;
  int upvotes;
  bool isUpvotedByCurrentUser;

  ForumComment({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.author,
    this.upvotes = 0,
    this.isUpvotedByCurrentUser = false,
  });

  ForumComment copyWith({int? upvotes, bool? isUpvotedByCurrentUser}) {
    return ForumComment(
      id: id,
      content: content,
      timestamp: timestamp,
      author: author,
      upvotes: upvotes ?? this.upvotes,
      isUpvotedByCurrentUser:
          isUpvotedByCurrentUser ?? this.isUpvotedByCurrentUser,
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final ForumUser sender;
  final ForumUser receiver;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sender,
    required this.receiver,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      content: content,
      timestamp: timestamp,
      sender: sender,
      receiver: receiver,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Main Forum Page
class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _showFab = true;
  late final TextEditingController _postController;
  late final TextEditingController _commentController;
  late final TextEditingController _chatMessageController;

  final List<String> _categories = [
    'All',
    'Tech',
    'Career',
    'Mental Health',
    'Gender Equality',
  ];
  String _selectedCategory = 'All';

  // Current user (mock)
  final ForumUser _currentUser = const ForumUser(
    id: 'user1',
    name: 'Sarah Johnson',
    avatar: 'assets/avatar1.png',
  );

  // Mock data
  late List<ForumPost> _posts;
  late List<ChatMessage> _chatMessages;
  late List<ForumUser> _users;

  ForumUser? _selectedChatUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _postController = TextEditingController();
    _commentController = TextEditingController();
    _chatMessageController = TextEditingController();

    _tabController.addListener(() {
    setState(() {
      _showFab = _tabController.index == 0; // Only show FAB for first tab (Discussions)
    });
  });
  
    _generateMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _commentController.dispose();
    _chatMessageController.dispose();
    super.dispose();
  }

  void _generateMockData() {
    // Mock users
    _users = const [
      ForumUser(id: 'user2', name: 'Alex Chen', avatar: 'assets/avatar2.png'),
      ForumUser(
        id: 'user3',
        name: 'Maria Garcia',
        avatar: 'assets/avatar3.png',
      ),
      ForumUser(
        id: 'user4',
        name: 'James Wilson',
        avatar: 'assets/avatar4.png',
      ),
    ];

    // Mock forum posts
    _posts = [
      ForumPost(
        id: 'post1',
        title: 'Tips for better work-life balance',
        content:
            'I\'ve been struggling with maintaining a healthy work-life balance. Any tips from the community?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        author: _users[0],
        category: 'Career',
        upvotes: 15,
        comments: [
          ForumComment(
            id: 'comment1',
            content: 'I found that setting strict boundaries helped me a lot!',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            author: _users[1],
            upvotes: 3,
          ),
          ForumComment(
            id: 'comment2',
            content: 'Try the Pomodoro technique. It worked wonders for me.',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            author: _currentUser,
            upvotes: 5,
          ),
        ],
      ),
      ForumPost(
        id: 'post2',
        title: 'Latest React Native updates discussion',
        content:
            'What do you all think about the latest React Native updates? I\'m particularly interested in the new architecture.',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        author: _users[2],
        category: 'Tech',
        upvotes: 27,
        comments: [
          ForumComment(
            id: 'comment3',
            content:
                'The new architecture is a game-changer! Much better performance.',
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
            author: _users[0],
            upvotes: 7,
          ),
        ],
      ),
      ForumPost(
        id: 'post3',
        title: 'Let\'s discuss mindfulness techniques',
        content:
            'I\'ve been practicing mindfulness for the past month and it has helped my anxiety significantly. What techniques do you use?',
        timestamp: DateTime.now().subtract(const Duration(hours: 24)),
        author: _users[1],
        category: 'Mental Health',
        upvotes: 42,
        comments: [],
      ),
    ];

    // Mock chat messages
    _chatMessages = [
      ChatMessage(
        id: 'msg1',
        content: 'Hey Sarah, did you see the new post about React Native?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        sender: _users[0],
        receiver: _currentUser,
        isRead: true,
      ),
      ChatMessage(
        id: 'msg2',
        content:
            'Yes, I found it really helpful! Are you attending the workshop next week?',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 50),
        ),
        sender: _currentUser,
        receiver: _users[0],
        isRead: true,
      ),
      ChatMessage(
        id: 'msg3',
        content: 'I was thinking about it. Want to go together?',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 45),
        ),
        sender: _users[0],
        receiver: _currentUser,
        isRead: true,
      ),
      ChatMessage(
        id: 'msg4',
        content: 'Hi Sarah, I loved your article on women in tech.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        sender: _users[1],
        receiver: _currentUser,
        isRead: false,
      ),
    ];
  }

  void _showCreatePostDialog() {
    final _postTitleController = TextEditingController();
    final _postContentController = TextEditingController();
    String dialogCategory =
        _selectedCategory == 'All' ? 'Tech' : _selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: dialogCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _categories
                              .where((category) => category != 'All')
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            dialogCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _postTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Post Title',
                        border: OutlineInputBorder(),
                        hintText: 'Enter a descriptive title',
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _postContentController,
                      decoration: const InputDecoration(
                        labelText: 'Post Content',
                        border: OutlineInputBorder(),
                        hintText: 'What would you like to discuss?',
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_postTitleController.text.isEmpty ||
                        _postContentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill in both title and content',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await addNewPost(
                      title: _postTitleController.text,
                      content: _postContentController.text,
                      category: dialogCategory,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D79),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Post Discussion'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> addNewPost({
    required String title,
    required String content,
    required String category,
  }) async {
    try {
      // Show loading indicator
      final loadingSnackBar = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Publishing your post...'),
            ],
          ),
          duration: Duration(minutes: 1),
        ),
      );

      // Create a reference to Firestore
      final postsCollection = FirebaseFirestore.instance.collection('posts');
      final newPostRef = postsCollection.doc();

      // Create the post data
      final newPost = {
        'postId': newPostRef.id,
        'title': title,
        'content': content,
        'authorId': _currentUser.id,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'upvotes': 0,
        'upvotedBy': [],
        'commentCount': 0,
      };

      // Add to Firestore
      await newPostRef.set(newPost);

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Update UI
      setState(() {
        _posts.insert(
          0,
          ForumPost(
            id: newPostRef.id,
            title: title,
            content: content,
            timestamp: DateTime.now(),
            author: _currentUser,
            category: category,
            upvotes: 0,
            comments: [],
            isUpvotedByCurrentUser: false,
          ),
        );
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _addComment(ForumPost post) {
    if (_commentController.text.isEmpty) return;

    final newComment = ForumComment(
      id: 'comment${post.comments.length + 1}',
      content: _commentController.text,
      timestamp: DateTime.now(),
      author: _currentUser,
    );

    setState(() {
      _posts =
          _posts.map((p) {
            if (p.id == post.id) {
              return p.copyWith(comments: [...p.comments, newComment]);
            }
            return p;
          }).toList();
      _commentController.clear();
    });
  }

  void _toggleUpvote(ForumPost post) {
    setState(() {
      _posts =
          _posts.map((p) {
            if (p.id == post.id) {
              return p.copyWith(
                upvotes:
                    post.isUpvotedByCurrentUser
                        ? post.upvotes - 1
                        : post.upvotes + 1,
                isUpvotedByCurrentUser: !post.isUpvotedByCurrentUser,
              );
            }
            return p;
          }).toList();
    });
  }

  void _toggleCommentUpvote(ForumComment comment, String postId) {
    setState(() {
      _posts =
          _posts.map((post) {
            if (post.id == postId) {
              final updatedComments =
                  post.comments.map((c) {
                    if (c.id == comment.id) {
                      return c.copyWith(
                        upvotes:
                            comment.isUpvotedByCurrentUser
                                ? comment.upvotes - 1
                                : comment.upvotes + 1,
                        isUpvotedByCurrentUser: !comment.isUpvotedByCurrentUser,
                      );
                    }
                    return c;
                  }).toList();
              return post.copyWith(comments: updatedComments);
            }
            return post;
          }).toList();
    });
  }

  void _sendChatMessage() {
    if (_chatMessageController.text.isEmpty || _selectedChatUser == null)
      return;

    final newMessage = ChatMessage(
      id: 'msg${_chatMessages.length + 1}',
      content: _chatMessageController.text,
      timestamp: DateTime.now(),
      sender: _currentUser,
      receiver: _selectedChatUser!,
    );

    setState(() {
      _chatMessages = [..._chatMessages, newMessage];
      _chatMessageController.clear();
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.pink,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 16),
                    const Text(
                      'Community Forum',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        // Implement search functionality
                      },
                    ),
                    //const CircleAvatar(
                    //radius: 16,
                    //backgroundColor: Colors.grey,
                    //child: Icon(Icons.person, color: Colors.white, size: 18),
                    //),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFFF4D79),
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: const Color(0xFFFF4D79),
                  tabs: const [Tab(text: 'Discussions'), Tab(text: 'Messages')],
                ),
              ),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Discussions Tab
                    _buildDiscussionsTab(),

                    // Messages Tab
                    _buildMessagesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _showFab
              //_tabController.index == 0
              ? FloatingActionButton(
                onPressed: _showCreatePostDialog,
                backgroundColor: const Color(0xFFFF4D79),
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildDiscussionsTab() {
    final filteredPosts =
        _selectedCategory == 'All'
            ? _posts
            : _posts
                .where((post) => post.category == _selectedCategory)
                .toList();

    return Column(
      children: [
        // Category Filter
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.white,
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFFFF4D79) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Post List
        Expanded(
          child:
              filteredPosts.isEmpty
                  ? const Center(child: Text('No posts found'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author info and category
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.author.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _getTimeAgo(post.timestamp),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      post.category,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Post title and content
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post.content,
                                style: const TextStyle(fontSize: 14),
                              ),

                              const SizedBox(height: 16),

                              // Engagement buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          post.isUpvotedByCurrentUser
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                          color:
                                              post.isUpvotedByCurrentUser
                                                  ? const Color(0xFFFF4D79)
                                                  : Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () => _toggleUpvote(post),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.upvotes.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.comment_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.comments.length.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      // Implement share functionality
                                    },
                                  ),
                                ],
                              ),

                              // Comments section
                              if (post.comments.isNotEmpty) ...[
                                const Divider(height: 32),
                                Text(
                                  'Comments (${post.comments.length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...post.comments.map(
                                  (comment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.grey,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    comment.author.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _getTimeAgo(
                                                      comment.timestamp,
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                comment.content,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap:
                                                        () =>
                                                            _toggleCommentUpvote(
                                                              comment,
                                                              post.id,
                                                            ),
                                                    child: Icon(
                                                      comment.isUpvotedByCurrentUser
                                                          ? Icons.thumb_up
                                                          : Icons
                                                              .thumb_up_outlined,
                                                      color:
                                                          comment.isUpvotedByCurrentUser
                                                              ? const Color(
                                                                0xFFFF4D79,
                                                              )
                                                              : Colors.grey,
                                                      size: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    comment.upvotes.toString(),
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Text(
                                                    'Reply',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              // Add comment
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _commentController,
                                      decoration: InputDecoration(
                                        hintText: 'Write a comment...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.send,
                                            color: Color(0xFFFF4D79),
                                          ),
                                          onPressed: () => _addComment(post),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    final unreadCounts = Map.fromIterable(
      _users,
      key: (user) => user.id,
      value:
          (user) =>
              _chatMessages
                  .where(
                    (msg) =>
                        msg.receiver.id == _currentUser.id &&
                        msg.sender.id == user.id &&
                        !msg.isRead,
                  )
                  .length,
    );

    final chatUsers =
        _users.where((user) => user.id != _currentUser.id).toList();

    return Column(
      children: [
        // User list
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: chatUsers.length,
            itemBuilder: (context, index) {
              final user = chatUsers[index];
              final unreadCount = unreadCounts[user.id] ?? 0;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedChatUser = user;
                    // Mark messages as read when opening chat
                    _chatMessages =
                        _chatMessages.map((msg) {
                          if (msg.receiver.id == _currentUser.id &&
                              msg.sender.id == user.id) {
                            return msg.copyWith(isRead: true);
                          }
                          return msg;
                        }).toList();
                  });
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(left: 8),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4D79),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name.split(' ')[0],
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Chat messages
        Expanded(
          child:
              _selectedChatUser == null
                  ? const Center(child: Text('Select a user to start chatting'))
                  : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Chat header
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedChatUser!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Messages list
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            itemCount:
                                _chatMessages
                                    .where(
                                      (msg) =>
                                          (msg.sender.id == _currentUser.id &&
                                              msg.receiver.id ==
                                                  _selectedChatUser!.id) ||
                                          (msg.sender.id ==
                                                  _selectedChatUser!.id &&
                                              msg.receiver.id ==
                                                  _currentUser.id),
                                    )
                                    .length,
                            itemBuilder: (context, index) {
                              final messages =
                                  _chatMessages
                                      .where(
                                        (msg) =>
                                            (msg.sender.id == _currentUser.id &&
                                                msg.receiver.id ==
                                                    _selectedChatUser!.id) ||
                                            (msg.sender.id ==
                                                    _selectedChatUser!.id &&
                                                msg.receiver.id ==
                                                    _currentUser.id),
                                      )
                                      .toList()
                                      .reversed
                                      .toList();
                              final message = messages[index];
                              final isCurrentUser =
                                  message.sender.id == _currentUser.id;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      isCurrentUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    if (!isCurrentUser) ...[
                                      const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            isCurrentUser
                                                ? const Color(0xFFFF4D79)
                                                : Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft:
                                              isCurrentUser
                                                  ? const Radius.circular(12)
                                                  : const Radius.circular(0),
                                          bottomRight:
                                              isCurrentUser
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        message.content,
                                        style: TextStyle(
                                          color:
                                              isCurrentUser
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (isCurrentUser) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        _getTimeAgo(message.timestamp),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Message input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatMessageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFFF4D79),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: _sendChatMessage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        ),
      ],
    );
  }
}
