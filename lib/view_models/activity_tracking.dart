import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_data_model.dart';
import '../models/challenge_progress.dart';
import '../models/user_model.dart' as models;

class ActivityTrackerVM {
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _linearAccelerationSubscription;
  GyroscopeEvent? _lastGyroscopeEvent;
  UserAccelerometerEvent? _lastLinearAccelerationEvent;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<ActivityData> _activityDataController =
      StreamController<ActivityData>.broadcast();
  Stream<ActivityData> get activityDataStream => _activityDataController.stream;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final UserVM _userVM = UserVM();
  late models.User? currentUser;
  double height = 160;
  double weight = 60;
  Timer? _updateTimer;
  late int stepsCount;
  late double distanceTraveled;
  late double caloriesBurned;
  late ActivityData data;
  late int activeTimeInSeconds;
  bool isGyroStep = false;
  bool isMoving = false;
  bool isStep = false;
  int get activeTimeInMinutes => (activeTimeInSeconds ~/ 60);
  Map<String, double> activityTypeDistance = {
    'walking': 0,
    'running': 0,
    'jogging': 0,
  };

  Future<ActivityData?> fetchLocalActivityData() async {
    String? dataString = await _secureStorage.read(key: 'activityData');
    if (dataString != null) {
      Map<String, dynamic> dataMap =
          json.decode(dataString) as Map<String, dynamic>;
      DateTime savedDate = DateTime.parse(dataMap['date']);
      DateTime today = DateTime.now();

      if (savedDate.isBefore(DateTime(today.year, today.month, today.day))) {
        await deleteLocalActivityData(savedDate);
        return null;
      }

      return ActivityData(
        username: dataMap['username'],
        date: savedDate,
        distanceTraveled: dataMap['distanceTraveled'],
        stepsCount: dataMap['stepsCount'],
        activeTime: dataMap['activeTime'],
        caloriesBurned: dataMap['caloriesBurned'],
        activityTypeDistance:
            Map<String, double>.from(dataMap['activityTypeDistance']),
      );
    }
    return null;
  }

  Future<void> deleteLocalActivityData(DateTime date) async {
    try {
      await _secureStorage.delete(key: 'activityData');
      if (kDebugMode) {
        print('Local activity data deleted for date: $date');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting local activity data: $e');
      }
    }
  }

  Future<DateTime?> _getLastCheckedDate() async {
    String? dateStr = await _secureStorage.read(key: 'lastCheckedDate');
    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  Future<void> _setLastCheckedDate(DateTime date) async {
    await _secureStorage.write(
      key: 'lastCheckedDate',
      value: date.toIso8601String(),
    );
  }

  Future<void> _checkAndClearOldData() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? lastCheckedDate = await _getLastCheckedDate();
    if (lastCheckedDate == null || lastCheckedDate.isBefore(today)) {
      if (lastCheckedDate != null) {
        await deleteLocalActivityData(lastCheckedDate);
      }
      await _setLastCheckedDate(today);
    }
  }

  void startTracking() async {
    await _checkAndClearOldData();
    final models.User? currentUser = await _userVM.getUserData();
    ActivityData? localActivityData = await fetchLocalActivityData();

    if (currentUser != null) {
      String? username = currentUser.userName;
      if (localActivityData == null) {
        localActivityData = await _fetchFirestoreActivityData(username!);
      } else {
        stepsCount = localActivityData.stepsCount;
        distanceTraveled = localActivityData.distanceTraveled;
        activeTimeInSeconds = localActivityData.activeTime * 60;
        caloriesBurned = localActivityData.caloriesBurned;
        activityTypeDistance = localActivityData.activityTypeDistance;
      }
      height = currentUser.height!;
      weight = currentUser.weight!;
      await _createDocumentForToday(username!);

      _linearAccelerationSubscription =
          userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
        _lastLinearAccelerationEvent = event;
        _processSensorData();
      });

