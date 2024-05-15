import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/activity_data_model.dart';
import '../models/user_model.dart' as models;

class ActivityTrackerViewModel {
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _linearAccelerationSubscription;
  GyroscopeEvent? _lastGyroscopeEvent;
  UserAccelerometerEvent? _lastLinearAccelerationEvent;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserVM _userVM = UserVM();
  late models.User? currentUser;
  late double height;
  Timer? _updateTimer;
  int stepsCount = 0;
  double distanceTraveled = 0;
  int activeTimeInSeconds = 0;

  int get activeTimeInMinutes => (activeTimeInSeconds ~/ 60);

  Map<String, double> activityTypeDistance = {
    'walking': 0,
    'running': 0,
    'jogging': 0,
  };

  void startTracking() async {
    final models.User? currentUser = await _userVM.getUserData();
    if (currentUser != null) {
      height = currentUser.height!;
    } else {
      height = 160;
    }
    if (currentUser != null) {
      String? username = currentUser.userName;
      await _createDocumentForToday(username!);
    } else {
      if (kDebugMode) {
        print('Error: Current user data not found');
      }
    }

    _linearAccelerationSubscription =
        userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      _lastLinearAccelerationEvent = event;
      if (kDebugMode) {
        print('Linear Acceleration Event received: $event');
      }
      _processSensorData();
    });

    _gyroscopeSubscription =
        gyroscopeEventStream().listen((GyroscopeEvent event) {
      _lastGyroscopeEvent = event;
      _processSensorData();
    });
    _updateTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _updateActivityDataInFirestore();
    });
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
          Map<String, double> activityTypeDistanceAsString = {};
          activityTypeDistance.forEach((key, value) {
            activityTypeDistanceAsString[key.toString()] = value;
          });

          docRef.update({
            'distanceTraveled': distanceTraveled / 1000,
            'stepsCount': stepsCount,
            'activeTime': activeTimeInMinutes,
            'activityTypeDistance': activityTypeDistanceAsString,
          }).then((_) {
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

    const double walkingThreshold = 0.1;
    const double joggingThreshold = 0.5;
    const double runningThreshold = 1.0;

    if (magnitude > runningThreshold) {
      activityTypeDistance['running'] =
          (activityTypeDistance['running'] ?? 0) + magnitude;
    } else if (magnitude > joggingThreshold) {
      activityTypeDistance['jogging'] =
          (activityTypeDistance['jogging'] ?? 0) + magnitude;
    } else if (magnitude > walkingThreshold) {
      activityTypeDistance['walking'] =
          (activityTypeDistance['walking'] ?? 0) + magnitude;
    }
  }

  void stopTracking() {
    _linearAccelerationSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _updateTimer?.cancel();
  }

  void _processSensorData() {
    if (_lastLinearAccelerationEvent != null) {
      _calculateStepsCount(_lastLinearAccelerationEvent!);
    }

    if (_lastGyroscopeEvent != null) {
      _calculateActiveTime(_lastGyroscopeEvent!);
      _updateActivityTypeDistance(_lastGyroscopeEvent!);
    }
  }

  void _calculateStepsCount(UserAccelerometerEvent event) {
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    final double magnitude = _calculateMagnitude(x, y, z);

    const double threshold = 10.0;

    if (magnitude > threshold) {
      stepsCount++;

      double distanceTraveled = calculateDistancePerStep(stepsCount);
      if (kDebugMode) {
        print('Steps Count: $stepsCount');
      }
      if (kDebugMode) {
        print('Distance Traveled: $distanceTraveled meters');
      }

      double speed = _calculateSpeed(stepsCount);

      String activity = _categorizeActivity(speed);
      if (kDebugMode) {
        print('Activity: $activity');
      }

      double caloriesBurned = _calculateCaloriesBurned(stepsCount, speed);
      if (kDebugMode) {
        print('Calories Burned: $caloriesBurned kcal');
      }
    }
  }

  String _categorizeActivity(double speed) {
    if (speed > 2.0) {
      return 'running';
    } else if (speed > 1.0) {
      return 'jogging';
    } else {
      return 'walking';
    }
  }

  void _calculateActiveTime(GyroscopeEvent event) {
    _startActiveTimeCounter();
  }

  void _startActiveTimeCounter() {
    activeTimeInSeconds++;
  }

  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  double _calculateSpeed(int stepsPer2Seconds) {
    double stride = calculateStride(stepsPer2Seconds);
    return stepsPer2Seconds * stride / 2;
  }

  double calculateDistancePerStep(int stepsCount) {
    return stepsCount / 1490;
  }

  double calculateStride(int stepsPer2Seconds) {
    if (stepsPer2Seconds >= 8) {
      return 1.2 * height;
    } else if (stepsPer2Seconds >= 6) {
      return height;
    } else if (stepsPer2Seconds >= 5) {
      return height / 1.2;
    } else if (stepsPer2Seconds >= 4) {
      return height / 2;
    } else if (stepsPer2Seconds >= 3) {
      return height / 3;
    } else if (stepsPer2Seconds >= 2) {
      return height / 4;
    } else {
      return height / 5;
    }
  }

  double _calculateCaloriesBurned(int stepsCount, double speed) {
    double weight = currentUser?.weight ?? 70;
    double speedMetersPerSecond = speed * 1000 / 3600;

    double caloriesPerSecond = 4.5 * speedMetersPerSecond;

    int totalActiveTimeInSeconds = activeTimeInSeconds ~/ 2;

    double totalCaloriesBurned =
        caloriesPerSecond * weight * totalActiveTimeInSeconds;

    return totalCaloriesBurned;
  }
}
