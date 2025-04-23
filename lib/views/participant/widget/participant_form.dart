import 'package:flutter/material.dart';

class ParticipantForm extends StatefulWidget {
  const ParticipantForm({super.key});

  @override
  State<ParticipantForm> createState() => ParticipantFormState();
}

class ParticipantFormState extends State<ParticipantForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Gender dropdown
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  // === VALIDATORS ===

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age cannot be empty';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Age must be a number';
    }
    if (age < 5 || age > 120) {
      return 'Age must be between 5 and 120';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a gender')),
        );
        return;
      }

      // You can now use the input data
      final name = _nameController.text;
      final age = int.parse(_ageController.text);
      final gender = _selectedGender!;

      // Debug print or pass the data to another function
      print('Name: $name, Age: $age, Gender: $gender');

      // Clear form or navigate, depending on your app flow
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              validator: validateName,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'What do people call you?',
                labelText: 'Full Name *',
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ageController,
              validator: validateAge,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                icon: Icon(Icons.cake),
                hintText: 'Your age',
                labelText: 'Age *',
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.wc),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
