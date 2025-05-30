import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Imports for localization and language switcher
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'language_switcher_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // Placeholder data - In a real app, this would come from a state management solution / API
  // final String clinicName = "My Clinic"; // Will be replaced by localized appTitle or similar
  final String userName = "Admin User"; // This might come from user state
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
    // Get the AppLocalizations instance
    final appLocalizations = AppLocalizations.of(context)!;
    
    final String todayDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.dashboard), // Use localized string for dashboard title
        actions: [
          const LanguageSwitcherWidget(), // Add the language switcher here
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
          _buildDateHeader(context, todayDate, appLocalizations), // Pass appLocalizations
          const SizedBox(height: 16.0),
          _buildMetricsGrid(context, appLocalizations), // Pass appLocalizations
          const SizedBox(height: 24.0),
          _buildQuickActions(context, appLocalizations), // Pass appLocalizations
          const SizedBox(height: 24.0),
          _buildTodaysAppointmentsSection(context, appLocalizations), // Pass appLocalizations
        ],
      ),
    );
  }

  // Modify helper methods to accept AppLocalizations if they contain localizable text

  Widget _buildDateHeader(BuildContext context, String date, AppLocalizations appLocalizations) {
    // Example: If 'Dashboard - {date}' needs localization, it's more complex.
    // For now, keeping the date part as is, but the "Dashboard" part could be from appLocalizations.dashboard
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${appLocalizations.dashboard} - $date', // Combining localized "Dashboard" with dynamic date
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, AppLocalizations appLocalizations) {
    // Titles of Metric cards are candidates for localization.
    // For this exercise, we'll assume keys like 'todaysAppointments', 'revenueToday' etc.
    // would be added to .arb files if these specific texts need to be localized.
    // Here, we'll use the existing arb keys as examples or keep static if no direct match.
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: <Widget>[
        _buildMetricCard(
          context,
          title: appLocalizations.appointments, // Using 'appointments' key as an example
          value: todaysAppointments.toString(),
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _buildMetricCard(
          context,
          title: "Revenue Today", // Keep static if no direct key, or add one e.g., "revenueToday"
          value: "₹${NumberFormat("#,##,##0.00", "en_IN").format(revenueToday)}",
          icon: Icons.currency_rupee,
          color: Colors.green,
        ),
        _buildMetricCard(
          context,
          title: appLocalizations.patientRegistration, // Using 'patientRegistration' as an example
          value: newPatientsToday.toString(), // Assuming this relates to new patients
          icon: Icons.person_add_alt_1,
          color: Colors.orange,
        ),
        _buildMetricCard(
          context,
          title: "Total Patients", // Keep static or add key e.g. "totalPatients"
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
              title, // Already localized if passed from appLocalizations
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

  Widget _buildQuickActions(BuildContext context, AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.quickActions, // Use localized "Quick Actions"
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 12.0, 
          runSpacing: 12.0, 
          children: <Widget>[
            // Buttons labels can also be localized if keys like "bookAppointment" are added
            _buildQuickActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: appLocalizations.appointments, // Example: Reusing 'appointments' for 'Book Appointment'
              onPressed: () { /* Placeholder */ },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.person_add,
              label: appLocalizations.patientRegistration, // Example: Reusing 'patientRegistration'
              onPressed: () { /* Placeholder */ },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.search,
              label: 'Search Patient', // Keep static or add key e.g. "searchPatient"
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
      label: Text(label), // Already localized if passed from appLocalizations
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

  Widget _buildTodaysAppointmentsSection(BuildContext context, AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appLocalizations.appointments, // Using 'appointments' for "Today's Appointments" title
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () { /* Placeholder to view all appointments */ },
              // Example: if a "viewAll" key existed: Text(appLocalizations.viewAll)
              child: const Text('View All'), 
            )
          ],
        ),
        const SizedBox(height: 8.0),
        sampleAppointments.isEmpty
            ? Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Example: if "noAppointmentsToday" key existed: Text(appLocalizations.noAppointmentsToday)
                child: const Text("No appointments for today.", style: TextStyle(fontSize: 16, color: Colors.grey)), 
              ))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sampleAppointments.length > 3 ? 3 : sampleAppointments.length, 
                itemBuilder: (context, index) {
                  final appointment = sampleAppointments[index];
                  return Card(
                    elevation: 1.0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(appointment['name']![0]), 
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
    String chipText = status; // This text itself could be localized if needed

    switch (status.toLowerCase()) {
      case 'scheduled':
        chipColor = Colors.blue.shade100;
        break;
      case 'checked-in':
        chipColor = Colors.orange.shade100;
        chipText = "Checked-in"; 
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
```
