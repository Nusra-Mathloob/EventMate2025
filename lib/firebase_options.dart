import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions for web not configured. Run flutterfire configure or add web settings.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'FirebaseOptions for iOS not configured. Add GoogleService-Info.plist and update firebase_options.dart.',
        );
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions for ${defaultTargetPlatform.name} not configured.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqlVmcq3c4c4pce1bwkWyw4MSvBt11kxo',
    appId: '1:521681290828:android:77eab4cfd0611acfc3d6e9',
    messagingSenderId: '521681290828',
    projectId: 'eventmate-3b243',
    storageBucket: 'eventmate-3b243.firebasestorage.app',
  );
}
