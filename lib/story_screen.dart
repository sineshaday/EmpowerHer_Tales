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
      category: 'Technology',
      isAcademic: true,
      imageUrl: 'https://images.unsplash.com/photo-1573164713988-8665fc963095?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1469&q=80',
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
      category: 'Business',
      isAcademic: false,
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
      category: 'Education',
      isAcademic: true,
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
      category: 'Leadership',
      isAcademic: true,
    ),
    Story(
      id: '5',
      title: 'New research on gender equality in STEM fields',
      content: 'A comprehensive study published in Nature reveals significant progress in gender representation in STEM fields over the last decade, but highlights persistent challenges.',
      author: 'Dr. Emily Chen',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      likes: 112,
      comments: [],
      readTime: '8min read',
      category: 'Research',
      isAcademic: true,
    ),
    Story(
      id: '6',
      title: 'Academic scholarship program for women in engineering',
      content: 'A new scholarship program aims to support women pursuing advanced degrees in engineering disciplines with full tuition coverage and mentorship opportunities.',
      author: 'Prof. Sarah Johnson',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      likes: 87,
      comments: [],
      readTime: '4min read',
      category: 'Scholarships',
      isAcademic: true,
    ),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isUploading = false;
  bool _showOnlyAcademic = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showUploadDialog({Story? storyToEdit}) {
    String selectedCategory = storyToEdit?.category ?? 'Technology';
    bool isAcademic = storyToEdit?.isAcademic ?? false;
    
    // If editing, pre-fill the fields
    if (storyToEdit != null) {
      _titleController.text = storyToEdit.title;
      _contentController.text = storyToEdit.content;
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
                      onPressed: () {
                        // Show a mock image selection dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Image'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take Photo'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Camera functionality would be implemented here')),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Show image selected confirmation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Image selected successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    setState(() {
                                      // In a real app, we would store the image path
                                      // For now, just show a confirmation
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
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
              onPressed: () {
                if (storyToEdit == null) {
                  _uploadStory(selectedCategory, isAcademic);
                } else {
                  _updateStory(storyToEdit.id, selectedCategory, isAcademic);
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

  void _uploadStory(String category, bool isAcademic) {
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
    Future.delayed(const Duration(milliseconds: 500), () {
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
            category: category,
            isAcademic: isAcademic,
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

  void _updateStory(String storyId, String category, bool isAcademic) {
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

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 300), () {
      // Find and update the story
      final storyIndex = stories.indexWhere((s) => s.id == storyId);
      if (storyIndex != -1) {
        final oldStory = stories[storyIndex];
        setState(() {
          stories[storyIndex] = Story(
            id: oldStory.id,
            title: _titleController.text,
            content: _contentController.text,
            author: oldStory.author,
            timestamp: oldStory.timestamp,
            likes: oldStory.likes,
            comments: oldStory.comments,
            readTime: oldStory.readTime,
            category: category,
            isAcademic: isAcademic,
            imageUrl: oldStory.imageUrl,
          );
        });
      }

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

  // Delete a story
  void _deleteStory(String storyId) {
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
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
              
              // Remove the story from the list immediately
              setState(() {
                stories.removeWhere((story) => story.id == storyId);
              });
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Story deleted successfully'),
                  backgroundColor: Color(0xFFFF69B4),
                  duration: Duration(seconds: 2),
                ),
              );
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

  @override
  Widget build(BuildContext context) {
    // Filter stories if academic filter is on
    final filteredStories = _showOnlyAcademic 
        ? stories.where((story) => story.isAcademic).toList()
        : stories;
        
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', true),
                  _buildFilterChip('Technology', false),
                  _buildFilterChip('Education', false),
                  _buildFilterChip('Research', false),
                  _buildFilterChip('Scholarships', false),
                  _buildFilterChip('Leadership', false),
                ],
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
              
            // Stories list
            Expanded(
              child: filteredStories.isEmpty
                  ? const Center(
                      child: Text(
                        'No stories found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredStories.length,
                      itemBuilder: (context, index) {
                        return StoryCard(
                          story: filteredStories[index],
                          onCommentAdded: (storyId, comment) {
                            setState(() {
                              final storyIndex = stories.indexWhere((s) => s.id == storyId);
                              if (storyIndex != -1) {
                                stories[storyIndex].comments.add(comment);
                              }
                            });
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
                          isUserStory: filteredStories[index].author == 'You',
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
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Filter logic would go here
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
  final bool isUserStory;

  const StoryCard({
    super.key,
    required this.story,
    required this.onCommentAdded,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
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

    // Show a snackbar to confirm the comment was added
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
      color: Colors.white, // Changed from pink to white
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

