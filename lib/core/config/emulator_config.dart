class EmulatorConfig {
  static const bool useEmulators = true;

  static const String firestoreHost = '127.0.0.1';
  static const int firestorePort = 8080;

  static const String authHost = '127.0.0.1';
  static const int authPort = 9099;

  static const String storageHost = '127.0.0.1';
  static const int storagePort = 9199;

  static bool get shouldUseEmulators => useEmulators;
}
