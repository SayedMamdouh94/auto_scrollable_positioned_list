import 'package:flutter_test/flutter_test.dart';

import 'package:auto_scroll_positioned_list/auto_scroll_positioned_list.dart';

void main() {
  test('AutoScrollController initializes with default values', () {
    final controller = AutoScrollController();
    expect(controller.isRunning, false);
    expect(controller.isPaused, false);
    expect(controller.speed, 0.00310);
  });

  test('AutoScrollController initializes with custom speed', () {
    final controller = AutoScrollController(initialSpeed: 0.5);
    expect(controller.speed, 0.5);
  });
}
