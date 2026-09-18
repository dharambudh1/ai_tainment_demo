import "package:flutter/material.dart";

const Duration duration = Duration(seconds: 1);

class AutoScrollItem extends StatefulWidget {
  const AutoScrollItem({
    required this.shouldScroll,
    required this.child,
    super.key,
  });

  final bool shouldScroll;
  final Widget child;

  @override
  State<AutoScrollItem> createState() => _AutoScrollItemState();
}

class _AutoScrollItemState extends State<AutoScrollItem> {
  @override
  void initState() {
    super.initState();

    _triggerScrollIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AutoScrollItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.shouldScroll && widget.shouldScroll) {
      _triggerScrollIfNeeded();
    }
  }

  void _triggerScrollIfNeeded() {
    if (widget.shouldScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(duration);

        if (mounted) {
          final RenderObject? renderObject = context.findRenderObject();

          if (renderObject != null) {
            final ScrollableState? scrollable = Scrollable.maybeOf(context);

            if (scrollable != null) {
              await scrollable.position.ensureVisible(
                renderObject,
                duration: duration,
                curve: Curves.linear,
              );
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
