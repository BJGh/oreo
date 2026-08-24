import 'dart:math';

/// Описание жестов для AndroiDartforArianaOS.
/// Полностью очищено от тяжелых Java-зависимостей, PathMeasure и Android-графики.
class GestureDescription {
  static const int MAX_STROKE_COUNT = 10;
  static const int MAX_GESTURE_DURATION_MS = 60000;

  final List<StrokeDescription> strokes;

  GestureDescription._internal(this.strokes);

  static int getMaxStrokeCount() => MAX_STROKE_COUNT;
  static int getMaxGestureDuration() => MAX_GESTURE_DURATION_MS;

  int get strokeCount => strokes.length;
  StrokeDescription getStroke(int index) => strokes[index];

  /// Получение точек касания для конкретного момента времени (расчет для QEMU/BJDOS)
  List<TouchPoint> getPointsForTime(int timeMs) {
    final List<TouchPoint> points = [];
    for (final stroke in strokes) {
      if (stroke.hasPointForTime(timeMs)) {
        final pos = stroke.getPosForTime(timeMs);
        points.add(TouchPoint(
          strokeId: stroke.id,
          x: pos.x.round(),
          y: pos.y.round(),
          isStart: timeMs == stroke.startTime,
          isEnd: timeMs == stroke.endTime,
        ));
      }
    }
    return points;
  }
}

/// Иммутабельное описание одной непрерывной линии/касания в жесте
class StrokeDescription {
  static int _idCounter = 0;

  final int id;
  final List<Point<double>> points; // Замена тяжелого Android Path на чистый массив точек
  final int startTime;
  final int endTime;
  final int duration;

  StrokeDescription({
    required this.points,
    required this.startTime,
    required this.duration,
  })  : id = _idCounter++,
        endTime = startTime + duration {
    if (points.isEmpty) {
      throw ArgumentError("Линия жеста должна содержать хотя бы одну точку (касание).");
    }
  }

  bool hasPointForTime(int timeMs) => timeMs >= startTime && timeMs <= endTime;

  /// Линейная интерполяция позиции пальца на экране во времени
  Point<double> getPosForTime(int timeMs) {
    if (points.length == 1 || duration == 0) return points.first;
    
    // Вычисляем прогресс движения от 0.0 до 1.0
    double progress = (timeMs - startTime) / duration;
    progress = progress.clamp(0.0, 1.0);

    // Упрощенный расчет позиции между ключевыми точками
    int index = (progress * (points.length - 1)).floor();
    if (index >= points.length - 1) return points.last;

    final p1 = points[index];
    final p2 = points[index + 1];
    
    double segmentProgress = (progress * (points.length - 1)) - index;

    return Point(
      p1.x + (p2.x - p1.x) * segmentProgress,
      p1.y + (p2.y - p1.y) * segmentProgress,
    );
  }
}

/// Легковесная структура финальной точки тача для передачи в драйвер ядра QEMU
class TouchPoint {
  final int strokeId;
  final int x;
  final int y;
  final bool isStart;
  final bool isEnd;

  TouchPoint({
    required this.strokeId,
    required this.x,
    required this.y,
    required this.isStart,
    required this.isEnd,
  });
}

/// Паттерн Строитель (Builder) для сборки сложного многопальцевого жеста
class GestureDescriptionBuilder {
  final List<StrokeDescription> _strokes = [];

  GestureDescriptionBuilder addStroke(StrokeDescription stroke) {
    if (_strokes.length >= GestureDescription.MAX_STROKE_COUNT) {
      throw StateError("Превышено максимальное количество одновременных касаний.");
    }
    _strokes.add(stroke);
    return this;
  }

  GestureDescription build() {
    if (_strokes.isEmpty) {
      throw StateError("Жест должен содержать хотя бы одну траекторию.");
    }
    return GestureDescription._internal(List.unmodifiable(_strokes));
  }
}
