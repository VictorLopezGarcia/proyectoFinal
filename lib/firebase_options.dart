import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for production (project rentmystuff-9456d).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAwegXx-SIQ73QILhTHrlqgtxKReTBTpJ8',
    appId: '1:924831462872:web:8d17db7b4881a3d328eead',
    messagingSenderId: '924831462872',
    projectId: 'rentmystuff-9456d',
    authDomain: 'rentmystuff-9456d.firebaseapp.com',
    storageBucket: 'rentmystuff-9456d.firebasestorage.app',
    measurementId: 'G-4D2Y41F1ZS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwegXx-SIQ73QILhTHrlqgtxKReTBTpJ8',
    appId: '1:924831462872:android:8d17db7b4881a3d328eead',
    messagingSenderId: '924831462872',
    projectId: 'rentmystuff-9456d',
    storageBucket: 'rentmystuff-9456d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwegXx-SIQ73QILhTHrlqgtxKReTBTpJ8',
    appId: '1:924831462872:ios:8d17db7b4881a3d328eead',
    messagingSenderId: '924831462872',
    projectId: 'rentmystuff-9456d',
    storageBucket: 'rentmystuff-9456d.firebasestorage.app',
    iosBundleId: 'com.rentmystuff.rentMyStuff',
  );
}
