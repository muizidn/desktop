import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'theme.dart';
import 'internal/toggleable.dart';

class ToggleSwitch extends StatefulWidget {
  const ToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  final bool value;

  final ValueChanged<bool?>? onChanged;

  final FocusNode? focusNode;

  final bool autofocus;

  // The width of dat toggle
  static const double width = 32.0;
  static const double height = 16.0;
  static const double radius = 8.0;
  static const double strokeWidth = 2.0;

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch>
    with TickerProviderStateMixin {
  bool get enabled => widget.onChanged != null;
  // Map<LocalKey, ActionFactory> _actionMap;

  @override
  void initState() {
    super.initState();
    // _actionMap = <LocalKey, ActionFactory>{
    //   ActivateAction.key: () =>
    //       CallbackAction(ActivateAction.key, onInvoke: _actionHandler),
    // };
  }

  void _actionHandler(FocusNode node, Intent intent) {
    if (widget.onChanged != null) {
      // FIXME
      switch (widget.value) {
        case false:
          widget.onChanged!(true);
          break;
        case true:
          widget.onChanged!(false);
          break;
        default: // case null:
          widget.onChanged!(false);
          break;
      }
    }

    final RenderObject renderObject = node.context!.findRenderObject()!;
    renderObject.sendSemanticsEvent(const TapSemanticEvent());
  }

  bool _hovering = false;
  void _handleHoverChanged(bool hovering) {
    setState(() {
      _hovering = hovering;
    });
  }

  bool _focused = false;
  void _handleFocusHighlightChanged(bool focused) {
    if (focused != _focused) {
      setState(() {
        _focused = focused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final background = colorScheme.background;
    //Size size = const Size();

    //final BoxConstraints constraints = BoxConstraints.tight(size);

    final effectiveHoverColor = colorScheme.primary;
    final effectiveActiveColor = colorScheme.primary2;

    final foregroundColor = enabled
        ? textTheme.foreground(background)
        : textTheme.disabledForeground(background);

    final Size size = Size(ToggleSwitch.width, ToggleSwitch.height);

    final BoxConstraints additionalConstraints = BoxConstraints.tight(size);

    final focusColor = foregroundColor; // FIXME

    return FocusableActionDetector(
        // actions: _actionMap,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: enabled,
        onShowHoverHighlight: _handleHoverChanged,
        onShowFocusHighlight: _handleFocusHighlightChanged,
        child: Builder(
          builder: (BuildContext context) {
            return _ToggleSwitchRenderObjectWidget(
              value: widget.value,
              activeColor: effectiveActiveColor.toColor(),
              inactiveColor: enabled
                  ? colorScheme.overlay5.toColor()
                  : colorScheme.overlay3.toColor(),
              hoverColor: effectiveHoverColor.toColor(),
              onChanged: widget.onChanged,
              foregroundColor: foregroundColor.toColor(),
              vsync: this,
              hasFocus: _focused,
              focusColor: focusColor.toColor(),
              hovering: _hovering,
              additionalConstraints: additionalConstraints,
            );
          },
        ));
  }
}

class _ToggleSwitchRenderObjectWidget extends LeafRenderObjectWidget {
  const _ToggleSwitchRenderObjectWidget({
    Key? key,
    required this.value,
    required this.activeColor,
    required this.foregroundColor,
    required this.inactiveColor,
    required this.hoverColor,
    required this.onChanged,
    required this.vsync,
    required this.hasFocus,
    required this.hovering,
    required this.focusColor,
    required this.additionalConstraints,
  }) : super(key: key);

  final bool value;
  final bool hasFocus;
  final bool hovering;
  final Color activeColor;
  final Color foregroundColor;
  final Color inactiveColor;
  final Color hoverColor;
  final Color focusColor;
  final ValueChanged<bool?>? onChanged;
  final TickerProvider vsync;
  final BoxConstraints additionalConstraints;

  @override
  _RenderToggleSwitch createRenderObject(BuildContext context) =>
      _RenderToggleSwitch(
        value: value,
        hasFocus: hasFocus,
        activeColor: activeColor,
        foregroundColor: foregroundColor,
        inactiveColor: inactiveColor,
        hoverColor: hoverColor,
        onChanged: onChanged,
        vsync: vsync,
        additionalConstraints: additionalConstraints,
        focusColor: focusColor,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderToggleSwitch renderObject) {
    renderObject
      ..value = value
      ..activeColor = activeColor
      ..foregroundColor = foregroundColor
      ..inactiveColor = inactiveColor
      ..hoverColor = hoverColor
      ..onChanged = onChanged
      ..additionalConstraints = additionalConstraints
      ..vsync = vsync;
  }
}

class _RenderToggleSwitch extends RenderToggleable {
  _RenderToggleSwitch({
    bool? value,
    required Color activeColor,
    required this.foregroundColor,
    required Color inactiveColor,
    required Color focusColor,
    required Color hoverColor,
    ValueChanged<bool?>? onChanged,
    bool hasFocus = false,
    bool hovering = false,
    required TickerProvider vsync,
    required BoxConstraints additionalConstraints,
  }) : super(
          tristate: false,
          value: value,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          onChanged: onChanged,
          hasFocus: hasFocus,
          hovering: hovering,
          vsync: vsync,
          additionalConstraints: additionalConstraints,
        );

  Color foregroundColor;

  static const double _width = ToggleSwitch.width;
  static const double _height = ToggleSwitch.height;
  static const double _strokeWidth = ToggleSwitch.strokeWidth;
  static const Radius _radius = Radius.circular(ToggleSwitch.radius);

  @override
  set value(bool? newValue) {
    if (newValue == value) return;
    super.value = newValue;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isChecked = value == true;
  }

  RRect _rect(Offset origin) {
    final double width = _width;
    final double height = _height;
    final Rect rect = Rect.fromLTWH(origin.dx, origin.dy, width, height);
    return RRect.fromRectAndRadius(rect, _radius);
  }

  Color _colorAt(double t) {
    return onChanged == null
        ? inactiveColor
        : (t >= 0.25
            ? activeColor
            : Color.lerp(inactiveColor, activeColor, t * 4.0)!);
  }

  Paint _createStrokePaint() {
    return Paint()..color = foregroundColor;
  }

  void _drawTrack(Canvas canvas, Offset origin, double t, Paint paint) {
    assert(t >= 0.0 && t <= 1.0);
    // As t goes from 0.0 to 1.0, animate the horizontal line from the
    // mid point outwards.

    final double space = _strokeWidth;
    double radius = (_height - _strokeWidth * 2) / 2;

    final double dy = origin.dy + space + radius;

    final Offset initialOrigin = Offset(origin.dx + radius + space, dy);
    final Offset finalOrigin = Offset(origin.dx + _width - radius - space, dy);

    final Offset circleOrigin = Offset.lerp(initialOrigin, finalOrigin, t)!;

    canvas.drawCircle(circleOrigin, radius, paint);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final Paint strokePaint = _createStrokePaint();

    final Offset origin = (offset & size).topLeft;

    final AnimationStatus status = position.status;
    final double tNormalized =
        status == AnimationStatus.forward || status == AnimationStatus.completed
            ? position.value
            : 1.0 - position.value;

    final double t = value == false ? 1.0 - tNormalized : tNormalized;

    final RRect rect = _rect(origin);

    final Paint borderPaint = Paint()
      ..color = _colorAt(t)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    canvas.drawRRect(rect, borderPaint);

    _drawTrack(canvas, origin, t, strokePaint);
  }
}
