import 'package:desktop/desktop.dart';
import 'package:dart_style/dart_style.dart';
import 'dart:math' as math;

class CodeTextController extends TextEditingController {
  CodeTextController({super.text});

  static final _regex = RegExp(
    r'''(?<class>\b[_$]*[A-Z][a-zA-Z0-9_$]*\b|bool\b|num\b|int\b|double\b|dynamic\b|(void)\b)|(?<string>(?:'.*?'))|(?<keyword>\b(?:try|on|catch|finally|throw|rethrow|break|case|continue|default|do|else|for|if|in|return|switch|while|abstract|class|enum|extends|extension|external|factory|implements|get|mixin|native|operator|set|typedef|with|covariant|static|final|const|required|late|void|var|library|import|part of|part|export|await|yield|async|sync|true|false)\b)|(?<comment>(?:(?:\/.*?)$))|(?<numeric>\b(?:(?:0(?:x|X)[0-9a-fA-F]*)|(?:(?:[0-9]+\.?[0-9]*)|(?:\.[0-9]+))(?:(?:e|E)(?:\+|-)?[0-9]+)?)\b)''',
    multiLine: true,
    dotAll: true,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final themeData = Theme.of(context);
    final brightness = themeData.brightness;
    final textStyle = themeData.textTheme.monospace;

    final Color classColor;
    final Color commentsColor;
    final Color stringColor;
    final Color keywordColor;
    final Color numericColor;

    if (brightness == Brightness.dark) {
      classColor = const Color(0xff5ecda8);
      commentsColor = const Color(0xff696969);
      stringColor = const Color(0xffdc8c6a);
      keywordColor = const Color(0xff60b5f6);
      numericColor = const Color(0xffc2dcb5);
    } else {
      classColor = const Color(0xff418D73);
      commentsColor = const Color(0xff969696);
      stringColor = const Color(0xffB37256);
      keywordColor = const Color(0xff4684B3);
      numericColor = const Color(0xff92A688);
    }

    final textColor = Theme.of(context).textTheme.textHigh;

    final matches = _regex.allMatches(text);

    final spans = <TextSpan>[];

    int lastEnd = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      spans.add(TextSpan(text: text.substring(lastEnd, start)));

      if (match.namedGroup('class') != null) {
        spans.add(TextSpan(
            text: text.substring(start, end),
            style: textStyle.copyWith(color: classColor)));
      } else if (match.namedGroup('keyword') != null) {
        spans.add(TextSpan(
            text: text.substring(start, end),
            style: textStyle.copyWith(color: keywordColor)));
      } else if (match.namedGroup('string') != null) {
        spans.add(TextSpan(
            text: text.substring(start, end),
            style: textStyle.copyWith(color: stringColor)));
      } else if (match.namedGroup('comment') != null) {
        spans.add(TextSpan(
            text: text.substring(start, end),
            style: textStyle.copyWith(color: commentsColor)));
      } else if (match.namedGroup('numeric') != null) {
        spans.add(TextSpan(
            text: text.substring(start, end),
            style: textStyle.copyWith(color: numericColor)));
      } else {
        spans.add(TextSpan(text: text.substring(start, end)));
      }

      lastEnd = end;
    }

    spans.add(TextSpan(text: text.substring(lastEnd)));

    return TextSpan(
      style: textStyle.copyWith(color: textColor),
      children: spans,
    );
  }
}

class Defaults extends StatefulWidget {
  const Defaults({
    super.key,
    required this.items,
    required this.header,
  });

  final List<ItemTitle> items;
  final String header;

  static BoxDecoration itemDecoration(BuildContext context) => BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.shade[30],
            width: 1.0,
          ),
        ),
      );

  static Widget createHeader(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: Theme.of(context).textTheme.header,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Widget createSubheader(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
      child: Text(
        name,
        style: Theme.of(context).textTheme.subheader,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Widget createTitle(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 8.0),
      child: Text(
        name,
        style: Theme.of(context).textTheme.title,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Widget createSubtitle(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 4.0),
      child: Text(
        name,
        style: Theme.of(context).textTheme.subtitle,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  static Widget createCaption(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 4.0),
      child: Text(
        name,
        style: Theme.of(context).textTheme.caption,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  _DefaultsState createState() => _DefaultsState();
}

class _DefaultsState extends State<Defaults> {
  int _index = 0;

  final List<bool> _shouldBuildView = <bool>[];

  String get _codeFormatted => DartFormatter().format('''
import 'package:desktop/desktop.dart';

void main() => runApp(DesktopApp(home: App()));

class App extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    ${widget.items[_index].codeText}
  }
} 
''');

  @override
  void initState() {
    super.initState();
    _shouldBuildView.addAll(List<bool>.filled(widget.items.length, false));
  }

  @override
  void didUpdateWidget(Defaults oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length - _shouldBuildView.length > 0) {
      _shouldBuildView.addAll(List<bool>.filled(
          widget.items.length - _shouldBuildView.length, false));
    } else if (widget.items.length - _shouldBuildView.length < 0) {
      _shouldBuildView.removeRange(
          widget.items.length, _shouldBuildView.length);
    }

    _index = math.min(_index, widget.items.length - 1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = List<Widget>.generate(widget.items.length, (index) {
      final bool active = index == _index;
      _shouldBuildView[index] = active || _shouldBuildView[index];

      return Offstage(
        offstage: !active,
        child: TickerMode(
          enabled: active,
          child: Builder(
            builder: (context) {
              return _shouldBuildView[index]
                  ? widget.items[index].body(context)
                  : Container();
            },
          ),
        ),
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Defaults.createHeader(context, widget.header),
                Defaults.createTitle(context, widget.items[_index].title),
              ],
            )),
        Expanded(
          child: Tab(
            trailing: (context) {
              return Row(
                children: [
                  ...List.generate(
                    widget.items[_index].options?.length ?? 0,
                    (index) => widget.items[_index].options![index],
                  ),
                  if (widget.items.length > 1)
                    ContextMenuButton<int>(
                      const Icon(Icons.menu),
                      tooltip: 'Variations',
                      value: _index,
                      onSelected: (value) => setState(() => _index = value),
                      itemBuilder: (context) => List.generate(
                        widget.items.length,
                        (index) => ContextMenuItem(
                          value: index,
                          child: Text(widget.items[index].title),
                        ),
                      ),
                    )
                ],
              );
            },
            items: [
              TabItem(
                itemBuilder: (context, _) => const Icon(Icons.visibility),
                builder: (context, _) => Column(
                  children: [
                    Container(
                      decoration: Defaults.itemDecoration(context),
                    ),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: list,
                      ),
                    ),
                  ],
                ),
              ),
              TabItem(
                itemBuilder: (context, _) => const Icon(Icons.code),
                builder: (context, _) => Container(
                  decoration: Defaults.itemDecoration(context),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SelectableText.rich(
                    CodeTextController(text: _codeFormatted)
                        .buildTextSpan(context: context, withComposing: false),
                    style: Theme.of(context).textTheme.monospace,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ItemTitle {
  ItemTitle({
    required this.body,
    this.codeText,
    this.options,
    required this.title,
  });
  final String title;
  final WidgetBuilder body;
  final String? codeText;
  final List<Widget>? options;
}
