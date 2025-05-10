import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/JournalPage.dart';
import 'package:graduation_project/Screens/ProfilePage.dart';
import 'package:graduation_project/Screens/TherapistsListScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userType;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _fetchUserType();
  }

  Future<void> _fetchUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final therapistDoc = await FirebaseFirestore.instance.collection('therapists').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        userType = userDoc['userType'] ?? 'user';
      });
    } else if (therapistDoc.exists) {
      setState(() {
        userType = therapistDoc['userType'] ?? 'therapist';
      });
    } else {
      print("⚠️ User document does not exist for uid: $uid in either collection.");
      setState(() {
        userType = 'user'; // default fallback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Column(
        children: [
          const Text("Home"),
          if (userType == 'therapist') const TherapistAvailabilityForm(), // 👈 Added
        ],
      ),
      const JournalPage(),
      const TherapistsListScreen(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mental Health App')),
      body: Center(child: screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Journal"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Therapists"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class TherapistAvailabilityForm extends StatefulWidget {
  const TherapistAvailabilityForm({super.key});

  @override
  State<TherapistAvailabilityForm> createState() => _TherapistAvailabilityFormState();
}

class _TherapistAvailabilityFormState extends State<TherapistAvailabilityForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _submitAvailability() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || selectedDay == null || startTime == null || endTime == null) return;

    // Fetch the therapist's current availability
    final therapistDoc = await FirebaseFirestore.instance.collection('therapists').doc(uid).get();
    final currentAvailability = List<Map<String, dynamic>>.from(therapistDoc.data()?['availability'] ?? []);

    // Check if the selected day already exists, and remove it if so
    currentAvailability.removeWhere((entry) => entry['day'] == selectedDay);

    // Add the new availability
    currentAvailability.add({
      'day': selectedDay,
      'start': startTime!.format(context),
      'end': endTime!.format(context),
    });

    // Update the availability in Firestore
    await FirebaseFirestore.instance.collection('therapists').doc(uid).update({
      'availability': currentAvailability,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Availability updated")));
    setState(() {
      selectedDay = null;
      startTime = null;
      endTime = null;
    });
  }

  // Reset all availability
  Future<void> _resetAvailability() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('therapists').doc(uid).update({
      'availability': [],
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All availability cleared")));
    setState(() {
      selectedDay = null;
      startTime = null;
      endTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Set Your Availability", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: selectedDay,
                hint: const Text("Select Day"),
                items: days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (value) => setState(() => selectedDay = value),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(startTime == null ? "Start Time" : "Start: ${startTime!.format(context)}"),
                  ElevatedButton(onPressed: () => _pickTime(true), child: const Text("Pick Start")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(endTime == null ? "End Time" : "End: ${endTime!.format(context)}"),
                  ElevatedButton(onPressed: () => _pickTime(false), child: const Text("Pick End")),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitAvailability,
                child: const Text("Save Availability"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _resetAvailability,
                child: const Text("Clear All Availability"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
