import 'dart:async';

/// Кастомная реализация AccessibilityService для AndroiDartforArianaOS
abstract class AccessibilityService {
  // Константы жестов
  static const int GESTURE_SWIPE_UP = 1;
  static const int GESTURE_SWIPE_DOWN = 2;
  static const int GESTURE_SWIPE_LEFT = 3;
  static const int GESTURE_SWIPE_RIGHT = 4;
  
  // Глобальные действия
  static const int GLOBAL_ACTION_BACK = 1;
  static const int GLOBAL_ACTION_HOME = 2;
  static const int GLOBAL_ACTION_RECENTS = 3;
  static const int GLOBAL_ACTION_NOTIFICATIONS = 4;

  int _connectionId = 0;
  bool _isConnected = false;

  /// Абстрактные методы, которые реализует кастомный сервис
  void onAccessibilityEvent(Map<String, dynamic> event);
  void onInterrupt();

  void onServiceConnected() {
    _isConnected = true;
    print("🤖 [AndroiDart]: Сервис успешно подключен без Java!");
  }

  bool onGesture(int gestureId) => false;
  bool onKeyEvent(Map<String, dynamic> keyEvent) => false;

  void init(int connectionId) {
    _connectionId = connectionId;
    onServiceConnected();
  }
}

/// Контроллер масштабирования, переведенный с Java на чистый Dart
class MagnificationController {
  final List<OnMagnificationChangedListener> _listeners = [];

  void addListener(OnMagnificationChangedListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(OnMagnificationChangedListener listener) {
    _listeners.remove(listener);
  }

  void dispatchMagnificationChanged(double scale, double centerX, double centerY) {
    for (final listener in _listeners) {
      scheduleMicrotask(() => listener.onMagnificationChanged(this, scale, centerX, centerY));
    }
  }
}

abstract class OnMagnificationChangedListener {
  void onMagnificationChanged(MagnificationController controller, double scale, double centerX, double centerY);
}
