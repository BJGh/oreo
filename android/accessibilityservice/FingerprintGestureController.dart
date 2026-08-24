import 'dart:async';

/// Кастомный контроллер жестов сканера отпечатков пальцев для AndroiDartforArianaOS.
/// Полностью очищен от Java Handler, Binder IPC и многопоточных блокировок.
class FingerprintGestureController {
  // Константы жестов
  static const int FINGERPRINT_GESTURE_SWIPE_RIGHT = 0x00000001;
  static const int FINGERPRINT_GESTURE_SWIPE_LEFT = 0x00000002;
  static const int FINGERPRINT_GESTURE_SWIPE_UP = 0x00000004;
  static const int FINGERPRINT_GESTURE_SWIPE_DOWN = 0x00000008;

  // Список активных колбэков. Благодаря Null-Safety исключены падения из-за пустых указателей.
  final List<FingerprintGestureCallback> _callbacks = [];
  
  // Флаг доступности датчика на уровне "неЯдра" (BJDOS)
  bool _isGestureDetectionAvailable = true;

  FingerprintGestureController();

  /// Проверка доступности сканера
  bool isGestureDetectionAvailable() => _isGestureDetectionAvailable;

  /// Регистрация колбэка
  void registerFingerprintGestureCallback(FingerprintGestureCallback callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  /// Отмена регистрации колбэка
  void unregisterFingerprintGestureCallback(FingerprintGestureCallback callback) {
    _callbacks.remove(callback);
  }

  /// Системный триггер: вызывается при изменении активности сенсора (код для QEMU/BJDOS)
  void onGestureDetectionActiveChanged(bool active) {
    _isGestureDetectionAvailable = active;
    final localCallbacks = List<FingerprintGestureCallback>.from(_callbacks);
    
    for (final callback in localCallbacks) {
      scheduleMicrotask(() => callback.onGestureDetectionAvailabilityChanged(active));
    }
  }

  /// Системный триггер: вызывается из низкого уровня при фиксации жеста пальцем
  void onGesture(int gesture) {
    final localCallbacks = List<FingerprintGestureCallback>.from(_callbacks);
    
    for (final callback in localCallbacks) {
      scheduleMicrotask(() => callback.onGestureDetected(gesture));
    }
  }
}

/// Абстрактный класс-слушатель событий сканера
abstract class FingerprintGestureCallback {
  void onGestureDetectionAvailabilityChanged(bool available) {}
  void onGestureDetected(int gesture) {}
}
