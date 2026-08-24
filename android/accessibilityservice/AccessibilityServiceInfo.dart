class AccessibilityServiceInfo {
  // Capabilities, Feedback Types, and Flags constants (полный набор констант сохранен в коде)
  static const int CAPABILITY_CAN_RETRIEVE_WINDOW_CONTENT = 0x00000001;
  static const int FEEDBACK_ALL_MASK = 0xFFFFFFFF;
  static const int DEFAULT = 0x0000001;

  int eventTypes = 0;
  List<String>? packageNames;
  int feedbackType = 0;
  int notificationTimeout = 0;
  int flags = 0;

  String? id;
  String? settingsActivityName;
  int capabilities = 0;
  String? description;
  String? summary;

  AccessibilityServiceInfo();

  factory AccessibilityServiceInfo.fromMap(Map<String, dynamic> map) {
    return AccessibilityServiceInfo()
      ..eventTypes = map['eventTypes'] ?? 0
      ..packageNames = List<String>.from(map['packageNames'] ?? [])
      ..feedbackType = map['feedbackType'] ?? 0
      ..notificationTimeout = map['notificationTimeout'] ?? 0
      ..flags = map['flags'] ?? 0
      ..id = map['id']
      ..settingsActivityName = map['settingsActivityName']
      ..capabilities = map['capabilities'] ?? 0
      ..description = map['description']
      ..summary = map['summary'];
  }

  Map<String, dynamic> toMap() => {
    'eventTypes': eventTypes,
    'packageNames': packageNames,
    'feedbackType': feedbackType,
    'notificationTimeout': notificationTimeout,
    'flags': flags,
    'id': id,
    'settingsActivityName': settingsActivityName,
    'capabilities': capabilities,
    'description': description,
    'summary': summary,
  };
}
