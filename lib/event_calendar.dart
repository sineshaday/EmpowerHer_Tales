import 'package:empowerher_tales/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(EmpowerHerTalesApp());
}

class EventCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Poppins',
      ),
      home: EventsScreen(),
    );
  }
}

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, String>> events = [
    {
      'title': 'Connect Women',
      'date': 'March 28th, 2025',
      'location': 'Google Meet',
      'format': 'Online',
      'image': 'https://static.wixstatic.com/media/fe4a5d_057007517b2347158abac16e41ebb2a4~mv2.png/v1/fill/w_720,h_405,al_c/fe4a5d_057007517b2347158abac16e41ebb2a4~mv2.png'
    },
    {
      'title': 'Dress For Success',
      'date': 'April 3rd, 2025',
      'location': 'Zoom',
      'format': 'Online',
      'image': 'https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F964405523%2F1400146494193%2F1%2Foriginal.20250219-154610?auto=format%2Ccompress&q=75&sharp=10&s=6dc0cc08553345f6bda5d4c5a9a39358'
    },
    {
      'title': 'Sip & Socialize - Women in Business',
      'date': 'April 20th, 2025',
      'location': 'Wilton Manors, FL',
      'format': 'Physical/Online',
      'image': 'https://tse3.mm.bing.net/th?id=OIP.h13VGj2lVmIi1a-G5J-Z9AHaDY&pid=Api'
    },
    {
      'title': 'Transform-Her Conference',
      'date': 'May 30th, 2025',
      'location': 'Kigali Convention Centre',
      'format': 'Physical/Online',
      'image': 'https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F924659573%2F2560146604071%2F1%2Foriginal.20241229-232930?crop=focalpoint&fit=crop&w=512&auto=format%2Ccompress&q=75&sharp=10&fp-x=0.005&fp-y=0.005&s=6672abe5e9d5d3d446ebf411f3b58c18'
    },
  ];

  void _addNewEvent(Map<String, String> newEvent) {
    setState(() {
      events.insert(0, {
        ...newEvent,
        'image': 'https://images.unsplash.com/photo-1521791055366-0d553872125f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1469&q=80'
      });
    });
  }

  void _navigateToAddEventScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(addEvent: _addNewEvent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          ),
        title: Text(
          'Women Connect Events',
          style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToAddEventScreen,
            tooltip: 'Add New Event',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEventScreen,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        tooltip: 'Add New Event',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Join us in empowering women through impactful events. Explore and participate!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.pink.shade700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.pinkAccent.withOpacity(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(imageUrl: event['image']!),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(
                              event['image']!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Container(
                                  height: 200,
                                  color: Colors.pink.shade100,
                                  child: Icon(Icons.event, size: 50, color: Colors.pink),
                                ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title']!,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.pink),
                                  SizedBox(width: 5),
                                  Text(event['date']!),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.pink),
                                  SizedBox(width: 5),
                                  Text(event['location']!),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.videocam, size: 16, color: Colors.pink),
                                  SizedBox(width: 5),
                                  Text(event['format']!),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.share, color: Colors.pink),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.bookmark_border, color: Colors.pink),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

class AddEventScreen extends StatefulWidget {
  final Function(Map<String, String>) addEvent;

  const AddEventScreen({required this.addEvent, Key? key}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newEvent = {
        'title': _titleController.text,
        'date': _dateController.text,
        'location': _locationController.text,
        'format': _formatController.text,
      };

      widget.addEvent(newEvent);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Event'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade700, Colors.pink.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  prefixIcon: Icon(Icons.title, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Event Date (e.g., March 28th, 2025)',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _formatController,
                decoration: InputDecoration(
                  labelText: 'Format (e.g., Online, Physical, Hybrid)',
                  prefixIcon: Icon(Icons.videocam, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event format';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(Icons.error, color: Colors.white, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}