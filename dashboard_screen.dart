import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting (placeholder for now)

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // Placeholder data - In a real app, this would come from a state management solution / API
  final String clinicName = "My Clinic";
  final String userName = "Admin User";
  final int todaysAppointments = 25;
  final double revenueToday = 15000.00;
  final int newPatientsToday = 5;
  final int totalPatients = 1200;

  // Sample appointment data
  final List<Map<String, String>> sampleAppointments = const [
    {"name": "Rajesh Kumar", "time": "10:00 AM", "status": "Scheduled"},
    {"name": "Priya Sharma", "time": "10:30 AM", "status": "Checked-in"},
    {"name": "Amit Singh", "time": "11:00 AM", "status": "Completed"},
    {"name": "Sunita Devi", "time": "11:30 AM", "status": "Scheduled"},
  ];

  @override
  Widget build(BuildContext context) {
    // Using a basic approach for date display, can be enhanced with a date picker
    final String todayDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(clinicName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Placeholder for notification action
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U'),
              // In a real app, load user image or use initials
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Placeholder for logout action
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildDateHeader(todayDate),
          const SizedBox(height: 16.0),
          _buildMetricsGrid(context),
          const SizedBox(height: 24.0),
          _buildQuickActions(context),
          const SizedBox(height: 24.0),
          _buildTodaysAppointmentsSection(context),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard - $date',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // IconButton(
        //   icon: Icon(Icons.calendar_today),
        //   onPressed: () {
        //     // Placeholder for opening a date picker
        //   },
        // ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    // Using GridView for responsiveness on different screen sizes
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // To disable GridView's own scrolling
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4, // 2 columns on small screens, 4 on larger
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: <Widget>[
        _buildMetricCard(
          context,
          title: "Today's Appointments",
          value: todaysAppointments.toString(),
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _buildMetricCard(
          context,
          title: "Revenue Today",
          value: "₹${NumberFormat("#,##,##0.00", "en_IN").format(revenueToday)}",
          icon: Icons.currency_rupee,
          color: Colors.green,
        ),
        _buildMetricCard(
          context,
          title: "New Patients Today",
          value: newPatientsToday.toString(),
          icon: Icons.person_add_alt_1,
          color: Colors.orange,
        ),
        _buildMetricCard(
          context,
          title: "Total Patients",
          value: totalPatients.toString(),
          icon: Icons.groups,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required String value, required IconData icon, Color color = Colors.grey}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(icon, size: 32.0, color: color),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        // Using Wrap for responsiveness of action buttons
        Wrap(
          spacing: 12.0, // Horizontal spacing
          runSpacing: 12.0, // Vertical spacing if buttons wrap to next line
          children: <Widget>[
            _buildQuickActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Book Appointment',
              onPressed: () { /* Placeholder */ },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.person_add,
              label: 'Register Patient',
              onPressed: () { /* Placeholder */ },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.search,
              label: 'Search Patient',
              onPressed: () { /* Placeholder */ },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        textStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildTodaysAppointmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Appointments",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () { /* Placeholder to view all appointments */ },
              child: const Text('View All'),
            )
          ],
        ),
        const SizedBox(height: 8.0),
        sampleAppointments.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No appointments for today.", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sampleAppointments.length > 3 ? 3 : sampleAppointments.length, // Show limited items on dashboard
                itemBuilder: (context, index) {
                  final appointment = sampleAppointments[index];
                  return Card(
                    elevation: 1.0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(appointment['name']![0]), // First letter of name
                      ),
                      title: Text(appointment['name']!),
                      subtitle: Text(appointment['time']!),
                      trailing: _buildStatusChip(appointment['status']!),
                      onTap: () {
                        // Placeholder: Navigate to appointment details or EMR
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String chipText = status;

    switch (status.toLowerCase()) {
      case 'scheduled':
        chipColor = Colors.blue.shade100;
        break;
      case 'checked-in':
        chipColor = Colors.orange.shade100;
        chipText = "Checked-in"; // Ensure consistent casing if needed
        break;
      case 'completed':
        chipColor = Colors.green.shade100;
        break;
      case 'cancelled':
        chipColor = Colors.red.shade100;
        break;
      default:
        chipColor = Colors.grey.shade200;
    }

    return Chip(
      label: Text(chipText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      labelStyle: TextStyle(color: chipColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white),
    );
  }
}

// To run this screen (example):
// void main() {
//   runApp(MaterialApp(
//     title: 'CMS Dashboard Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.teal, // Example theme
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//     ),
//     home: const DashboardScreen(),
//   ));
// }
```
