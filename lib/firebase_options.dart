import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase not configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'Firebase not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7vsiNX_9vmR5XFCr3-RJwh6OMEj2tcRs',
    appId: '1:143704227409:web:4c68f6cc95216e20038270',
    messagingSenderId: '143704227409',
    projectId: 'coffee-app-7cc80',
    authDomain: 'coffee-app-7cc80.firebaseapp.com',
    storageBucket: 'coffee-app-7cc80.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClN2-D_iTO67bZe5LIM3L9cqBP6Ra5eqo',
    appId: '1:143704227409:android:31d764d4dfa99bb8038270',
    messagingSenderId: '143704227409',
    projectId: 'coffee-app-7cc80',
    storageBucket: 'coffee-app-7cc80.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDz4Ct397VvYuLgfh7KBKOZ74855-L64RQ',
    appId: '1:143704227409:ios:23d16d493421f899038270',
    messagingSenderId: '143704227409',
    projectId: 'coffee-app-7cc80',
    storageBucket: 'coffee-app-7cc80.firebasestorage.app',
    iosBundleId: 'com.example.coffeeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDz4Ct397VvYuLgfh7KBKOZ74855-L64RQ',
    appId: '1:143704227409:ios:23d16d493421f899038270',
    messagingSenderId: '143704227409',
    projectId: 'coffee-app-7cc80',
    storageBucket: 'coffee-app-7cc80.firebasestorage.app',
    iosBundleId: 'com.example.coffeeApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7vsiNX_9vmR5XFCr3-RJwh6OMEj2tcRs',
    appId: '1:143704227409:web:5d958a1c20badbb7038270',
    messagingSenderId: '143704227409',
    projectId: 'coffee-app-7cc80',
    authDomain: 'coffee-app-7cc80.firebaseapp.com',
    storageBucket: 'coffee-app-7cc80.firebasestorage.app',
  );
}
