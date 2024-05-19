import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/activity_data_model.dart';
import '../models/user_model.dart' as models;

class ActivityTrackerViewModel {
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
  Timer? _updateTimer;
  late int stepsCount;
  late double distanceTraveled;
  late int activeTimeInSeconds;
  late double caloriesBurned;

  int get activeTimeInMinutes => (activeTimeInSeconds ~/ 360);
  late DateTime lastUpdateTime;
  Map<String, double> activityTypeDistance = {
    'walking': 0,
    'running': 0,
    'jogging': 0,
  };

  void startTracking() async {
    final models.User? currentUser = await _userVM.getUserData();
    ActivityData? localActivityData = await fetchLocalActivityData();
    lastUpdateTime = DateTime.now();
    stepsCount = localActivityData?.stepsCount ?? 0;
    distanceTraveled = localActivityData?.distanceTraveled ?? 0;
    activeTimeInSeconds = localActivityData?.activeTime ?? 0;
    caloriesBurned = localActivityData?.caloriesBurned ?? 0;
    activityTypeDistance = localActivityData?.activityTypeDistance ??
        {
          'walking': 0,
          'running': 0,
          'jogging': 0,
        };

    if (currentUser != null) {
      String? username = currentUser.userName;
      height = currentUser.height!;
      weight = currentUser.weight!;
      await _createDocumentForToday(username!);

      _linearAccelerationSubscription =
          userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
        _lastLinearAccelerationEvent = event;
        if (kDebugMode) {
          //print('Linear Acceleration Event received: $event');
        }
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
          // print('Document created for today: $todayDate');
        }
      } else {
        if (kDebugMode) {
          // print('Document already exists for today: $todayDate');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        // print('Error creating or retrieving document: $error');
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

          data['distanceTraveled'] =
              (data['distanceTraveled'] ?? 0) + distanceTraveled / 1000;
          data['stepsCount'] = (data['stepsCount'] ?? 0) + stepsCount;
          data['activeTime'] = (data['activeTime'] ?? 0) + activeTimeInSeconds;
          data['caloriesBurned'] =
              (data['caloriesBurned'] ?? 0) + caloriesBurned;

          Map<String, double> existingActivityTypeDistance =
              Map<String, double>.from(data['activityTypeDistance']);
          activityTypeDistance.forEach((key, value) {
            existingActivityTypeDistance[key] =
                (existingActivityTypeDistance[key] ?? 0) + value / 1000;
          });
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

    const double walkingThreshold = 3;
    const double joggingThreshold = 4;
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
    return height * 0.415;
  }

  void stopTracking() {
    _saveLocalActivityData(ActivityData(
      username: currentUser?.userName ?? '',
      date: DateTime.now(),
      distanceTraveled: distanceTraveled / 1000,
      stepsCount: stepsCount,
      activeTime: activeTimeInSeconds,
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
      _calculateStepsCount(_lastLinearAccelerationEvent!);
      _calculateActiveTime();
      _updateActivityTypeDistance(_lastGyroscopeEvent!);

      ActivityData activityData = ActivityData(
        username: currentUser?.userName ?? '',
        date: DateTime.now(),
        distanceTraveled: distanceTraveled / 1000,
        stepsCount: stepsCount,
        activeTime: activeTimeInMinutes,
        caloriesBurned: caloriesBurned,
        activityTypeDistance: activityTypeDistance,
      );

      await _saveLocalActivityData(activityData);
      if (kDebugMode) {
        // print(
        //     "Local activity data saved: ${json.encode(activityData.toMap())}"
        // );
      }
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
      distanceTraveled = calculateDistancePerStep(stepsCount);
      double speed = _calculateSpeed(stepsCount);
      caloriesBurned = _calculateCaloriesBurned(speed, weight);
      if (kDebugMode) {
        // print('Steps Count: $stepsCount');
      }
      if (kDebugMode) {
        // print('Distance Traveled: $distanceTraveled meters');
      }
      if (kDebugMode) {
        // print('Calories Burned: $caloriesBurned kcal');
      }
    }
  }

  double calculateDistancePerStep(int stepsCount) {
    double heightInMeters = height / 100;
    double stepLengthInMeters = heightInMeters * 0.414;
    return stepsCount * stepLengthInMeters;
  }

  double _calculateSpeed(int stepsCount) {
    double strideLengthInMeters = 0.415 * height / 100;
    double stepFrequency = stepsCount / activeTimeInSeconds;
    return strideLengthInMeters * stepFrequency;
  }

  double _calculateCaloriesBurned(double speed, double weight) {
    double speedKmh = speed * 3.6;
    double calories = 4.5 * speedKmh * weight / 100;
    return calories;
  }

  Future<void> _calculateActiveTime() async {
    const double movementThreshold = 0.05;

    if (_lastLinearAccelerationEvent != null) {
      final double x = _lastLinearAccelerationEvent!.x;
      final double y = _lastLinearAccelerationEvent!.y;
      final double z = _lastLinearAccelerationEvent!.z;

      final double magnitude = _calculateMagnitude(x, y, z);

      if (magnitude > movementThreshold) {
        await Future.delayed(const Duration(seconds: 1));
        activeTimeInSeconds += 1;
        if (kDebugMode) {
          // print('Active Time: $activeTimeInSeconds seconds');
        }
      }
    }
  }

  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  Future<void> _saveLocalActivityData(ActivityData activityData) async {
    try {
      await _secureStorage.write(
        key: 'activityData',
        value: json.encode(activityData.toMap()),
      );
      if (kDebugMode) {
        //print("Activity data saved locally: ${activityData.toMap()}");
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
            Map<String, double> activityTypeDistanceInKilometers = {};
            localActivityData.activityTypeDistance.forEach((key, value) {
              activityTypeDistanceInKilometers[key.toString()] = value / 1000;
            });

            docRef.update({
              'distanceTraveled': localActivityData.distanceTraveled,
              'stepsCount': localActivityData.stepsCount,
              'activeTime': localActivityData.activeTime,
              'activityTypeDistance': activityTypeDistanceInKilometers,
              'caloriesBurned': localActivityData.caloriesBurned,
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
}
