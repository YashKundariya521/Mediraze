import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:intl/intl.dart'; // For date formatting

class PatientRegistrationOpdForm extends StatefulWidget {
  const PatientRegistrationOpdForm({Key? key}) : super(key: key);

  @override
  _PatientRegistrationOpdFormState createState() =>
      _PatientRegistrationOpdFormState();
}

class _PatientRegistrationOpdFormState
    extends State<PatientRegistrationOpdForm> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for each field
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  final _bloodGroupController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressStreetController = TextEditingController();
  final _addressCityController = TextEditingController();
  final _addressStateController = TextEditingController();
  final _addressPincodeController = TextEditingController();
  final _aadharController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactRelationshipController = TextEditingController();
  final _emergencyContactMobileController = TextEditingController();
  final _chiefComplaintController = TextEditingController();
  final _referredByController = TextEditingController();
  String? _selectedVisitType = 'New'; // Default to New

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _visitTypeOptions = ['New', 'Follow-up', 'Emergency'];

  DateTime? _selectedDate;

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _fullNameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressStreetController.dispose();
    _addressCityController.dispose();
    _addressStateController.dispose();
    _addressPincodeController.dispose();
    _aadharController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactRelationshipController.dispose();
    _emergencyContactMobileController.dispose();
    _chiefComplaintController.dispose();
    _referredByController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        // Calculate age
        DateTime today = DateTime.now();
        int age = today.year - picked.year;
        if (today.month < picked.month ||
            (today.month == picked.month && today.day < picked.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Patient Registration...')),
      );
      // In a real app, you would send this data to your backend API
      print('Form Data:');
      print('Full Name: ${_fullNameController.text}');
      print('Date of Birth: ${_dobController.text}');
      print('Age: ${_ageController.text}');
      print('Gender: $_selectedGender');
      print('Mobile Number: ${_mobileNumberController.text}');
      // ... print other fields
      print('Chief Complaint: ${_chiefComplaintController.text}');
      print('Visit Type: $_selectedVisitType');

      // Potentially navigate to next screen or show success message
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
        title: const Text('Patient Registration & OPD'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSectionTitle('Personal Details'),
              _buildTextFormField(
                controller: _fullNameController,
                labelText: 'Full Name',
                hintText: 'Enter patient\'s full name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _buildTextFormField(
                      controller: _dobController,
                      labelText: 'Date of Birth (DD/MM/YYYY)',
                      hintText: 'Select date of birth',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 1,
                    child: _buildTextFormField(
                      controller: _ageController,
                      labelText: 'Age',
                      hintText: 'Years',
                      readOnly: true, // Calculated from DOB
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _buildDropdownFormField(
                value: _selectedGender,
                items: _genderOptions,
                labelText: 'Gender',
                hintText: 'Select gender',
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => value == null ? 'Please select gender' : null,
              ),
              _buildTextFormField(
                controller: _bloodGroupController,
                labelText: 'Blood Group (Optional)',
                hintText: 'e.g., O+, AB-',
              ),

              _buildSectionTitle('Contact Information'),
              _buildTextFormField(
                controller: _mobileNumberController,
                labelText: 'Mobile Number',
                hintText: 'Enter 10-digit mobile number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
                // Suffix for OTP verification indication (cosmetic for now)
                // suffixIcon: TextButton(onPressed: () {}, child: Text("Verify")),
              ),
              _buildTextFormField(
                controller: _emailController,
                labelText: 'Email Address (Optional)',
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _addressStreetController,
                labelText: 'Street/Area',
                hintText: 'Enter street name, house no., area',
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street/area';
                  }
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextFormField(
                      controller: _addressCityController,
                      labelText: 'City',
                      hintText: 'Enter city name',
                       validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _addressStateController,
                      labelText: 'State',
                      hintText: 'Enter state name',
                       validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              _buildTextFormField(
                controller: _addressPincodeController,
                labelText: 'Pincode',
                hintText: 'Enter 6-digit pincode',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pincode';
                  }
                   if (value.length != 6) {
                    return 'Pincode must be 6 digits';
                  }
                  return null;
                },
              ),

              _buildSectionTitle('Identification (Optional)'),
              _buildTextFormField(
                controller: _aadharController,
                labelText: 'Aadhar Number (Optional)',
                hintText: 'Enter 12-digit Aadhar number',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                 validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 12) {
                    return 'Aadhar number must be 12 digits';
                  }
                  return null;
                },
              ),

              _buildSectionTitle('Emergency Contact (Optional)'),
              _buildTextFormField(
                controller: _emergencyContactNameController,
                labelText: 'Contact Name (Optional)',
                hintText: 'Enter emergency contact name',
              ),
               _buildTextFormField(
                controller: _emergencyContactRelationshipController,
                labelText: 'Relationship (Optional)',
                hintText: 'e.g., Spouse, Parent, Sibling',
              ),
              _buildTextFormField(
                controller: _emergencyContactMobileController,
                labelText: 'Contact Mobile (Optional)',
                hintText: 'Enter 10-digit mobile number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),

              _buildSectionTitle('OPD Information'),
              _buildTextFormField(
                controller: _chiefComplaintController,
                labelText: 'Chief Complaint',
                hintText: 'Describe patient\'s main issues',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chief complaint';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _referredByController,
                labelText: 'Referred By (Optional)',
                hintText: 'Name of referring doctor or person',
              ),
              _buildDropdownFormField(
                value: _selectedVisitType,
                items: _visitTypeOptions,
                labelText: 'Visit Type',
                hintText: 'Select visit type',
                onChanged: (value) {
                  setState(() {
                    _selectedVisitType = value;
                  });
                },
                validator: (value) => value == null ? 'Please select visit type' : null,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Registration Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Register Patient'),
                ),
              ),
              const SizedBox(height: 20.0), // For bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
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
    Widget? suffixIcon,
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
          fillColor: readOnly ? Colors.grey[200] : null,
          suffixIcon: suffixIcon,
        ),
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        onTap: onTap,
        textInputAction: TextInputAction.next, // Move to next field
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

// Example usage:
// void main() {
//   runApp(MaterialApp(
//     title: 'Patient Registration Form Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.teal,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//     ),
//     home: const PatientRegistrationOpdForm(),
//   ));
// }
```
