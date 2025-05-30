import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Placeholder data model for a visit
class Visit {
  final String id;
  final DateTime visitDate;
  final String doctorName;
  final String chiefComplaintSummary; // Or primary diagnosis summary
  final String department; // Optional, e.g., General, Ayurveda

  Visit({
    required this.id,
    required this.visitDate,
    required this.doctorName,
    required this.chiefComplaintSummary,
    this.department = "General Medicine",
  });
}

class EmrVisitHistoryScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  // Placeholder visit data for the given patient
  // In a real app, this would be fetched based on patientId
  final List<Visit> _visits = [
    Visit(
      id: "V001",
      visitDate: DateTime(2024, 7, 15, 10, 30),
      doctorName: "Dr. Amit Sharma",
      chiefComplaintSummary: "Fever and sore throat.",
      department: "General Physician"
    ),
    Visit(
      id: "V002",
      visitDate: DateTime(2024, 5, 20, 14, 0),
      doctorName: "Dr. Priya Singh",
      chiefComplaintSummary: "Follow-up: Blood pressure check.",
      department: "Cardiology"
    ),
    Visit(
      id: "V003",
      visitDate: DateTime(2023, 12, 10, 9, 15),
      doctorName: "Dr. Ramesh Gupta",
      chiefComplaintSummary: "Routine check-up and vaccination.",
      department: "Pediatrics" // Assuming patient context might change
    ),
    Visit(
      id: "V004",
      visitDate: DateTime(2023, 8, 1, 11, 0),
      doctorName: "Dr. Sunita Patel",
      chiefComplaintSummary: "Ayurvedic consultation for joint pain.",
      department: "Ayurveda"
    ),
  ];

  // Constructor with placeholder patient details
  EmrVisitHistoryScreen({
    Key? key,
    this.patientId = "PAT12345", // Placeholder
    this.patientName = "Rajesh Kumar", // Placeholder
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, you might filter _visits based on actual patientId or fetch them.
    final List<Visit> patientVisits = _visits; // For this example, using all placeholder visits.
    // To simulate an empty state for a different patient, you could do:
    // final List<Visit> patientVisits = patientId == "PAT_NO_VISITS" ? [] : _visits;


    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("EMR - Visit History"),
            Text(
              patientName,
              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: patientVisits.isEmpty
          ? _buildEmptyState()
          : _buildVisitList(context, patientVisits),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No visit history found for this patient.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitList(BuildContext context, List<Visit> visits) {
    // Sort visits by date, most recent first
    visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text(
                DateFormat('dd').format(visit.visitDate), // Day of the month
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
              ),
            ),
            title: Text(
              DateFormat('EEE, dd MMM yyyy').format(visit.visitDate), // e.g., Mon, 15 Jul 2024
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Text(
                  "Doctor: ${visit.doctorName}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                 Text(
                  "Department: ${visit.department}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Summary: ${visit.chiefComplaintSummary}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            isThreeLine: true, // Adjust based on content, true allows more space for subtitle
            onTap: () {
              // Conceptual navigation to detailed visit view
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Tapped on Visit ID: ${visit.id}. Navigating to details..."),
                  duration: const Duration(seconds: 1),
                ),
              );
              // In a real app:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => VisitDetailScreen(visitId: visit.id)));
            },
          ),
        );
      },
    );
  }
}

// Example Usage (main.dart or any other entry point):
// void main() {
//   runApp(MaterialApp(
//     title: 'EMR Visit History Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.teal,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//       cardTheme: CardTheme(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     ),
//     // Example with default patient
//     home: EmrVisitHistoryScreen(),
//     // Example with a specific patient that might have no visits
//     // home: EmrVisitHistoryScreen(patientId: "PAT_NO_VISITS", patientName: "Test Patient Empty"),
//   ));
// }
```
