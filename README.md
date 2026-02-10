# auto_scroll_positioned_list

Continuous auto-scroll controller + widget wrapper for `scrollable_positioned_list`.

## Features

- Continuous chunk scrolling (default 100ms) for responsive stop/speed updates
- Pause auto-scroll on user drag, resume after release
- Speed levels + increase/decrease speed
- Optional tap-to-toggle

## Usage

```dart
final controller = AutoScrollController();

AutoScrollablePositionedList.builder(
  controller: controller,
  itemCount: 300,
  onTap: controller.toggle,
  itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
);
```