      _gyroscopeSubscription =
          gyroscopeEventStream().listen((GyroscopeEvent event) {
        _lastGyroscopeEvent = event;
        _processSensorData();
        _processGyroSensorData(event);
      });
    } else {
      if (kDebugMode) {
        print('Error: Current user data not found');
      }
      await Future.delayed(const Duration(seconds: 10));
      startTracking();
    }
  }

  Future<ActivityData?> _fetchFirestoreActivityData(String username) async {
    DateTime now = DateTime.now();
    String todayDate = "${now.year}-${now.month}-${now.day}";
    String documentId = "$username-$todayDate";

    DocumentReference docRef =
        _firestore.collection('ActivityData').doc(documentId);

    try {
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        ActivityData activityData = ActivityData.fromFirestore(docSnapshot);
        activeTimeInSeconds = activityData.activeTime * 60;
        stepsCount = activityData.stepsCount;
        distanceTraveled = activityData.distanceTraveled * 1000;
        caloriesBurned = activityData.caloriesBurned;
        activityTypeDistance =
            activityData.activityTypeDistance.map((key, value) => MapEntry(
                  key,
                  value * 1000,
                ));
        await _saveLocalActivityData(activityData);
        return activityData;
      } else {
        stepsCount = 0;
        distanceTraveled = 0.0;
        activeTimeInSeconds = 0;
        caloriesBurned = 0.0;
        activityTypeDistance = {'walking': 0, 'running': 0, 'jogging': 0};
        _createDocumentForToday(currentUser!.userName!);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching document from Firestore: $error');
      }
    }
    return null;
  }

  Future<void> _createDocumentForToday(String username) async {
    DateTime now = DateTime.now();
    String todayDate = "${now.year}-${now.month}-${now.day}";
    String documentId = "$username-$todayDate";

    DocumentReference docRef =
        _firestore.collection('ActivityData').doc(documentId);

    try {
      DocumentSnapshot docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        ActivityData activityData = ActivityData(
          username: username,
          date: now,
          distanceTraveled: 0.0,
          stepsCount: 0,
          activeTime: 0,
          caloriesBurned: 0.0,
          activityTypeDistance: {
            'jogging': 0.0,
            'walking': 0.0,
            'running': 0.0,
          },
        );
        await docRef.set(activityData.toMap());
        if (kDebugMode) {
          print('Document created for today: $todayDate');
        }
      } else {
        if (kDebugMode) {
          print('Document already exists for today: $todayDate');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error creating or retrieving document: $error');
      }
    }
  }

  void _updateActivityTypeDistance(GyroscopeEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    final double magnitude = _calculateMagnitude(x, y, z);

    const double walkingThreshold = 2.5;
    const double joggingThreshold = 4;
    const double runningThreshold = 6;

    double strideLengthInMeters = calculateStrideLength(height);
    double strideLengthInKilometers = strideLengthInMeters / 1000;

    if (magnitude > runningThreshold) {
      activityTypeDistance['running'] =
          (activityTypeDistance['running'] ?? 0) + strideLengthInKilometers;
    } else if (magnitude > joggingThreshold) {
      activityTypeDistance['jogging'] =
          (activityTypeDistance['jogging'] ?? 0) + strideLengthInKilometers;
    } else if (magnitude > walkingThreshold) {
      activityTypeDistance['walking'] =
          (activityTypeDistance['walking'] ?? 0) + strideLengthInKilometers;
    }
  }

  double calculateStrideLength(double height) {
    return height * 0.7;
  }

  void stopTracking() {
    _saveLocalActivityData(ActivityData(
        username: currentUser?.userName ?? '',
        date: DateTime.now(),
        distanceTraveled: distanceTraveled,
        stepsCount: stepsCount,
        activeTime: activeTimeInMinutes,
        caloriesBurned: caloriesBurned,
        activityTypeDistance: activityTypeDistance));

    _linearAccelerationSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _updateTimer?.cancel();
  }

  Future<void> _processSensorData() async {
    final models.User? currentUser = await _userVM.getUserData();
    if (_lastLinearAccelerationEvent != null && _lastGyroscopeEvent != null) {
      _calculateStepsCount(_lastLinearAccelerationEvent!);
      _calculateActiveTime();
      _updateActivityTypeDistance(_lastGyroscopeEvent!);
      distanceTraveled = activityTypeDistance.values
          .map((distance) => distance / 1000)
          .reduce((a, b) => a + b);
      ActivityData activityData = ActivityData(
          username: currentUser?.userName ?? '',
          date: DateTime.now(),
          distanceTraveled: distanceTraveled,
          stepsCount: stepsCount,
          activeTime: activeTimeInMinutes,
          caloriesBurned: caloriesBurned,
          activityTypeDistance:
              activityTypeDistance.map((key, value) => MapEntry(
                    key,
                    value / 1000,
                  )));

      await _saveLocalActivityData(activityData);
    }
  }

  void _calculateStepsCount(UserAccelerometerEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    final double magnitude = _calculateMagnitude(x, y, z);

    const double threshold = 1;

    if (magnitude > threshold && !isStep && isGyroStep) {
      isStep = true;
      stepsCount++;
      _calculateCaloriesBurned(stepsCount);
    } else if (magnitude < threshold) {
      isStep = false;
    }
  }

  void _processGyroSensorData(GyroscopeEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    final double gyroMagnitude = _calculateMagnitude(x, y, z);

    const double movementThreshold = 1.0;

    if (gyroMagnitude > movementThreshold) {
      isGyroStep = true;
    } else {
      isGyroStep = false;
    }
  }

  double _calculateSpeed(int stepsCount) {
    double strideLengthInMeters = 0.415 * height / 100;
    double stepFrequency =
        (activeTimeInMinutes > 0) ? stepsCount / activeTimeInMinutes : 0;
    double speed = strideLengthInMeters * stepFrequency;
    return speed;
  }

  void _calculateCaloriesBurned(int newSteps) {
    double speed = _calculateSpeed(newSteps);
    double speedKmh = speed * 3.6;
    double calories = 4.5 * speedKmh * weight / 4000;

    if (calories.isNaN || calories.isInfinite) {
      calories = 0.0;
    }
    caloriesBurned = calories;
  }

  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  void _calculateActiveTime() {
    const double movementThreshold = 0.5;

    if (_lastLinearAccelerationEvent != null) {
      final double x = _lastLinearAccelerationEvent!.x;
      final double y = _lastLinearAccelerationEvent!.y;
      final double z = _lastLinearAccelerationEvent!.z;

      final double magnitude = _calculateMagnitude(x, y, z);

      if (magnitude > movementThreshold) {
        _startActiveTimeTimer();
      } else {
        _stopActiveTimeTimer();
      }
    } else {
      _stopActiveTimeTimer();
    }
  }

  void _startActiveTimeTimer() {
    if (_updateTimer == null || !_updateTimer!.isActive) {
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        activeTimeInSeconds++;
      });
    }
  }

  void _stopActiveTimeTimer() {
    _updateTimer?.cancel();
  }

  Future<void> _saveLocalActivityData(ActivityData activityData) async {
    try {
      if (activityData.distanceTraveled.isNaN ||
          activityData.distanceTraveled.isInfinite) {
        activityData.distanceTraveled = 0.0;
      }
      if (activityData.stepsCount.isNaN || activityData.stepsCount.isInfinite) {
        activityData.stepsCount = 0;
      }
      if (activityData.activeTime.isNaN || activityData.activeTime.isInfinite) {
        activityData.activeTime = 0;
      }
      if (activityData.caloriesBurned.isNaN ||
          activityData.caloriesBurned.isInfinite) {
        activityData.caloriesBurned = 0.0;
      }

      activityData.activityTypeDistance.forEach((key, value) {
        if (value.isNaN || value.isInfinite) {
          activityData.activityTypeDistance[key] = 0.0;
        }
      });

      await _secureStorage.write(
        key: 'activityData',
        value: json.encode(activityData.toMap()),
      );
      _activityDataController.add(activityData);
    } catch (e) {
      if (kDebugMode) {
        print("Error saving activity data locally: $e");
      }
    }
  }

  Future<void> checkLocalStorageData() async {
    ActivityData? localActivityData = await fetchLocalActivityData();
    if (localActivityData != null) {
      await _updateActivityDataInFirestoreWithLocalData(localActivityData);
      await _updateChallengeProgress(localActivityData);
    }
  }

  Future<void> _updateActivityDataInFirestoreWithLocalData(
      ActivityData localActivityData) async {
    try {
      final models.User? currentUser = await _userVM.getUserData();

      if (currentUser != null) {
        String? username = currentUser.userName;
        DateTime now = DateTime.now();
        String todayDate = "${now.year}-${now.month}-${now.day}";
        String documentId = "$username-$todayDate";
        DocumentReference docRef =
            _firestore.collection('ActivityData').doc(documentId);

        docRef.get().then((docSnapshot) {
          if (docSnapshot.exists) {
            Map<String, dynamic> data =
                docSnapshot.data() as Map<String, dynamic>;

            int existingStepsCount = (data['stepsCount'] ?? 0).toInt();
            double existingCaloriesBurned =
                (data['caloriesBurned'] ?? 0.0).toDouble();
            double existingDistanceTraveled =
                (data['distanceTraveled'] ?? 0.0).toDouble();
            Map<String, double> existingActivityTypeDistance =
                Map<String, double>.from(data['activityTypeDistance'] ?? {});
            int newStepsCount =
                localActivityData.stepsCount >= existingStepsCount
                    ? localActivityData.stepsCount
                    : existingStepsCount + localActivityData.stepsCount;
            int newActiveTime = localActivityData.activeTime;
            double newCaloriesBurned = existingCaloriesBurned +
                (localActivityData.caloriesBurned - existingCaloriesBurned);
            double newDistanceTraveled =
                existingDistanceTraveled + localActivityData.distanceTraveled;
            Map<String, double> newActivityTypeDistance = {
              ...existingActivityTypeDistance
            };
            localActivityData.activityTypeDistance.forEach((key, value) {
              newActivityTypeDistance[key] =
                  (newActivityTypeDistance[key] ?? 0.0) + value;
            });
            docRef.update({
              'distanceTraveled': newDistanceTraveled,
              'stepsCount': newStepsCount,
              'activeTime': newActiveTime,
              'activityTypeDistance': newActivityTypeDistance,
              'caloriesBurned': newCaloriesBurned,
            }).then((_) {
              if (kDebugMode) {
                print('Document updated successfully from local storage data');
              }
            }).catchError((error) {
              if (kDebugMode) {
                print(
                    'Error updating document from local storage data: $error');
              }
            });
          } else {
            _createDocumentForToday(username!);
            _updateActivityDataInFirestoreWithLocalData(localActivityData);
          }
        }).catchError((error) {
          if (kDebugMode) {
            print('Error retrieving document: $error');
          }
        });
      } else {
        if (kDebugMode) {
          print('Error: Current user data not found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating Firestore with local data: $e");
      }
    }
  }

  Future<void> _updateChallengeProgress(ActivityData activityData) async {
    try {
      final now = DateTime.now();
      final today =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      QuerySnapshot challengeSnapshot = await _firestore
          .collection('challengeProgress')
          .where('username', isEqualTo: activityData.username)
          .where('challengeDate', isEqualTo: today)
          .get();

      if (challengeSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print(
              "No challenge progress documents found for the user on the given date.");
        }
        return;
      }

      for (var challengeDoc in challengeSnapshot.docs) {
        ChallengeProgress challengeProgress =
            ChallengeProgress.fromFirestore(challengeDoc);

        String normalizedActivityType =
            challengeProgress.activityType.toLowerCase();
        double currentDistanceForType =
            (activityData.activityTypeDistance[normalizedActivityType] ?? 0.0) /
                1000;

        double newProgress =
            (currentDistanceForType / challengeProgress.distance) * 100;
        challengeProgress.progress = newProgress;

        if (kDebugMode) {
          print("New progress calculated: $newProgress");
        }

        await _firestore
            .collection('challengeProgress')
            .doc(challengeDoc.id)
            .update(challengeProgress.toFirestore());

        if (challengeProgress.progress >= 100) {
          await _completeChallenge(challengeProgress);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating challenge progress: $e");
      }
    }
  }

  Future<void> _completeChallenge(ChallengeProgress challengeProgress) async {
    await _firestore
        .collection('challengeProgress')
        .doc(challengeProgress.challengeId as String?)
        .update({
      'progress': 100,
    });

    DocumentReference userDoc =
        _firestore.collection('users').doc(challengeProgress.username);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userDoc);
      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>?;
        int currentScore = userData?['score'] ?? 0;
        transaction.update(userDoc,
            {'score': currentScore + (challengeProgress.distance * 10)});
      }
    });
  }

  Future<void> checkStepsCount() async {
    try {
      final UserVM userVM = UserVM();
      final models.User? currentUser = await userVM.getUserData();
      if (currentUser != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final DateTime now = DateTime.now();
        final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

        final userDocs = await FirebaseFirestore.instance
            .collection('ActivityData')
            .where('username', isEqualTo: currentUser.userName)
            .where('date',
                isGreaterThanOrEqualTo: "$formattedDate 00:00:00.000000")
            .where('date',
                isLessThanOrEqualTo: "$formattedDate 23:59:59.999999")
            .get();

        if (userDocs.docs.isNotEmpty) {
          final data = userDocs.docs.first.data();
          if (data['stepsCount'] != null) {
            int stepsCount = data['stepsCount'];
            if (stepsCount >= 10000) {
              final bool? bonusAwardedToday =
                  prefs.getBool('bonus_awarded_$formattedDate');
              if (bonusAwardedToday == null || !bonusAwardedToday) {
                final userQuery = await FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: currentUser.userName)
                    .get();
                if (userQuery.docs.isNotEmpty) {
                  final userDoc = userQuery.docs.first.reference;
                  final userSnapshot = await userDoc.get();
                  final userData = userSnapshot.data() as Map<String, dynamic>;
                  final currentScore = userData['score'] as int;

                  await userDoc.update({
                    'score': currentScore + 50,
                  });
                  await prefs.setBool('bonus_awarded_$formattedDate', true);

                  if (kDebugMode) {
                    print(
                        'Score updated for user with username: ${currentUser.userName}');
                  }
                }
              } else {
                if (kDebugMode) {
                  print('Bonus score already awarded for today');
                }
              }
            } else {
              if (kDebugMode) {
                print('Steps count is less than 10,000: $stepsCount');
              }
            }
          } else {
            if (kDebugMode) {
              print('No steps count found in the document');
            }
          }
        } else {
          if (kDebugMode) {
            print(
                'No document found for the current user in ActivityData with today\'s date');
          }
        }
      } else {
        if (kDebugMode) {
          print('No current user logged in');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking steps count: $e');
      }
    }
  }

  Future<void> deleteOldActivityData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: 7));
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS');

      QuerySnapshot activitySnapshot =
          await firestore.collection('ActivityData').get();

      for (var doc in activitySnapshot.docs) {
        String dateString = doc['date'];
        DateTime date;

        try {
          date = dateFormat.parse(dateString);
        } catch (e) {
          if (kDebugMode) {
            print(
                'Error parsing date for document ID: ${doc.id}, date string: $dateString');
          }
          continue;
        }
        if (date.isBefore(cutoffDate)) {
          await firestore.collection('ActivityData').doc(doc.id).delete();
          if (kDebugMode) {
            print('Deleted activity data for document ID: ${doc.id}');
          }
        }
      }

      if (kDebugMode) {
        print('Old activity data deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting old activity data: $e');
      }
    }
  }
}
