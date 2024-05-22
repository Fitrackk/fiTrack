import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/activity_data_model.dart';
import '../models/challenge_progress.dart';
import '../models/user_model.dart' as models;

class ActivityTrackerVM {
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _linearAccelerationSubscription;
  GyroscopeEvent? _lastGyroscopeEvent;
  UserAccelerometerEvent? _lastLinearAccelerationEvent;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final UserVM _userVM = UserVM();
  late models.User? currentUser;
  double height = 160;
  double weight = 60;
  late DateTime _currentDate;
  Timer? _updateTimer;
  late int stepsCount;
  late double distanceTraveled;
  late int activeTimeInMinutes;
  late int activeTime;
  late double caloriesBurned;
  late ActivityData data;
  int lastRecordedStepCount = 0;
  DateTime? startTime;

  void startActivity() {
    startTime ??= DateTime.now();
  }

  int getActiveTimeInMinutes() {
    if (startTime == null) return 0;
    return DateTime.now().difference(startTime!).inMinutes;
  }

  Future<void> checkDayTransition() async {
    DateTime now = DateTime.now();
    if (now.day != _currentDate.day) {
      await _updateActivityDataInFirestore();
      await deleteLocalActivityData(
          _currentDate.subtract(const Duration(days: 1)));
      _currentDate = now;
      await _createDocumentForToday(currentUser!.userName!);
    }
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

  Map<String, double> activityTypeDistance = {
    'walking': 0,
    'running': 0,
    'jogging': 0,
  };

  void startTracking() async {
    final models.User? currentUser = await _userVM.getUserData();
    String? username = currentUser?.userName;
    ActivityData? localActivityData = await fetchLocalActivityData();
    if (localActivityData == null) {
      localActivityData = await _fetchFirestoreActivityData(username!);
    } else {
      stepsCount = localActivityData.stepsCount;
      distanceTraveled = localActivityData.distanceTraveled;
      activeTimeInMinutes = localActivityData.activeTime;
      caloriesBurned = localActivityData.caloriesBurned;
      activityTypeDistance = localActivityData.activityTypeDistance;
    }
    activeTime = activeTimeInMinutes;

    if (currentUser != null) {
      String? username = currentUser.userName;
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
      });

      Timer(const Duration(minutes: 120), () {
        checkLocalStorageData();
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
        activeTimeInMinutes = activityData.activeTime;
        stepsCount = activityData.stepsCount;
        distanceTraveled = activityData.distanceTraveled;
        caloriesBurned = activityData.caloriesBurned;
        activityTypeDistance = activityData.activityTypeDistance;
        await _saveLocalActivityData(activityData);
        return activityData;
      } else {
        stepsCount = 0;
        distanceTraveled = 0.0;
        activeTimeInMinutes = 0;
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

  Future<void> _updateActivityDataInFirestore() async {
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

          double newDistanceTraveled = data['distanceTraveled'] ?? 0;
          newDistanceTraveled += distanceTraveled;
          if (newDistanceTraveled.isNaN || newDistanceTraveled.isInfinite) {
            newDistanceTraveled = 0.0;
          }

          int newStepsCount = data['stepsCount'] ?? 0;
          newStepsCount += stepsCount;
          if (newStepsCount.isNaN || newStepsCount.isInfinite) {
            newStepsCount = 0;
          }

          int newActiveTime = data['activeTime'] ?? 0;
          newActiveTime += activeTimeInMinutes;
          if (newActiveTime.isNaN || newActiveTime.isInfinite) {
            newActiveTime = 0;
          }
          activeTime += newActiveTime;
          double newCaloriesBurned = data['caloriesBurned'] ?? 0;
          newCaloriesBurned += caloriesBurned;
          if (newCaloriesBurned.isNaN || newCaloriesBurned.isInfinite) {
            newCaloriesBurned = 0.0;
          }

          Map<String, double> existingActivityTypeDistance =
              Map<String, double>.from(data['activityTypeDistance']);
          activityTypeDistance.forEach((key, value) {
            double newValue =
                (existingActivityTypeDistance[key] ?? 0) + value / 100;
            if (newValue.isNaN || newValue.isInfinite) {
              newValue = 0.0;
            }
            existingActivityTypeDistance[key] = newValue;
          });

          data['distanceTraveled'] = newDistanceTraveled;
          data['stepsCount'] = newStepsCount;
          data['activeTime'] = newActiveTime;
          data['caloriesBurned'] = newCaloriesBurned;
          data['activityTypeDistance'] = existingActivityTypeDistance;

          docRef.update(data).then((_) {
            if (kDebugMode) {
              print('Document updated successfully');
            }
          }).catchError((error) {
            if (kDebugMode) {
              print('Error updating document: $error');
            }
          });
        } else {
          _createDocumentForToday(username!);
          _updateActivityDataInFirestore();
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
  }

  void _updateActivityTypeDistance(GyroscopeEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    final double magnitude = _calculateMagnitude(x, y, z);

    const double walkingThreshold = 2;
    const double joggingThreshold = 3.5;
    const double runningThreshold = 5;

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
      activityTypeDistance: activityTypeDistance,
    ));

    _linearAccelerationSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _updateTimer?.cancel();
  }

  Future<void> _processSensorData() async {
    final models.User? currentUser = await _userVM.getUserData();
    if (_lastLinearAccelerationEvent != null && _lastGyroscopeEvent != null) {
      _currentDate = DateTime.now();
      _calculateStepsCount(_lastLinearAccelerationEvent!);
      _calculateActiveTime();
      _updateActivityTypeDistance(_lastGyroscopeEvent!);
      distanceTraveled = activityTypeDistance.values.reduce((a, b) => a + b);

      ActivityData activityData = ActivityData(
          username: currentUser?.userName ?? '',
          date: DateTime.now(),
          distanceTraveled: distanceTraveled / 1000,
          stepsCount: stepsCount,
          activeTime: activeTime + getActiveTimeInMinutes(),
          caloriesBurned: caloriesBurned,
          activityTypeDistance:
              activityTypeDistance.map((key, value) => MapEntry(
                    key,
                    value / 1000,
                  )));

      await _saveLocalActivityData(activityData);
    }
    await checkDayTransition();
  }

  void _calculateStepsCount(UserAccelerometerEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    final double magnitude = _calculateMagnitude(x, y, z);

    const double threshold = 12.0;

    if (magnitude > threshold) {
      startActivity();
      stepsCount++;
      int newSteps = stepsCount - lastRecordedStepCount;
      lastRecordedStepCount = stepsCount;
      _calculateCaloriesBurned(newSteps);
    }
  }

  double _calculateSpeed(int stepsCount) {
    double strideLengthInMeters = 0.415 * height / 100;
    int activeTimeInMinutes = getActiveTimeInMinutes();
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
    caloriesBurned += calories;
  }

  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  Future<void> _calculateActiveTime() async {
    const double movementThreshold = 0.5;

    if (_lastLinearAccelerationEvent != null) {
      final double x = _lastLinearAccelerationEvent!.x;
      final double y = _lastLinearAccelerationEvent!.y;
      final double z = _lastLinearAccelerationEvent!.z;

      final double magnitude = _calculateMagnitude(x, y, z);

      if (magnitude > movementThreshold) {
        await Future.delayed(const Duration(seconds: 1));
        activeTimeInMinutes = getActiveTimeInMinutes();
      }
    }
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
      if (kDebugMode) {
        // print("Activity data saved locally: ${activityData.toMap()}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving activity data locally: $e");
      }
    }
  }

