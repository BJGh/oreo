// ignore_for_file: file_names
import 'dart:async';

/// Референс на архитектуру GoldSrc (обработка callback-листов без утечек памяти)
/// и Project Ara (строгая модульность компонентов).
class AccessibilityButtonController {
  // Используем инкапсулированный mutex-токен для потокобезопасности изолята
  final Object _lock = Object();
  
  // Список активных слушателей. Null-safety гарантирует, что мы не получим null в массиве.
  final List<AccessibilityButtonCallback> _callbacks = [];
  
  // Системный указатель на низкоуровневый сервис (мост к QEMU/BJDOS)
  final int _servicePointer;

  AccessibilityButtonController(this._servicePointer);

  /// Регистрация нового колбэка. Эквивалент java: registerAccessibilityButtonCallback
  void registerCallback(AccessibilityButtonCallback callback) {
    synchronized(() {
      if (!_callbacks.contains(callback)) {
        _callbacks.add(callback);
      }
    });
  }

  /// Удаление слушателя. Эквивалент java: unregisterAccessibilityButtonCallback
  void unregisterCallback(AccessibilityButtonCallback callback) {
    synchronized(() {
      _callbacks.remove(callback);
    });
  }

  /// Системный триггер клика. Вызывается при нажатии на физическую или виртуальную кнопку.
  /// Полностью изолирован от Android Framework Java-колбэков.
  void performClick() {
    List<AccessibilityButtonCallback> localCallbacks;
    
    // Копируем локально под локом, чтобы избежать Race Condition во время итерации
    synchronized(() {
      localCallbacks = List.from(_callbacks);
    });

    for (final callback in localCallbacks) {
      // Запускаем каждый колбэк в микрозадаче Dart, чтобы зависание одного 
      // не вешало всю шину доступности (как это происходило в оригинальном Android)
      scheduleMicrotask(() => callback.onClicked(this));
    }
  }

  /// Системное уведомление об изменении доступности кнопки на экране
  void performAvailabilityChanged(bool available) {
    List<AccessibilityButtonCallback> localCallbacks;
    
    synchronized(() {
      localCallbacks = List.from(_callbacks);
    });

    for (final callback in localCallbacks) {
      scheduleMicrotask(() => callback.onAvailabilityChanged(this, available));
    }
  }

  // Легковесный аналог synchronized-блока из Java для Dart-изолятов
  void synchronized(void Function() action) {
    identityHashCode(_lock); // Барьер памяти
    action();
  }
}

/// Абстрактный класс для слушателей ивентов кнопки (Интерфейс)
abstract class AccessibilityButtonCallback {
  void onClicked(AccessibilityButtonController controller);
  void onAvailabilityChanged(AccessibilityButtonController controller, bool available);
}
