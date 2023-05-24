import 'package:desktop/desktop.dart';

import '../defaults.dart';

class ButtonRadioPage extends StatefulWidget {
  const ButtonRadioPage({super.key});

  @override
  State<ButtonRadioPage> createState() => _ButtonRadioPageState();
}

class _ButtonRadioPageState extends State<ButtonRadioPage> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    const enabledCode = '''
return Container(
  width: 100.0,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Radio(
        value: value,
        onChanged: (fvalue) {
          setState(() {
            value = true;
          });
        },
      ),
      Radio(
        value: !value,
        onChanged: (fvalue) {
          setState(() {
            value = false;
          });
        },
      ),
    ],
  ),
);
''';

    const disabledCode = '''
return Container(
  width: 100.0,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Radio(
        value: true,
      ),
      Radio(
        value: false,
      ),
    ],
  ),
);
''';

    return Defaults(
      styleItems: Defaults.createStyle(RadioTheme.of(context).toString()),
      items: [
        ItemTitle(
          body: (context) => Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Radio(
                    value: _value,
                    onChanged: (fvalue) {
                      setState(() {
                        _value = true;
                      });
                    },
                  ),
                  Radio(
                    value: !_value,
                    onChanged: (fvalue) {
                      setState(() {
                        _value = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          codeText: enabledCode,
          title: 'Enabled',
        ),
        ItemTitle(
          body: (context) => Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Radio(
                    value: true,
                  ),
                  Radio(
                    value: false,
                  ),
                ],
              ),
            ),
          ),
          codeText: disabledCode,
          title: 'Disabled',
        ),
      ],
      header: 'Radio',
    );
  }
}
