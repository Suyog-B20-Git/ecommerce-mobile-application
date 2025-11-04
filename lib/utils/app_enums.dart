import 'package:flutter/material.dart';

enum StorageKey {
  isLaunch,
  userToken,
  userId,
  userEmail,
  userName,
  accessToken,
  refreshToken,
  onboardingCompleted,
  recentSearches;

  String get name => switch (this) {
    StorageKey.isLaunch => 'isLaunch',
    StorageKey.userToken => 'userToken',
    StorageKey.userId => 'userId',
    StorageKey.userEmail => 'userEmail',
    StorageKey.userName => 'userName',
    StorageKey.accessToken => 'accessToken',
    StorageKey.refreshToken => 'refreshToken',
    StorageKey.onboardingCompleted => 'onboardingCompleted',
    StorageKey.recentSearches => 'recentSearches',
  };
}

enum ApiMethod { get, post, put, delete, patch, multipart }

typedef OnSuccessCallback = Future<void> Function(dynamic response);

class PendingRequest {
  final ApiMethod method;
  final String url;
  final Map<String, dynamic>? queryParams;
  final dynamic params;
  final BuildContext? context;
  final bool showLoading;
  final OnSuccessCallback? onSuccess;

  PendingRequest({
    required this.method,
    required this.url,
    this.queryParams,
    this.params,
    this.context,
    this.showLoading = false,
    this.onSuccess,
  });
}

enum UserRole {
  admin,
  counsellor,
  trainer,
  accountant,
  placementOfficer,
  student,
}

enum CourseStatus { active, inactive }

enum BatchStatus { ongoing, upcoming, completed, cancelled }

enum StudentStatus { active, inactive }

enum EnrollmentStatus { active, completed, dropped, suspended }