  Future<ActivityData?> fetchLocalActivityData() async {
    String? dataString = await _secureStorage.read(key: 'activityData');
    if (dataString != null) {
      Map<String, dynamic> dataMap =
          json.decode(dataString) as Map<String, dynamic>;
      return ActivityData(
        username: dataMap['username'],
        date: DateTime.parse(dataMap['date']),
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

            int newStepsCount =
                localActivityData.stepsCount >= existingStepsCount
                    ? localActivityData.stepsCount
                    : existingStepsCount + localActivityData.stepsCount;
            int newActiveTime = localActivityData.activeTime;
            double newCaloriesBurned = existingCaloriesBurned +
                (localActivityData.caloriesBurned - existingCaloriesBurned);
            activeTime = newActiveTime;
            startTime ??= DateTime.now();
            docRef.update({
              'distanceTraveled': localActivityData.distanceTraveled,
              'stepsCount': newStepsCount,
              'activeTime': newActiveTime,
              'activityTypeDistance': localActivityData.activityTypeDistance,
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
            _updateActivityDataInFirestore();
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
        print(
            "No challenge progress documents found for the user on the given date.");
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

        print("New progress calculated: $newProgress");

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
        double currentScore = userData?['score'] ?? 0;
        transaction.update(userDoc,
            {'score': currentScore + (challengeProgress.distance * 10)});
      }
    });
  }
}
