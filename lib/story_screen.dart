import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'main.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionName = 'stories';
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isUploading = false;
  bool _showOnlyAcademic = false;
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showUploadDialog({Story? storyToEdit}) {
    String selectedCategory = storyToEdit?.category ?? 'Technology';
    bool isAcademic = storyToEdit?.isAcademic ?? false;
    File? imageFile;
    String? imageUrl = storyToEdit?.imageUrl;
    
    // If editing, pre-fill the fields
    if (storyToEdit != null) {
      _titleController.text = storyToEdit.title;
      _contentController.text = storyToEdit.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(storyToEdit == null ? 'Create New Story' : 'Edit Story'),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCategory,
                  items: [
                    'Technology',
                    'Business',
                    'Education',
                    'Leadership',
                    'Research',
                    'Scholarships',
                    'Other'
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Academic Content'),
                  subtitle: const Text('Mark this story as academic content'),
                  value: isAcademic,
                  activeColor: const Color(0xFFFF69B4),
                  onChanged: (value) {
                    setState(() {
                      isAcademic = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.image, color: Colors.grey),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            imageFile = File(pickedFile.path);
                            imageUrl = null; // Clear previous URL if any
                          });
                          
                          // Show image selected confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image selected successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Text(imageFile != null || imageUrl != null ? 'Change Image' : 'Add Image'),
                    ),
                    if (imageFile != null || imageUrl != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            imageFile = null;
                            imageUrl = null;
                          });
                        },
                        child: const Text('Remove'),
                      ),
                  ],
                ),
                if (imageFile != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (imageUrl != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Error loading image'),
                        );
                      },
                    ),
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
              onPressed: () {
                if (storyToEdit == null) {
                  _uploadStory(selectedCategory, isAcademic, imageFile);
                } else {
                  _updateStory(storyToEdit.id, selectedCategory, isAcademic, imageFile, imageUrl);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
              ),
              child: Text(
                storyToEdit == null ? 'Upload' : 'Update', 
                style: const TextStyle(color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CREATE operation
  Future<void> _uploadStory(String category, bool isAcademic, File? imageFile) async {
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

    try {
      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final storageRef = _storage.ref().child('story_images/$fileName');
        
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask;
        
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Calculate read time
      final wordsPerMinute = 200;
      final wordCount = _contentController.text.split(' ').length;
      final minutes = (wordCount / wordsPerMinute).ceil();
      final readTime = '${minutes}min read';

      // Add story to Firestore
      await _firestore.collection(_collectionName).add({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': 'You', // Simplified without authentication
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': [],
        'readTime': readTime,
        'category': category,
        'isAcademic': isAcademic,
        'imageUrl': imageUrl,
        'isLiked': false,
        'isSaved': false,
      });

      // Clear the text fields
      _titleController.clear();
      _contentController.clear();

      setState(() {
        _isUploading = false;
      });

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success message
      _showUploadSuccessDialog(DateTime.now());
    } catch (e) {
      // Close the loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading story: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isUploading = false;
      });
    }
  }

  // UPDATE operation
  Future<void> _updateStory(String storyId, String category, bool isAcademic, File? imageFile, String? currentImageUrl) async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    Navigator.of(context).pop();

    // Show updating indicator
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
            Text('Updating your story...'),
          ],
        ),
      ),
    );

    try {
      // Upload new image if provided
      String? imageUrl = currentImageUrl;
      if (imageFile != null) {
        // Delete old image if exists
        if (currentImageUrl != null) {
          try {
            final ref = _storage.refFromURL(currentImageUrl);
            await ref.delete();
          } catch (e) {
            print('Error deleting old image: $e');
            // Continue with update even if image deletion fails
          }
        }
        
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final storageRef = _storage.ref().child('story_images/$fileName');
        
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask;
        
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Calculate read time
      final wordsPerMinute = 200;
      final wordCount = _contentController.text.split(' ').length;
      final minutes = (wordCount / wordsPerMinute).ceil();
      final readTime = '${minutes}min read';

      // Update story in Firestore
      final updateData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': category,
        'isAcademic': isAcademic,
        'readTime': readTime,
      };

      if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      } else if (currentImageUrl == null) {
        // Remove image if it was deleted
        updateData['imageUrl'] = FieldValue.delete();
      }

      await _firestore.collection(_collectionName).doc(storyId).update(updateData);

      // Clear the text fields
      _titleController.clear();
      _contentController.clear();

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating story: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // DELETE operation
  Future<void> _deleteStory(String storyId) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story'),
        content: const Text('Are you sure you want to delete this story? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog
              Navigator.of(context).pop();
              
              // Show loading indicator
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
                      Text('Deleting story...'),
                    ],
                  ),
                ),
              );
              
              try {
                // Get the story to check if it has an image
                final storyDoc = await _firestore.collection(_collectionName).doc(storyId).get();
                final data = storyDoc.data();
                
                // Delete the image from storage if it exists
                if (data != null && data['imageUrl'] != null) {
                  try {
                    final ref = _storage.refFromURL(data['imageUrl']);
                    await ref.delete();
                  } catch (e) {
                    print('Error deleting image: $e');
                    // Continue with story deletion even if image deletion fails
                  }
                }
                
                // Delete the story document
                await _firestore.collection(_collectionName).doc(storyId).delete();
                
                // Close loading dialog
                Navigator.of(context).pop();
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Story deleted successfully'),
                    backgroundColor: Color(0xFFFF69B4),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // Close loading dialog
                Navigator.of(context).pop();
                
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting story: $e'),
                    backgroundColor: Colors.red,
                  ),
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

  // Add comment operation
  Future<void> _addComment(String storyId, String commentText) async {
    if (commentText.trim().isEmpty) return;
    
    try {
      final storyRef = _firestore.collection(_collectionName).doc(storyId);
      
      final newComment = {
        'author': 'You', // Simplified without authentication
        'content': commentText.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      await storyRef.update({
        'comments': FieldValue.arrayUnion([newComment]),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Toggle like operation
  Future<void> _toggleLike(String storyId, bool isCurrentlyLiked) async {
    try {
      final storyRef = _firestore.collection(_collectionName).doc(storyId);
      
      // Get current story data
      final storyDoc = await storyRef.get();
      final storyData = storyDoc.data();
      
      if (storyData != null) {
        final currentLikes = storyData['likes'] ?? 0;
        
        // Update likes count and isLiked status
        await storyRef.update({
          'likes': isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1,
          'isLiked': !isCurrentlyLiked,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling like: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Toggle save operation
  Future<void> _toggleSave(String storyId, bool isCurrentlySaved) async {
    try {
      final storyRef = _firestore.collection(_collectionName).doc(storyId);
      
      // Update isSaved status
      await storyRef.update({
        'isSaved': !isCurrentlySaved,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCurrentlySaved ? 'Story removed from saved' : 'Story saved'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving story: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          // Academic filter toggle
          IconButton(
            icon: Icon(
              Icons.school,
              color: _showOnlyAcademic ? const Color(0xFFFF69B4) : Colors.black,
            ),
            tooltip: 'Show Academic Content Only',
            onPressed: () {
              setState(() {
                _showOnlyAcademic = !_showOnlyAcademic;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _showOnlyAcademic 
                        ? 'Showing academic content only' 
                        : 'Showing all content'
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFFFF69B4),
                ),
              );
            },
          ),
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
        child: Column(
          children: [
            // Add Story Button - Prominent at the top
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: ElevatedButton.icon(
                onPressed: () => _showUploadDialog(),
                icon: const Icon(Icons.add_circle),
                label: const Text('Add New Story'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 250, 151, 201),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            // Category filter chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection(_collectionName)
                    .orderBy('category')
                    .snapshots(),
                builder: (context, snapshot) {
                  // Extract unique categories
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
                      _buildFilterChip(
                        category, 
                        _selectedCategory == category
                      )
                    ).toList(),
                  );
                }
              ),
            ),
            
            // Academic content banner
            if (_showOnlyAcademic)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: const Color(0xFFFF69B4).withOpacity(0.2),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Color(0xFFFF69B4)),
                    const SizedBox(width: 8),
                    const Text(
                      'Academic Content',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF69B4),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showOnlyAcademic = false;
                        });
                      },
                      child: const Text('Show All'),
                    ),
                  ],
                ),
              ),
              
            // Stories list - READ operation
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredStoriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final stories = snapshot.data?.docs ?? [];
                  
                  if (stories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No stories found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final doc = stories[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // Convert Firestore data to Story object
                      final story = _convertToStory(doc.id, data);
                      
                      return StoryCard(
                        story: story,
                        onCommentAdded: (storyId, comment) {
                          _addComment(storyId, comment.content);
                        },
                        onDelete: (storyId) {
                          _deleteStory(storyId);
                        },
                        onEdit: (story) {
                          _showUploadDialog(storyToEdit: story);
                        },
                        onView: (story) {
                          _viewFullStory(story);
                        },
                        onToggleLike: (storyId, isLiked) {
                          _toggleLike(storyId, isLiked);
                        },
                        onToggleSave: (storyId, isSaved) {
                          _toggleSave(storyId, isSaved);
                        },
                        isUserStory: true, // Simplified without authentication
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDialog(),
        backgroundColor: const Color(0xFFFF69B4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Stream<QuerySnapshot> _getFilteredStoriesStream() {
    Query query = _firestore.collection(_collectionName)
        .orderBy('timestamp', descending: true);
    
    if (_showOnlyAcademic) {
      query = query.where('isAcademic', isEqualTo: true);
    }
    
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    
    return query.snapshots();
  }
  
  Story _convertToStory(String id, Map<String, dynamic> data) {
    // Convert Firestore timestamp to DateTime
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    
    // Extract comments
    final commentsData = data['comments'] as List<dynamic>? ?? [];
    final comments = commentsData.map((comment) {
      final commentTimestamp = (comment['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      return Comment(
        author: comment['author'] ?? '',
        content: comment['content'] ?? '',
        timestamp: commentTimestamp,
      );
    }).toList();
    
    return Story(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? '',
      timestamp: timestamp,
      likes: data['likes'] ?? 0,
      comments: comments,
      readTime: data['readTime'] ?? '1min read',
      category: data['category'] ?? 'Other',
      isAcademic: data['isAcademic'] ?? false,
      imageUrl: data['imageUrl'],
    )
      ..isLiked = data['isLiked'] ?? false
      ..isSaved = data['isSaved'] ?? false;
  }
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFFF69B4).withOpacity(0.2),
        checkmarkColor: const Color(0xFFFF69B4),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFFF69B4) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  void _viewFullStory(Story story) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC0CB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          story.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                // Story content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author and date
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            story.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(story.timestamp),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Category and academic badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              story.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (story.isAcademic)
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
                      const SizedBox(height: 16),
                      
                      // Image if available
                      if (story.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            story.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Content
                      Text(
                        story.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Likes and comments count
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text('${story.likes} likes'),
                          const SizedBox(width: 16),
                          const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text('${story.comments.length} comments'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Comments section
                      if (story.comments.isNotEmpty) ...[
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...story.comments.map((comment) => Container(
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
                                    comment.author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM d, h:mm a').format(comment.timestamp),
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
                        )).toList(),
                      ],
                    ],
                  ),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sharing is not implemented in this demo')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF69B4),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
  final String category;
  final bool isAcademic;
  bool isLiked = false;
  bool isSaved = false;
  final String? imageUrl;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.readTime,
    required this.category,
    required this.isAcademic,
    this.imageUrl,
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
  final Function(String storyId) onDelete;
  final Function(Story story) onEdit;
  final Function(Story story) onView;
  final Function(String storyId, bool isLiked)? onToggleLike;
  final Function(String storyId, bool isSaved)? onToggleSave;
  final bool isUserStory;

  const StoryCard({
    super.key,
    required this.story,
    required this.onCommentAdded,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
    this.onToggleLike,
    this.onToggleSave,
    this.isUserStory = false,
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
  }

  void _showStoryOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Story Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.isUserStory) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Story'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onEdit(widget.story);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Story'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDelete(widget.story.id);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Full Story'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onView(widget.story);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Story'),
              onTap: () {
                Navigator.of(context).pop();
                // Share functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing is not implemented in this demo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report Story'),
              onTap: () {
                Navigator.of(context).pop();
                // Report functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reporting is not implemented in this demo')),
                );
              },
            ),
          ],
        ),
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
      color: Colors.white,
      child: InkWell(
        onTap: () => widget.onView(widget.story),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
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
                      if (widget.story.isAcademic)
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
                  // Add more options button
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.black54),
                    onPressed: _showStoryOptions,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.story.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              // Add image if available
              if (widget.story.imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.story.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 252, 251, 251),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.story.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.story.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => widget.onView(widget.story),
                child: const Text('Read more...'),
              ),
              const SizedBox(height: 8),
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
                          widget.onToggleLike?.call(widget.story.id, widget.story.isLiked);
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
                      widget.onToggleSave?.call(widget.story.id, widget.story.isSaved);
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
                    color: const Color.fromARGB(255, 248, 248, 248),
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
      ),
    );
  }
}