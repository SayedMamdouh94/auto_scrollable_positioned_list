import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AutoScrollController extends ChangeNotifier {
  AutoScrollController({
    double initialSpeed = 0.00310,
    List<double>? speedLevels,
    this.chunkDuration = const Duration(milliseconds: 100),
    this.curve = Curves.linear,
    this.minChunkPixels = 1.0,
    this.maxChunkPixels = 200.0,
    this.pausePoll = const Duration(milliseconds: 100),
  })  : _speed = initialSpeed,
        _speedLevels = speedLevels ?? _defaultSpeedLevels;

  final Duration chunkDuration;
  final Duration pausePoll;
  final Curve curve;
  final double minChunkPixels;
  final double maxChunkPixels;

  ItemScrollController? _itemScrollController;
  ScrollOffsetController? _scrollOffsetController;
  ItemPositionsListener? _positionsListener;

  int _itemCount = 0;
  double _viewportExtent = 0;

  bool _running = false;
  bool _paused = false;

  bool get isRunning => _running;
  bool get isPaused => _paused;

  double _speed;
  double get speed => _speed;

  final List<double> _speedLevels;

  void bind({
    required ItemScrollController itemScrollController,
    required ScrollOffsetController scrollOffsetController,
    required ItemPositionsListener positionsListener,
    required int itemCount,
    required double viewportExtent,
  }) {
    _itemScrollController = itemScrollController;
    _scrollOffsetController = scrollOffsetController;
    _positionsListener = positionsListener;
    _itemCount = itemCount;
    _viewportExtent = viewportExtent;
  }

  Future<void> start({int? untilIndex}) async {
    if (_running) return;
    _running = true;
    _paused = false;
    notifyListeners();

    try {
      final isc = _itemScrollController;
      final soc = _scrollOffsetController;
      final pl = _positionsListener;

      if (isc == null || soc == null || pl == null) return;

      int tries = 0;
      while (!isc.isAttached && tries < 30 && _running) {
        tries++;
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (!isc.isAttached || !_running) return;

      while (_running && isc.isAttached) {
        if (_paused) {
          await Future.delayed(pausePoll);
          continue;
        }

        if (_isAtEnd(pl, untilIndex: untilIndex)) break;

        final secondsPerChunk = chunkDuration.inMilliseconds / 1000.0;
        final pixelsPerPage = _viewportExtent <= 0 ? 800.0 : _viewportExtent;

        final chunkPixels = (_speed * pixelsPerPage * secondsPerChunk)
            .clamp(minChunkPixels, maxChunkPixels)
            .toDouble();

        await soc.animateScroll(
          offset: chunkPixels,
          duration: chunkDuration,
          curve: curve,
        );
      }
    } catch (_) {
      // swallow, stop safely
    } finally {
      _running = false;
      _paused = false;
      notifyListeners();
    }
  }

  void stop() {
    if (!_running && !_paused) return;
    _running = false;
    _paused = false;
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _paused = true;
    notifyListeners();
  }

  void resume() {
    if (!_running) return;
    _paused = false;
    notifyListeners();
  }

  Future<void> toggle({int? untilIndex}) async {
    if (_running) {
      stop();
    } else {
      unawaited(start(untilIndex: untilIndex));
    }
  }

  bool _isAtEnd(ItemPositionsListener pl, {int? untilIndex}) {
    final positions = pl.itemPositions.value;
    if (positions.isEmpty) return false;

    final target = untilIndex ?? (_itemCount - 1);
    if (target < 0) return true;

    return positions.any(
      (p) => p.index == target && p.itemTrailingEdge <= 1.0,
    );
  }

  static final List<double> _defaultSpeedLevels = [
    0.00310,
    0.00610,
    0.00910,
    0.01210,
    0.01510,
    0.01810,
    0.02110,
    0.02410,
    0.02710,
    0.03010,
    0.03310,
  ];

  int getCurrentSpeedLevel() {
    int closest = 0;
    double minDiff = double.infinity;

    for (int i = 0; i < _speedLevels.length; i++) {
      final diff = (speed - _speedLevels[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }
    return closest;
  }

  bool get isAtMinSpeed => getCurrentSpeedLevel() == 0;
  bool get isAtMaxSpeed => getCurrentSpeedLevel() == _speedLevels.length - 1;

  void setSpeed(double newSpeed) {
    _speed = newSpeed;
    notifyListeners();
  }

  void increaseSpeed() {
    final i = getCurrentSpeedLevel();
    if (i < _speedLevels.length - 1) setSpeed(_speedLevels[i + 1]);
  }

  void decreaseSpeed() {
    final i = getCurrentSpeedLevel();
    if (i > 0) setSpeed(_speedLevels[i - 1]);
  }
}
