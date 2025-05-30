import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PanchakarmaSessionLogScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PanchakarmaSessionLogScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  _PanchakarmaSessionLogScreenState createState() =>
      _PanchakarmaSessionLogScreenState();
}

class _PanchakarmaSessionLogScreenState
    extends State<PanchakarmaSessionLogScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final _sessionDateController = TextEditingController();
  final _sessionTimeController = TextEditingController(); // New controller for time
  final _otherTherapyNameController = TextEditingController();
  final _medicinesOilsController = TextEditingController();
  final _durationController = TextEditingController();
  final _therapistNameController = TextEditingController();
  final _preTreatmentNotesController = TextEditingController();
  final _postTreatmentNotesController = TextEditingController();
  final _contraindicationsController = TextEditingController(); // New controller
  final _sessionSequenceController = TextEditingController(); // New controller

  // Dropdown state
  String? _selectedTherapy;
  bool _showOtherTherapyField = false;

  // Dosha state
  final Set<String> _selectedDoshas = {}; // To store multiple selected doshas
  final List<String> _doshaOptions = ["Vata", "Pitta", "Kapha"];

  final List<String> _therapyOptions = [
    "Abhyanga",
    "Shirodhara",
    "Vamana",
    "Virechana",
    "Nasya",
    "Basti (Anuvasana)",
    "Basti (Niruha)",
    "Raktamokshana",
    "Pizhichil",
    "Kati Basti",
    "Janu Basti",
    "Greeva Basti",
    "Other"
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // New state for time

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _sessionDateController.text =
        DateFormat('dd/MM/yyyy').format(_selectedDate!);
    _selectedTime = TimeOfDay.now(); // Initialize with current time
    _sessionTimeController.text = _formatTimeOfDay(_selectedTime!);
  }

  @override
  void dispose() {
    _sessionDateController.dispose();
    _sessionTimeController.dispose(); // Dispose new controller
    _otherTherapyNameController.dispose();
    _medicinesOilsController.dispose();
    _durationController.dispose();
    _therapistNameController.dispose();
    _preTreatmentNotesController.dispose();
    _postTreatmentNotesController.dispose();
    _contraindicationsController.dispose(); // Dispose new controller
    _sessionSequenceController.dispose(); // Dispose new controller
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); // e.g., 5:08 PM
    return format.format(dt);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _sessionDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _sessionTimeController.text = _formatTimeOfDay(picked);
      });
    }
  }

  void _onTherapyChanged(String? newValue) {
    setState(() {
      _selectedTherapy = newValue;
      if (newValue == "Other") {
        _showOtherTherapyField = true;
      } else {
        _showOtherTherapyField = false;
        _otherTherapyNameController.clear();
      }
    });
  }

  void _onDoshaSelected(String dosha, bool selected) {
    setState(() {
      if (selected) {
        _selectedDoshas.add(dosha);
      } else {
        _selectedDoshas.remove(dosha);
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String therapyName = _selectedTherapy == "Other"
          ? _otherTherapyNameController.text
          : _selectedTherapy!;
      
      // Consolidate date and time
      String fullSessionDateTime = "Date: ${_sessionDateController.text}";
      if(_selectedTime != null) {
        fullSessionDateTime += ", Time: ${_sessionTimeController.text}";
      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Panchakarma Session Log...')),
      );

      print('--- Panchakarma Session Log ---');
      print('Patient ID: ${widget.patientId}');
      print('Patient Name: ${widget.patientName}');
      print('Session DateTime: $fullSessionDateTime');
      print('Selected Doshas: ${_selectedDoshas.join(', ')}');
      print('Therapy Type: $therapyName');
      print('Session Sequence: ${_sessionSequenceController.text}');
      print('Medicines/Oils Used: ${_medicinesOilsController.text}');
      print('Duration: ${_durationController.text} minutes');
      print('Therapist Name: ${_therapistNameController.text}');
      print('Pre-treatment Notes: ${_preTreatmentNotesController.text}');
      print('Post-treatment Notes: ${_postTreatmentNotesController.text}');
      print('Contraindications/Warnings: ${_contraindicationsController.text}');

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panchakarma Session Log'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPatientInfo(),
              const SizedBox(height: 16),
              // Date and Time Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _sessionDateController,
                      labelText: 'Date of Session',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a date' : null,
                      prefixIcon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _sessionTimeController,
                      labelText: 'Time of Session',
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a time' : null,
                      prefixIcon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle("Dosha Status"),
              _buildDoshaSelectionChips(),
              
              _buildDropdownFormField(
                value: _selectedTherapy,
                items: _therapyOptions,
                labelText: 'Type of Therapy',
                onChanged: _onTherapyChanged,
                validator: (value) =>
                    value == null ? 'Please select a therapy type' : null,
              ),
              if (_showOtherTherapyField)
                _buildTextFormField(
                  controller: _otherTherapyNameController,
                  labelText: 'Specify Other Therapy',
                  validator: (value) {
                    if (_showOtherTherapyField &&
                        (value == null || value.isEmpty)) {
                      return 'Please specify the therapy name';
                    }
                    return null;
                  },
                ),
              _buildTextFormField(
                controller: _sessionSequenceController,
                labelText: 'Session Sequence (e.g., 3 of 5) (Optional)',
                hintText: 'Enter session sequence if applicable',
              ),
              _buildTextFormField(
                controller: _medicinesOilsController,
                labelText: 'Specific Medicines/Oils Used (and Quantities)',
                maxLines: 3,
                hintText: 'Detail medicines, oils, and quantities used...',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter details' : null,
              ),
              _buildTextFormField(
                controller: _durationController,
                labelText: 'Duration of Session (minutes)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _therapistNameController,
                labelText: 'Therapist Name',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter therapist name' : null,
              ),
              _buildTextFormField(
                controller: _preTreatmentNotesController,
                labelText: 'Pre-treatment Observations/Notes',
                maxLines: 3,
                hintText: 'Any observations before starting the treatment...',
              ),
              _buildTextFormField(
                controller: _postTreatmentNotesController,
                labelText: 'Post-treatment Observations/Notes',
                maxLines: 3,
                hintText: 'Any observations after the treatment...',
              ),
              _buildTextFormField(
                controller: _contraindicationsController,
                labelText: 'Contraindications/Warnings (Optional)',
                maxLines: 3,
                hintText: 'Note any contraindications or warnings for this session...',
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Save Session Log'),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Patient: ${widget.patientName}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "ID: ${widget.patientId}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
      ),
    );
  }

  Widget _buildDoshaSelectionChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _doshaOptions.map((dosha) {
          return ChoiceChip(
            label: Text(dosha),
            selected: _selectedDoshas.contains(dosha),
            onSelected: (bool selected) {
              _onDoshaSelected(dosha, selected);
            },
            selectedColor: Colors.teal.shade100,
            labelStyle: TextStyle(
              color: _selectedDoshas.contains(dosha) ? Colors.teal.shade900 : Colors.black87,
            ),
            backgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool readOnly = false,
    int? maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[100] : null,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        onTap: onTap,
        textInputAction: maxLines != null && maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      ),
    );
  }

  Widget _buildDropdownFormField<T>({
    required T? value,
    required List<T> items,
    required String labelText,
    String? hintText,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

// Example Usage:
// void main() {
//   runApp(MaterialApp(
//     title: 'Panchakarma Log Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.teal,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//     ),
//     home: const PanchakarmaSessionLogScreen(
//       patientId: "PATXYZ789",
//       patientName: "Aisha Sharma",
//     ),
//   ));
// }
```
