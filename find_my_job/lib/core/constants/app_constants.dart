// Core constants for the FindMyJob app

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'FindMyJob';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String candidateProfilesCollection = 'candidateProfiles';
  static const String companyProfilesCollection = 'companyProfiles';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String savedJobsCollection = 'savedJobs';
  static const String notificationsCollection = 'notifications';

  // Firebase Storage paths
  static const String cvStorageFolder = 'cvs';
  static const String profilePhotosFolder = 'profilePhotos';
  static const String companyLogosFolder = 'companyLogos';

  // Constraints
  static const int cvMaxSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const List<String> cvAllowedExtensions = ['pdf'];
  static const String cvAllowedMimeType = 'application/pdf';

  // Geo
  static const double defaultSearchRadiusKm = 25.0;
  static const double defaultMapZoom = 13.0;
  static const int geohashPrecision = 6; // ~1.2km cell

  // Matching
  static const int recommendedJobsLimit = 50;
  static const int nearbyJobsLimit = 100;

  // Pagination
  static const int jobsPageSize = 20;
  static const int applicationsPageSize = 20;

  // UI
  static const double cardBorderRadius = 16.0;
  static const double bottomSheetBorderRadius = 24.0;
  static const double defaultPadding = 16.0;

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);
}
