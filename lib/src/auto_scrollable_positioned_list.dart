import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'auto_scroll_controller.dart';

class AutoScrollablePositionedList extends StatefulWidget {
  const AutoScrollablePositionedList.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.controller,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.dragDistanceThreshold = 10,
    this.resumeDelay = const Duration(milliseconds: 500),
    this.pauseOnUserDrag = true,
    this.onTap,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.minCacheExtent,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final AutoScrollController controller;

  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsets? padding;

  final double dragDistanceThreshold;
  final Duration resumeDelay;
  final bool pauseOnUserDrag;

  /// If you want: tap toggles autoscroll (like your Tahajjud mode).
  final VoidCallback? onTap;

  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final double? minCacheExtent;

  @override
  State<AutoScrollablePositionedList> createState() =>
      _AutoScrollablePositionedListState();
}

class _AutoScrollablePositionedListState
    extends State<AutoScrollablePositionedList> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  Offset? _pointerDown;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportExtent = widget.scrollDirection == Axis.vertical
            ? constraints.biggest.height
            : constraints.biggest.width;

        widget.controller.bind(
          itemScrollController: _itemScrollController,
          scrollOffsetController: _scrollOffsetController,
          positionsListener: _positionsListener,
          itemCount: widget.itemCount,
          viewportExtent: viewportExtent,
        );

        return GestureDetector(
          onTap: widget.onTap,
          child: Listener(
            onPointerDown: (e) => _pointerDown = e.position,
            onPointerMove: (e) {
              if (!widget.pauseOnUserDrag) return;
              if (_pointerDown == null) return;

              final distance = (e.position - _pointerDown!).distance;
              if (distance > widget.dragDistanceThreshold) {
                if (widget.controller.isRunning &&
                    !widget.controller.isPaused) {
                  widget.controller.pause();
                }
                _pointerDown = null; // mark as drag
              }
            },
            onPointerUp: (_) {
              final wasDrag = _pointerDown == null;

              if (widget.pauseOnUserDrag &&
                  wasDrag &&
                  widget.controller.isRunning) {
                Future.delayed(widget.resumeDelay, () {
                  if (mounted && widget.controller.isRunning) {
                    widget.controller.resume();
                  }
                });
              }

              _pointerDown = null;
            },
            child: ScrollablePositionedList.builder(
              physics: widget.physics,
              scrollDirection: widget.scrollDirection,
              reverse: widget.reverse,
              padding: widget.padding,
              itemCount: widget.itemCount,
              itemBuilder: widget.itemBuilder,
              itemScrollController: _itemScrollController,
              itemPositionsListener: _positionsListener,
              scrollOffsetController: _scrollOffsetController,
              addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
              addRepaintBoundaries: widget.addRepaintBoundaries,
              minCacheExtent: widget.minCacheExtent,
            ),
          ),
        );
      },
    );
  }
}
