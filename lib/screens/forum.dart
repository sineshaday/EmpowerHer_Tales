import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: ForumPage()));
}

class ForumUser {
  final String id;
  final String name;
  final String avatar;
  final bool isMock;

  const ForumUser({
    required this.id,
    required this.name,
    required this.avatar,
    this.isMock = false,
  });

  static ForumUser mockUser() {
    return const ForumUser(
      id: 'mock_user',
      name: 'Mock User',
      avatar: 'assets/default_avatar.png',
      isMock: true,
    );
  }
}

class ForumPost {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final ForumUser author;
  final String authorId;
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
    required this.authorId,
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
      authorId: authorId,
      category: category,
      upvotes: upvotes ?? this.upvotes,
      comments: comments ?? this.comments,
      isUpvotedByCurrentUser: isUpvotedByCurrentUser ?? this.isUpvotedByCurrentUser,
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
      isUpvotedByCurrentUser: isUpvotedByCurrentUser ?? this.isUpvotedByCurrentUser,
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      content: data['content'],
      timestamp: data['timestamp'].toDate(),
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      isRead: data['isRead'] ?? false,
    );
  }
}

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<ForumUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return ForumUser(
          id: userId,
          name: doc['name'],
          avatar: doc['avatar'] ?? 'assets/default_avatar.png',
        );
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user: $e");
      return null;
    }
  }

  static Stream<List<ForumUser>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ForumUser(
          id: doc.id,
          name: doc['name'],
          avatar: doc['avatar'] ?? 'assets/default_avatar.png',
        );
      }).toList();
    });
  }
}

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with SingleTickerProviderStateMixin {
  late final TabController tabController;
  bool showFab = true;
  late final TextEditingController postController;
  late final TextEditingController commentController;
  late final TextEditingController chatMessageController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _postsStream;

  final List<String> categories = [
    'All',
    'Tech',
    'Career',
    'Mental Health',
    'Gender Equality',
  ];
  String selectedCategory = 'All';

  late ForumUser currentUser = ForumUser.mockUser();
  List<ForumPost> posts = [];
  List<ForumUser> users = [];
  ForumUser? selectedChatUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    postController = TextEditingController();
    commentController = TextEditingController();
    chatMessageController = TextEditingController();

    

    tabController.addListener(() {
      setState(() {
        showFab = tabController.index == 0;
      });
    });

    _initializeUser();

    _postsStream = _firestore.collection('posts')
    .orderBy('timestamp', descending: true)  // EDIT: Added sorting
    .snapshots();
  }

  Future<void> _initializeUser() async {
    try {
      final currentAuthUser = FirebaseAuth.instance.currentUser;
      if (currentAuthUser != null) {
        final user = await UserService.getUser(currentAuthUser.uid);
        if (user != null) {
          setState(() {
            currentUser = user;
            isLoadingUser = false;
          });
          _loadPosts();
          return;
        }
      }
      setState(() => isLoadingUser = false);
    } catch (e) {
      setState(() => isLoadingUser = false);
      debugPrint('Error initializing user: $e');
    }
  }

  Future<void> _loadPosts() async {
    try {
      final snapshot = await firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();
      final usersList = await UserService.getUsers().first;

      setState(() {
        users = usersList.where((user) => user.id != currentUser.id).toList();
        posts = snapshot.docs.map((doc) {
          final author = usersList.firstWhere(
            (user) => user.id == doc['authorId'],
            orElse: () => currentUser,
          );
          return ForumPost(
            id: doc.id,
            title: doc['title'],
            content: doc['content'],
            timestamp: doc['timestamp'].toDate(),
            author: author,
            authorId: doc['authorId'],
            category: doc['category'],
            upvotes: doc['upvotes'] ?? 0,
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Using mock data due to error: $e');
      _generateMockData();
    }
  }

  void _generateMockData() {
    users = [
      const ForumUser(
        id: 'user2',
        name: 'Alex Chen',
        avatar: 'assets/avatar2.png',
        isMock: true,
      ),
      const ForumUser(
        id: 'user3',
        name: 'Maria Garcia',
        avatar: 'assets/avatar3.png',
        isMock: true,
      ),
      const ForumUser(
        id: 'user4',
        name: 'James Wilson',
        avatar: 'assets/avatar4.png',
        isMock: true,
      ),
    ];

    final postAuthor = currentUser.isMock ? users[0] : currentUser;

    posts = [
      ForumPost(
        id: 'post1',
        title: 'Tips for better work-life balance',
        content: 'I\'ve been struggling with maintaining a healthy work-life balance.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        author: postAuthor,
        authorId: postAuthor.id,
        category: 'Career',
        upvotes: 15,
        comments: [
          ForumComment(
            id: 'comment1',
            content: 'I found that setting strict boundaries helped me a lot!',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            author: users[1],
          ),
        ],
      ),
    ];
  }

  // ... [Rest of your methods remain unchanged] ...

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[100],
          child: Column(
            children: [
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
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
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
                  controller: tabController,
                  labelColor: const Color(0xFFFF4D79),
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: const Color(0xFFFF4D79),
                  tabs: const [Tab(text: 'Discussions'), Tab(text: 'Messages')],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _buildDiscussionsTab(),
                    _buildMessagesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: const Color(0xFFFF4D79),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDiscussionsTab() {
    final filteredPosts = selectedCategory == 'All'
        ? posts
        : posts.where((post) => post.category == selectedCategory).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.white,
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF4D79) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: filteredPosts.isEmpty
              ? const Center(child: Text('No posts found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return _buildPostCard(post);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPostCard(ForumPost post) {
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
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                if (post.authorId == currentUser.id)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deletePost(post.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isUpvotedByCurrentUser
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: post.isUpvotedByCurrentUser
                            ? const Color(0xFFFF4D79)
                            : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => _toggleUpvote(post),
                    ),
                    Text(post.upvotes.toString()),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment_outlined, size: 20),
                    const SizedBox(width: 4),
                    Text(post.comments.length.toString()),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            if (post.comments.isNotEmpty) ...[
              const Divider(height: 32),
              Text('Comments (${post.comments.length})'),
              const SizedBox(height: 12),
              ...post.comments.map((comment) => _buildCommentTile(post.id, comment)),
            ],
            const Divider(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFFFF4D79)),
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
  }

  Widget _buildPostList() {
  return StreamBuilder<QuerySnapshot>(
    stream: _postsStream,  // EDIT: Using the stream we created
    builder: (context, snapshot) {
      // EDIT: Added proper error and loading states
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final posts = snapshot.data!.docs;

      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(post['title']),
              subtitle: Text(post['content']),
              trailing: Text(post['category']),
              // EDIT: Added timestamp display
              leading: Text(
                '${post['timestamp']?.toDate().toString().substring(0, 10) ?? ''}',
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _buildCommentTile(String postId, ForumComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(comment.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCommentUpvote(comment, postId),
                      child: Icon(
                        comment.isUpvotedByCurrentUser
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: comment.isUpvotedByCurrentUser
                            ? const Color(0xFFFF4D79)
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
                    const Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (comment.author.id == currentUser.id) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _deleteComment(postId, comment.id),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: StreamBuilder<List<ForumUser>>(
            stream: UserService.getUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final usersList = snapshot.data!
                  .where((user) => user.id != currentUser.id)
                  .toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  final user = usersList[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedChatUser = user;
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(left: 8),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(user.avatar),
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
              );
            },
          ),
        ),
        Expanded(
          child: selectedChatUser == null
              ? const Center(child: Text('Select a user to start chatting'))
              : StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('chats')
                      .doc(_getChatId(currentUser.id, selectedChatUser!.id))
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs
                        .map((doc) => ChatMessage.fromFirestore(doc))
                        .toList();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(selectedChatUser!.avatar),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedChatUser!.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Expanded(
                            child: ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isCurrentUser = message.senderId == currentUser.id;
                                return _buildMessageBubble(message, isCurrentUser);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: chatMessageController,
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFFF4D79),
                                child: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.white),
                                  onPressed: _sendChatMessage,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(selectedChatUser!.avatar),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFFFF4D79) : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isCurrentUser ? const Radius.circular(12) : Radius.zero,
                bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(12),
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Text(
              _getTimeAgo(message.timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1-$uid2' : '$uid2-$uid1';
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  void _showCreatePostDialog() {
    if (currentUser.isMock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create posts in mock mode')));
      return;
    }

    final postTitleController = TextEditingController();
    final postContentController = TextEditingController();
    String dialogCategory = selectedCategory == 'All' ? 'Tech' : selectedCategory;

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
                      items: categories
                          .where((category) => category != 'All')
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => dialogCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: postTitleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: postContentController,
                      decoration: const InputDecoration(labelText: 'Content'),
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
                    if (postTitleController.text.isEmpty ||
                        postContentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }
                    Navigator.pop(context);
                    await _addPost(
                      title: postTitleController.text,
                      content: postContentController.text,
                      category: dialogCategory,
                    );
                  },
                  child: const Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addPost({
  required String title,
  required String content,
  required String category,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,       // Make sure these field names match
      'content': content,   // your Firestore document structure
      'category': category,
      'authorId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'upvotes': 0,
    });
  } catch (e) {
    debugPrint('Error adding post: $e');
    rethrow; // Re-throw to handle in calling function
  }
}

  void _addComment(ForumPost post) {
    if (commentController.text.isEmpty) return;

    final newComment = ForumComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      content: commentController.text,
      timestamp: DateTime.now(),
      author: currentUser,
    );

    setState(() {
      posts = posts.map((p) {
        if (p.id == post.id) {
          return p.copyWith(comments: [...p.comments, newComment]);
        }
        return p;
      }).toList();
      commentController.clear();
    });
  }

  void _toggleUpvote(ForumPost post) {
    setState(() {
      posts = posts.map((p) {
        if (p.id == post.id) {
          return p.copyWith(
            upvotes: post.isUpvotedByCurrentUser ? post.upvotes - 1 : post.upvotes + 1,
            isUpvotedByCurrentUser: !post.isUpvotedByCurrentUser,
          );
        }
        return p;
      }).toList();
    });
  }

  void _toggleCommentUpvote(ForumComment comment, String postId) {
    setState(() {
      posts = posts.map((post) {
        if (post.id == postId) {
          final updatedComments = post.comments.map((c) {
            if (c.id == comment.id) {
              return c.copyWith(
                upvotes: comment.isUpvotedByCurrentUser
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

  Future<void> _deletePost(String postId) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await firestore.collection('posts').doc(postId).delete();
        setState(() => posts.removeWhere((post) => post.id == postId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')));
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> _deleteComment(String postId, String commentId) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          posts = posts.map((post) {
            if (post.id == postId) {
              return post.copyWith(
                comments: post.comments.where((c) => c.id != commentId).toList(),
              );
            }
            return post;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _sendChatMessage() async {
    if (chatMessageController.text.isEmpty || selectedChatUser == null) return;

    try {
      final chatId = _getChatId(currentUser.id, selectedChatUser!.id);
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'content': chatMessageController.text,
            'senderId': currentUser.id,
            'receiverId': selectedChatUser!.id,
            'timestamp': FieldValue.serverTimestamp(),
          });

      chatMessageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    postController.dispose();
    commentController.dispose();
    chatMessageController.dispose();
    super.dispose();
  }
}