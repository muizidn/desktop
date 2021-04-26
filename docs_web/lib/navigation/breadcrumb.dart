import 'package:desktop/desktop.dart';
import '../defaults.dart';

class BreadcrumbPage extends StatefulWidget {
  BreadcrumbPage({Key? key}) : super(key: key);

  @override
  _BreadcrumbPageState createState() => _BreadcrumbPageState();
}

class _BreadcrumbPageState extends State<BreadcrumbPage> {
  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: '''
Breadcrumb(
  initialRoute: 'page_0/',
  routeBuilder: (context, settings) {
    switch (settings.name) {
      case 'page_0/':
        return DesktopPageRoute(
          fullscreenDialog: false,
          builder: (context) => _MainPage(0),
          settings: RouteSettings(name: settings.name),
        );
      default:
        final count = settings.arguments as int;
        return DesktopPageRoute(
          fullscreenDialog: false,
          builder: (context) => _MainPage(count),
          settings: RouteSettings(name: settings.name),
        );
    }
  },
)
''');

    return Column(
      children: [
        Defaults.createHeader(context, 'Breadcrumb'),
        Expanded(
          child: Container(
            constraints: BoxConstraints.tightFor(height: 600.0),
            child: Tab(
              items: [
                TabItem.icon(
                  Icons.visibility,
                  builder: (context, _) => Container(
                    decoration: Defaults.itemDecoration(context),
                    child: Breadcrumb(
                      initialRoute: 'page_0/',
                      routeBuilder: (context, settings) {
                        switch (settings.name) {
                          case 'page_0/':
                            return DesktopPageRoute(
                              fullscreenDialog: false,
                              builder: (context) => _MainPage(0),
                              settings: RouteSettings(name: settings.name),
                            );
                          default:
                            final count = settings.arguments as int;
                            return DesktopPageRoute(
                              fullscreenDialog: false,
                              builder: (context) => _MainPage(count),
                              settings: RouteSettings(name: settings.name),
                            );
                        }
                      },
                    ),
                  ),
                ),
                TabItem.icon(
                  Icons.code,
                  builder: (context, _) => Container(
                    alignment: Alignment.topLeft,
                    //decoration: Defaults.itemDecoration(context),
                    child: TextField(
                      maxLines: 1000,
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      style: Theme.of(context).textTheme.monospace,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MainPage extends StatelessWidget {
  _MainPage(this.count);

  final count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Defaults.createSubheader(context, 'Page $count'),
        ),
        Expanded(
          child: Center(
            child: TextButton(
              'Next page',
              onPressed: () async => Navigator.pushNamed(
                context,
                'Page${count + 1}/',
                arguments: count + 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
