import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _entryController = TextEditingController();
  int _selectedMood = 0;
  double _weeklyAverage = 0.0;
  List<QueryDocumentSnapshot> _previousEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchWeeklyMoodData();
  }

  Future<void> _fetchWeeklyMoodData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('journals')
        .where('uid', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .orderBy('timestamp', descending: true)
        .get();

    _previousEntries = snapshot.docs;

    if (_previousEntries.isNotEmpty) {
      final moodSum = _previousEntries.map((doc) => doc['mood'] as int).reduce((a, b) => a + b);
      setState(() {
        _weeklyAverage = moodSum / _previousEntries.length;
      });
    } else {
      setState(() {
        _weeklyAverage = 0;
      });
    }
  }

  Future<void> _submitJournal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedMood == 0 || _entryController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('journals').add({
      'uid': user.uid,
      'mood': _selectedMood,
      'entry': _entryController.text.trim(),
      'timestamp': Timestamp.now(),
    });

    _entryController.clear();
    _selectedMood = 0;
    _fetchWeeklyMoodData();
  }

  Widget _buildStarRow({required int rating, void Function(int)? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          onPressed: onTap != null ? () => onTap(i + 1) : null,
        );
      }),
    );
  }

  Widget _buildPreviousEntries() {
    if (_previousEntries.isEmpty) {
      return const Text("No journal entries yet.");
    }

    return Column(
      children: _previousEntries.map((doc) {
        final mood = doc['mood'];
        final text = doc['entry'];
        final date = (doc['timestamp'] as Timestamp).toDate();
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: _buildStarRow(rating: mood),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  "${date.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_weeklyAverage > 0)
              Text(
                "⭐ ${_weeklyAverage.toStringAsFixed(2)} / 5 this week",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            const Text("Previous Entries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildPreviousEntries(),
            const Divider(height: 40),
            const Text("Rate your mood today", style: TextStyle(fontSize: 16)),
            _buildStarRow(
              rating: _selectedMood,
              onTap: (rating) {
                setState(() => _selectedMood = rating);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _entryController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write about your day...",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitJournal,
              child: const Text("Submit Entry"),
            ),
          ],
        ),
      ),
    );
  }
}
