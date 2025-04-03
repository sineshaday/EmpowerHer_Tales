import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'stories';
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = true;
  
  // Track liked stories
  Set<String> _likedStories = {};

  @override
  void initState() {
    super.initState();
    _checkAndAddSampleStories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkAndAddSampleStories() async {
    try {
      // Clear existing stories first to avoid duplicates
      final existingStories = await _firestore.collection(_collectionName).get();
      for (var doc in existingStories.docs) {
        await doc.reference.delete();
      }
      
      // Add the sample stories
      await _addSampleStories();
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleStories() async {
    final sampleStories = [
      {
        'title': 'Tech companies commit to digital inclusion initiative',
        'content': 'Several major tech companies announced a new coalition to improve digital access for underserved communities worldwide.',
        'author': 'Samantha Chen',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        'likes': 45,
        'comments': [
          {
            'author': 'Michelle',
            'content': 'This is a step in the right direction!',
            'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 4))),
          }
        ],
        'category': 'Business',
        'isAcademic': false,
        'readTime': '3min read',
        'imageUrl': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
      },
      {
        'title': 'Female-led startup raises \$10M for education platform',
        'content': 'A startup focused on providing STEM education to girls in rural areas has secured major funding to expand their operations.',
        'author': 'Maria Rodriguez',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 8))),
        'likes': 67,
        'comments': [],
        'category': 'Education',
        'isAcademic': true,
        'readTime': '5min read',
      },
      {
        'title': 'Women\'s leadership summit announces global expansion',
        'content': 'The annual women\'s leadership summit will now be held in 10 countries, bringing together female leaders from diverse backgrounds.',
        'author': 'Priya Sharma',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'likes': 93,
        'comments': [],
        'category': 'Leadership',
        'isAcademic': true,
        'readTime': '6min read',
      },
      {
        'title': 'New research on gender equality in STEM fields',
        'content': 'A comprehensive study published in Nature reveals significant progress in gender representation in STEM fields over the last decade, but highlights persistent challenges.',
        'author': 'Dr. Emily Chen',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
        'likes': 112,
        'comments': [],
        'category': 'Research',
        'isAcademic': true,
        'readTime': '8min read',
      },
      {
        'title': 'Academic scholarship program for women in engineering',
        'content': 'A new scholarship program aims to support women pursuing advanced degrees in engineering disciplines with full tuition coverage and mentorship opportunities.',
        'author': 'Prof. Sarah Johnson',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 18))),
        'likes': 87,
        'comments': [],
        'category': 'Scholarships',
        'isAcademic': true,
        'readTime': '4min read',
      },
    ];
    
    for (final story in sampleStories) {
      await _firestore.collection(_collectionName).add(story);
    }
    
    print('Added ${sampleStories.length} sample stories');
  }

  // Add a new story
  Future<void> _addStory() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await _firestore.collection(_collectionName).add({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': 'You',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': [],
        'category': 'Technology',
        'isAcademic': false,
        'readTime': '1min read',
      });

      _titleController.clear();
      _contentController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story added successfully')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Update an existing story
  void _showEditStoryDialog(String storyId, String currentTitle, String currentContent) {
    _titleController.text = currentTitle;
    _contentController.text = currentContent;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Story'),
        content: Column(
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
          ],
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
            onPressed: () => _updateStory(storyId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  // Update story implementation
  Future<void> _updateStory(String storyId) async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await _firestore.collection(_collectionName).doc(storyId).update({
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _contentController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story updated successfully')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating story: $e')),
      );
    }
  }

  // Simple share story function
  void _shareStory(String title, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Add comment to a story - FIXED
  Future<void> _addComment(String storyId, String comment) async {
    if (comment.isEmpty) return;
    
    try {
      // Get a reference to the story document
      final storyRef = _firestore.collection(_collectionName).doc(storyId);
      
      // Create the new comment
      final newComment = {
        'author': 'You',
        'content': comment,
        'timestamp': Timestamp.now(),
      };
      
      // Update the document by adding the new comment to the comments array
      await storyRef.update({
        'comments': FieldValue.arrayUnion([newComment])
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  // Toggle like on a story
  Future<void> _toggleLike(String storyId) async {
    try {
      final storyRef = _firestore.collection(_collectionName).doc(storyId);
      final storyDoc = await storyRef.get();
      
      if (storyDoc.exists) {
        final data = storyDoc.data() as Map<String, dynamic>;
        int likes = data['likes'] ?? 0;
        
        await storyRef.update({'likes': likes + 1});
        
        // Update local state to show red heart
        setState(() {
          _likedStories.add(storyId);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Delete a story
  Future<void> _deleteStory(String storyId) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story'),
        content: const Text('Are you sure you want to delete this story? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await _firestore.collection(_collectionName).doc(storyId).delete();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Story deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting story: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddStoryDialog() {
    _titleController.clear();
    _contentController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Story'),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addStory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(String storyId) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Your comment',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addComment(storyId, commentController.text);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Stories'),
          backgroundColor: const Color(0xFFFFC0CB),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        backgroundColor: const Color(0xFFFFC0CB),
      ),
      body: Column(
        children: [
          // Add Story Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showAddStoryDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add New Story'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection(_collectionName)
                  .orderBy('category')
                  .snapshots(),
              builder: (context, snapshot) {
                Set<String> categories = {'All'};
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['category'] != null) {
                      categories.add(data['category'] as String);
                    }
                  }
                }
                
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((category) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFFF69B4).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedCategory == category ? const Color(0xFFFF69B4) : Colors.black,
                        ),
                      ),
                    )
                  ).toList(),
                );
              }
            ),
          ),
          
          // Stories List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStoriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final stories = snapshot.data?.docs ?? [];
                
                if (stories.isEmpty) {
                  return const Center(child: Text('No stories found'));
                }
                
                return ListView.builder(
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final doc = stories[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final storyId = doc.id;
                    
                    final title = data['title'] ?? '';
                    final content = data['content'] ?? '';
                    final author = data['author'] ?? '';
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final likes = data['likes'] ?? 0;
                    final comments = data['comments'] as List<dynamic>? ?? [];
                    final imageUrl = data['imageUrl'] as String?;
                    final category = data['category'] ?? 'Other';
                    final isAcademic = data['isAcademic'] ?? false;
                    final readTime = data['readTime'] ?? '1min read';
                    final isLiked = _likedStories.contains(storyId);
                    
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category and Academic badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isAcademic)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF69B4).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.school, color: Color(0xFFFF69B4), size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Academic',
                                          style: TextStyle(
                                            color: Color(0xFFFF69B4),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Title
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Image if available
                            if (imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      color: Colors.grey.shade200,
                                      child: const Center(child: Icon(Icons.error)),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            
                            // Content
                            Text(
                              content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Author, date and read time
                            Row(
                              children: [
                                Text(
                                  'By $author',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM d, yyyy').format(timestamp),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  readTime,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Action buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Like button
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                      onPressed: () => _toggleLike(storyId),
                                      tooltip: 'Like',
                                    ),
                                    Text('$likes'),
                                  ],
                                ),
                                
                                // Comment button
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.comment_outlined),
                                      onPressed: () => _showCommentDialog(storyId),
                                      tooltip: 'Comment',
                                    ),
                                    Text('${comments.length}'),
                                  ],
                                ),
                                
                                // Edit button
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showEditStoryDialog(storyId, title, content),
                                  tooltip: 'Edit',
                                ),
                                
                                // Share button
                                IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () => _shareStory(title, content),
                                  tooltip: 'Share',
                                ),
                                
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteStory(storyId),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            
                            // Comments section
                            if (comments.isNotEmpty) ...[
                              const Divider(),
                              const Text(
                                'Comments',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...comments.map((comment) {
                                final commentAuthor = comment['author'] ?? '';
                                final commentContent = comment['content'] ?? '';
                                final commentTimestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            commentAuthor,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            DateFormat('MMM d, h:mm a').format(commentTimestamp),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(commentContent),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStoryDialog,
        backgroundColor: const Color(0xFFFF69B4),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Stream<QuerySnapshot> _getFilteredStoriesStream() {
    Query query = _firestore.collection(_collectionName)
        .orderBy('timestamp', descending: true);
    
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    
    return query.snapshots();
  }
}