import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _sortOrder = 'desc';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('School Announcements'),
        backgroundColor: Colors.deepPurple,
        actions: [
          DropdownButton<String>(
            value: _sortOrder,
            icon: Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.deepPurple,
            onChanged: (String? newValue) {
              setState(() {
                _sortOrder = newValue!;
              });
            },
            items: <String>['asc', 'desc']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'asc' ? 'Oldest First' : 'Newest First',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/efficient-d35fb.appspot.com/o/Inked305210021_174476585100114_8121263289838116254_n.jpg?alt=media&token=3ecb32c9-73ba-40dc-a078-a890ef50430e', // Replace with your school logo URL
              height: 100,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('announcements')
                  .orderBy('date', descending: _sortOrder == 'desc')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No announcements available'));
                }

                return ListView(
                  padding: EdgeInsets.all(10),
                  children: snapshot.data!.docs.map((doc) {
                    return AnnouncementCard(doc: doc);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  AnnouncementCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(doc: doc),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                doc['imageUrl'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    DateFormat.yMMMd().format(doc['date'].toDate()),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  AnnouncementDetailScreen({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['title']),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                doc['imageUrl'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              doc['title'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              doc['content'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat.yMMMd().format(doc['date'].toDate()),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
