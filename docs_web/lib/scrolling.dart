import 'dart:async';

import 'package:desktop/desktop.dart';
import 'package:flutter/services.dart';
import 'defaults.dart';

final _kFileNames = [
  'pexels-akbar-nemati-5622738',
  'pexels-anete-lusina-4790622',
  'pexels-bianca-marolla-3030635',
  'pexels-christopher-schruff-720684',
  'pexels-danielle-daniel-479009',
  'pexels-david-savochka-192384',
  'pexels-dương-nhân-2817405',
  'pexels-emily-geibel-3772262',
  'pexels-emir-kaan-okutan-2255565',
  'pexels-engin-akyurt-1571724',
  'pexels-evg-culture-1416792',
  'pexels-faris-subriun-4391733',
  'pexels-flickr-156321',
  'pexels-fotografierende-3127729',
  'pexels-francesco-ungaro-96428',
  'pexels-halil-i̇brahim-çeti̇n-1754986',
  'pexels-hugo-zoccal-fernandes-laguna-1299518',
  'pexels-jan-kopřiva-5800065',
  'pexels-josé-andrés-pacheco-cortes-5456616',
  'pexels-leonardo-de-oliveira-1770918',
  'pexels-levent-simsek-4411430',
  'pexels-luan-oosthuizen-1784289',
  'pexels-mark-burnett-731553',
  'pexels-mati-mango-4734723',
  'pexels-matteo-petralli-1828875',
  'pexels-matthias-oben-5281143',
  'pexels-mustafa-ezz-979503',
  'pexels-peng-louis-1643457',
  'pexels-peng-louis-1653357',
  'pexels-piers-olphin-5044690',
  'pexels-pixabay-45170',
  'pexels-pixabay-45201',
  'pexels-pixabay-104827',
  'pexels-pixabay-160755',
  'pexels-pixabay-271611',
  'pexels-tamba-budiarsana-979247',
  'pexels-tomas-ryant-2693561',
  'pexels-utku-koylu-2611939',
  'pexels-xue-guangjian-1687831',
  'pexels-zhang-kaiyv-4858815',
  'pexels-александар-цветановић-1440406',
  'pexels-aleksandr-nadyojin-4492149',
];

class ScrollingPage extends StatefulWidget {
  ScrollingPage({Key? key}) : super(key: key);

  @override
  _ScrollingPageState createState() => _ScrollingPageState();
}

class _ScrollingPageState extends State<ScrollingPage> {
  final controller = ScrollController();

  String? _requestPrevious(String name) {
    final index = _kFileNames.lastIndexOf(name) - 1;

    if (index >= 0) {
      return _kFileNames[index];
    } else {
      return null;
    }
  }

  String? _requestNext(String name) {
    final index = _kFileNames.lastIndexOf(name) + 1;

    if (index > 0 && index < _kFileNames.length) {
      return _kFileNames[index];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Defaults.createHeader(context, 'Scrolling'),
        Expanded(
          child: Scrollbar(
            controller: controller,
            child: GridView.custom(
              controller: controller,
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              childrenDelegate:
                  SliverChildListDelegate.fixed(_kFileNames.map((assetName) {
                return GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _ImagePage(
                          assetName,
                          requestNext: _requestNext,
                          requestPrevious: _requestPrevious,
                        );
                      },
                    );
                  },
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Image.asset(
                      'assets/cats_small/$assetName.jpg',
                      frameBuilder: _frameBuilder,
                      fit: BoxFit.cover,
                    );
                  }),
                );
              }).toList()),
            ),
          ),
        ),
      ],
    );
  }
}

typedef RequestAssetNameCallback = String? Function(String);

class _ImagePage extends StatefulWidget {
  _ImagePage(
    this.assetName, {
    this.requestNext,
    this.requestPrevious,
    Key? key,
  }) : super(key: key);

  final String assetName;

