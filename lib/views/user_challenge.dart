import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../configures/text_style.dart';
import '../utils/customs/custom_challenge_card.dart';
import '../configures/color_theme.dart';
import '../models/challenge_model.dart';

class UserChallenge extends StatefulWidget {
  const UserChallenge({Key? key}) : super(key: key);

  @override
  State<UserChallenge> createState() => _UserChallengeState();
}

class _UserChallengeState extends State<UserChallenge> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  String? activityType;
  int? participants;

  bool enableReminder = false;
  List<bool> selectedOptions = List.generate(4, (index) => false);
  late bool tempEnableReminder;
  late List<bool> tempSelectedOptions;

  // List to hold created challenges
  List<Challenge> challenges = [];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  void _fetchChallenges() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('challenges').get();
    setState(() {
      challenges = snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _openDialog() {
    // Backup the current state
    tempEnableReminder = enableReminder;
    tempSelectedOptions = List.from(selectedOptions);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 1.1,
            height: 720,
            child: Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: FitColors.tertiary60,
              ),
              child: AlertDialog(
                title: const Text('New Challenge Setup'),
                content: _buildDialogContent(),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Restore the state if canceled
                      setState(() {
                        enableReminder = tempEnableReminder;
                        selectedOptions = List.from(tempSelectedOptions);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _createChallenge();
                      Navigator.pop(context);
                    },
                    child: const Text('Create!'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _createChallenge() async {
    if (activityType != null && _distanceController.text.isNotEmpty && participants != null && _dateController.text.isNotEmpty) {
      final challenge = Challenge(
        activityType: activityType!,
        challengeDate: selectedDate.toLocal().toString().split(' ')[0],
        challengeId: challenges.length + 1, // Simple id generation
        challengeName: "Challenge ${challenges.length + 1}",
        challengeOwner: "By User",
        distance: double.parse(_distanceController.text),
        participantUsernames: ["User1"], // Placeholder usernames
        participations: participants!,
      );

      // Add to Firestore
      await FirebaseFirestore.instance.collection('challenges').add(challenge.toMap());

      // Add to local list
      setState(() {
        challenges.add(challenge);
      });
    }
  }

  Widget _buildDialogContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Activity type',
              border: OutlineInputBorder(),
            ),
            items: <String>['Walking', 'Running', 'Jogging'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                activityType = newValue;
              });
            },
          ),
          const SizedBox(height: 10), // Reduced height
          TextField(
            controller: _distanceController,
            decoration: const InputDecoration(
              labelText: 'Distance (Each km earns participants 10 points)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10), // Reduced height
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Participants: #',
              border: OutlineInputBorder(),
            ),
            items: List<int>.generate(50, (i) => i + 1).map((int number) {
              return DropdownMenuItem<int>(
                value: number,
                child: Text(number.toString()),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                participants = newValue;
              });
            },
          ),
          const SizedBox(height: 10), // Reduced height
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Challenge Date',
                  labelStyle: TextStyles.titleMedium.copyWith(color: FitColors.text10),
                  hintText: 'Select challenge date',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FitColors.tertiary60,
                      width: 1.1,
                    ),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5), // Reduced height
          Row(
            children: [
              const SizedBox(width: 25),
              Text('Enable Reminder'),
              const SizedBox(width: 5),
              Switch(
                value: enableReminder,
                onChanged: (value) {
                  setState(() {
                    enableReminder = value;
                    if (!value) {
                      selectedOptions = List.generate(4, (index) => false);
                    }
                  });
                },
              ),
            ],
          ),
          _buildCheckboxOption('When finish.', 0),
          _buildCheckboxOption('Every 6hr.', 1),
          _buildCheckboxOption('Every 12hr.', 2),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(String title, int index) {
    return CheckboxListTile(
      title: Text(title),
      value: selectedOptions[index],
      onChanged: (bool? value) {
        setState(() {
          selectedOptions[index] = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          ...challenges.expand((challenge) => [
            CustomChallengeCard(
              challengeName: '${challenge.distance} Km ${challenge.activityType}',
              challengeOwner: challenge.challengeOwner,
              challengeDate: challenge.challengeDate,
              challengeProgress: "0%",
              challengeParticipants: challenge.participations,
              challengeJoined: false,
              challengeParticipantsImg: challenge.participantUsernames, // Placeholder for images
            ),
            const SizedBox(height: 15),
          ]),
          ElevatedButton(
            onPressed: _openDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: FitColors.primary30,
              minimumSize: const Size(250, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Text('Create A New Challenge !',
                style: TextStyles.titleMedium.copyWith(color: FitColors.primary95)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
