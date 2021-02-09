import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'dart:math' as math;

import 'theme.dart';
import 'internal/toggleable.dart';

class Radio extends StatefulWidget {
  const Radio({
    Key? key,
    required this.value,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  final bool value;

  final ValueChanged<bool?>? onChanged;

  final FocusNode? focusNode;

  final bool autofocus;

  static const double strokeWidth = 2.0;
  static const double outerRadius = 8.0;
  static const double innerRadius = outerRadius - (strokeWidth * 2.0);

  @override
  _RadioState createState() => _RadioState();
}

class _RadioState extends State<Radio> with TickerProviderStateMixin {
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
      switch (widget.value) {
        case false:
          widget.onChanged!(true); // FIXME
          break;
        case true:
          widget.onChanged!(false); // FIXME
          break;
        default: // case null:
          widget.onChanged!(false); // FIXME
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
    //Size size = const Size();

    //final BoxConstraints constraints = BoxConstraints.tight(size);

    final background = colorScheme.background;

    final effectiveHoverColor = colorScheme.primary1;
    final effectiveActiveColor = colorScheme.primary2;

    final foregroundColor = enabled
        ? textTheme.foreground(background)
        : textTheme.disabledForeground(background);

    final Size size = Size.square(Radio.outerRadius * 2.0);

    final BoxConstraints additionalConstraints = BoxConstraints.tight(size);

    return FocusableActionDetector(
      // actions: _actionMap,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: enabled,
      onShowHoverHighlight: _handleHoverChanged,
      onShowFocusHighlight: _handleFocusHighlightChanged,
      child: Builder(
        builder: (BuildContext context) {
          return _RadioRenderObjectWidget(
            value: widget.value,
            activeColor: effectiveActiveColor.toColor(),
            inactiveColor: enabled
                ? colorScheme.overlay5.toColor()
                : colorScheme.overlay3.toColor(),
            hoverColor: effectiveHoverColor.toColor(),
            onChanged: widget.onChanged,
            foregroundColor: foregroundColor.toColor(),
            focusColor: foregroundColor.toColor(), // FIXME
            vsync: this,
            hasFocus: _focused,
            hovering: _hovering,
            additionalConstraints: additionalConstraints,
          );
        },
      ),
    );
  }
}

class _RadioRenderObjectWidget extends LeafRenderObjectWidget {
  const _RadioRenderObjectWidget({
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
  _RenderRadio createRenderObject(BuildContext context) => _RenderRadio(
        value: value,
        hasFocus: hasFocus,
        activeColor: activeColor,
        foregroundColor: foregroundColor,
        inactiveColor: inactiveColor,
        hoverColor: hoverColor,
        onChanged: onChanged,
        hovering: hovering,
        focusColor: focusColor,
        vsync: vsync,
        additionalConstraints: additionalConstraints,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderRadio renderObject) {
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

class _RenderRadio extends RenderToggleable {
  _RenderRadio({
    bool? value,
    required Color activeColor,
    required this.foregroundColor,
    required Color inactiveColor,
    required Color focusColor,
    required Color hoverColor,
    required ValueChanged<bool?>? onChanged,
    required bool hasFocus,
    required bool hovering,
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

  static const double _strokeWidth = Radio.strokeWidth;
  static const double _outerRadius = Radio.outerRadius;
  static const double _innerRadius = Radio.innerRadius;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isChecked = value == true;
  }

  Color _colorAt(double t) {
    return onChanged == null
        ? inactiveColor
        : (t >= 0.25
            ? activeColor
            : Color.lerp(inactiveColor, activeColor, t * 4.0)!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final Offset center = (offset & size).center;

    final Paint borderPaint = Paint()
      ..color = _colorAt(position.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final Paint strokePaint = Paint()..color = foregroundColor;

    canvas.drawCircle(center, _outerRadius, borderPaint);

    if (!position.isDismissed) {
      canvas.drawCircle(center, _innerRadius, strokePaint);
    }
  }
}