  final RequestAssetNameCallback? requestNext;
  final RequestAssetNameCallback? requestPrevious;

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<_ImagePage> with TickerProviderStateMixin {
  Timer? _fadeoutTimer;
  bool firstBuild = true;
  bool offstage = false;
  bool menuFocus = false;

  void _startFadeoutTimer() {
    _fadeoutTimer?.cancel();

    setState(() {
      offstage = false;
      _fadeoutTimer = Timer(Duration(milliseconds: 1500), () {
        setState(() => _fadeoutTimer = null);
      });
    });
  }

  String? replaceAssetName;

  late Map<Type, Action<Intent>> _actionMap;
  late Map<LogicalKeySet, Intent> _shortcutMap;

  void _requestPrevious() {
    setState(() => replaceAssetName =
        widget.requestPrevious!(replaceAssetName ?? widget.assetName));
  }

  void _requestNext() {
    setState(() => replaceAssetName =
        widget.requestNext!(replaceAssetName ?? widget.assetName));
  }

  @override
  void initState() {
    super.initState();

    _actionMap = <Type, Action<Intent>>{
      ScrollIntent: CallbackAction<ScrollIntent>(onInvoke: (action) {
        switch (action.direction) {
          case AxisDirection.left:
            if (widget.requestPrevious != null) _requestPrevious();
            break;
          case AxisDirection.right:
            if (widget.requestNext != null) _requestNext();
            break;
          default:
        }
      }),
    };

    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
          const ScrollIntent(direction: AxisDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
          const ScrollIntent(direction: AxisDirection.right),
    };
  }

  @override
  void dispose() {
    _fadeoutTimer?.cancel();
    _fadeoutTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIXME Better way to do this?
    if (firstBuild) {
      _startFadeoutTimer();
      firstBuild = false;
    }

    final assetName = replaceAssetName ?? widget.assetName;

    final canRequestPrevious = widget.requestPrevious?.call(assetName) != null;
    final canRequestNext = widget.requestNext?.call(assetName) != null;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    Widget result = MouseRegion(
      onHover: (_) => _startFadeoutTimer(),
      child: Stack(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: constraints.maxHeight,
                color: Color(0x0),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/cats/$assetName.jpg',
                    frameBuilder: _frameBuilder,
                    fit: BoxFit.contain,
                    cacheHeight: constraints.maxHeight.toInt(),
                  ),
                ),
              ),
            );
          }),
          Offstage(
            offstage: offstage,
            child: AnimatedOpacity(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: colorScheme.background.withAlpha(0.9).toColor(),
                  height: 60.0,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => menuFocus = true),
                    onExit: (_) => setState(() => menuFocus = false),
                    child: ButtonTheme.merge(
                      data: ButtonThemeData(
                        color: textTheme.textLow,
                        hoverColor: textTheme.textMedium,
                        highlightColor: textTheme.textHigh,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(assetName),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      if (widget.requestPrevious != null)
                                        IconButton(
                                          Icons.navigate_before,
                                          onPressed: canRequestPrevious
                                              ? _requestPrevious
                                              : null,
                                          tooltip: 'Previous',
                                        ),
                                      if (widget.requestNext != null)
                                        IconButton(
                                          Icons.navigate_next,
                                          onPressed: canRequestNext
                                              ? _requestNext
                                              : null,
                                          tooltip: 'Next',
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  Icons.close,
                                  onPressed: () => Navigator.pop(context),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              opacity: _fadeoutTimer == null && !menuFocus ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: _fadeoutTimer == null && !menuFocus
                  ? Curves.easeOut
                  : Curves.easeIn,
              onEnd: () => setState(
                  () => offstage = _fadeoutTimer == null && !menuFocus),
              //curve: Curves.easeOutSine,
            ),
          ),
        ],
      ),
    );

    return FocusableActionDetector(
      child: result,
      autofocus: true,
      actions: _actionMap,
      shortcuts: _shortcutMap,
    );
  }
}

Widget _frameBuilder(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  return AnimatedOpacity(
    child: child,
    opacity: frame == null ? 0 : 1,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutSine,
  );
}
