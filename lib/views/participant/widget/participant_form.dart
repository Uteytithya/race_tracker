import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/provider/participant_provider.dart';

class ParticipantForm extends StatefulWidget {
  final Participant? participant;

  const ParticipantForm({
    super.key,
    this.participant,
  });

  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _bibController;
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  Gender _selectedGender = Gender.male;
  bool _isLoading = false;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if editing
    _bibController = TextEditingController(
      text: widget.participant?.bib.toString() ?? '',
    );
    _nameController = TextEditingController(
      text: widget.participant?.name ?? '',
    );
    _ageController = TextEditingController(
      text: widget.participant?.age.toString() ?? '',
    );
    
    if (widget.participant != null) {
      _selectedGender = widget.participant!.gender;
    }
  }

  @override
  void dispose() {
    _bibController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveParticipant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create new participant object
    final participant = Participant(
      bib: int.parse(_bibController.text),
      name: _nameController.text,
      age: int.parse(_ageController.text),
      gender: _selectedGender,
    );

    // Add to provider
    try {
      final provider = context.read<ParticipantProvider>();
      
      // Check if bib number already exists
      if (widget.participant == null) {
        final existingParticipant = await provider.getByBib(participant.bib);
        logger.w("Existing Participant: $existingParticipant");
        if (existingParticipant != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bib number already exists'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        provider.addParticipant(participant);
      } else {
        // Find index of participant to update
        final participants = await provider.participants;
        final index = participants.indexWhere(
          (p) => p.bib == widget.participant!.bib,
        );
        if (index != -1) {
          provider.updateParticipant(participant);
        }
      }

      // Navigate back after successful save
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving participant: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bib Number Field
            const Text(
              'Bib Number',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bibController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter bib number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a bib number';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Name Field
            const Text(
              'Name',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter participant name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Age Field
            const Text(
              'Age',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter age',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an age';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid age';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Gender Selection
            const Text(
              'Gender',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Gender>(
                  isExpanded: true,
                  value: _selectedGender,
                  onChanged: (Gender? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    }
                  },
                  items: Gender.values.map((Gender gender) {
                    return DropdownMenuItem<Gender>(
                      value: gender,
                      child: Text(gender.name),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveParticipant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF101248),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.participant == null ? 'Create' : 'Update',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}