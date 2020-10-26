import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class InternalPagesModel extends ChangeNotifier {
  var pages = <MaterialPage>[];

  void push(Widget widget) {
    pages.add(
      MaterialPage(builder: (_) {
        return widget;
      }),
    );
    notifyListeners();
  }

  void pop() {
    pages.removeLast();
    notifyListeners();
  }

  int get length => pages.length;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (context) => InternalPagesModel(),
        child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final innerNave = GlobalKey<NavigatorState>();

  Widget barPage0;
  Widget barPage1;
  Widget barPage2;
  var barPages = <Widget>[];

  // var internalPages = <MaterialPage>[];

  @override
  void initState() {
    super.initState();
    barPage0 = BarPage(
      key: UniqueKey(),
      color: Colors.green,
      initialText: "TAB 0",
    );
    barPage1 = BarPage(
      key: UniqueKey(),
      color: Colors.purple[200],
      initialText: "TAB 1",
    );
    barPage2 = BarPage(
      key: UniqueKey(),
      color: Colors.blue,
      initialText: "TAB 2",
    );

    barPages.addAll([barPage0, barPage1, barPage2]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("OUT");
        final internalPagesModel =
            Provider.of<InternalPagesModel>(context, listen: false);

        if (internalPagesModel.pages.length > 0) {
          internalPagesModel.pop();
          return false;
        }
        // if (innerNave.currentState.canPop()) {
        //   if (pages.length > 1) {
        //     setState(() {
        //       pages.removeLast();
        //       print("OUTTT: ${pages.length}");
        //       _currentIndex = pages.length - 1;
        //     });
        //   }
        //   return false;
        // }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Consumer<InternalPagesModel>(
            builder: (context, internalPagesModel, child) {
              return Navigator(
                onPopPage: (_, __) => false,
                pages: [
                  MaterialPage(builder: (_) => child),
                  for (var page in internalPagesModel.pages) page,
                ],
              );
            },
            child: IndexedStack(
              index: _currentIndex,
              children: barPages,
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            if (index == _currentIndex) return;
            setState(() {
              print("IN: $index");
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.hot_tub), label: "Tub"),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
          ],
        ),
      ),
    );
  }
}

class BarPage extends StatefulWidget {
  final Color color;
  final String initialText;

  BarPage({Key key, this.color, this.initialText}) : super(key: key);

  @override
  BarPageState createState() => BarPageState();
}

class BarPageState extends State<BarPage> {
  TextEditingController _textController;
  // var internalPages = <MaterialPage>[];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialText,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final internalPages =
            Provider.of<InternalPagesModel>(context, listen: false);
        if (internalPages.length > 0) {
          setState(() {
            internalPages.pop();
          });
          return false;
        }
        return true;
      },
      child: Container(
        color: widget.color,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _textController),
            ElevatedButton(
              child: Text("Push page internally"),
              onPressed: () {
                _addPage(_buildInternalPage());
              },
            )
          ],
        ),
      ),
    );
  }

  Container _buildInternalPage() {
    final colors = [Colors.orange, Colors.pink, Colors.red, Colors.yellow];
    final randomIndex = math.Random().nextInt(colors.length - 1);
    return Container(
      color: colors[randomIndex],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text("Push another internally"),
            onPressed: () {
              _addPage(_buildInternalPage());
            },
          ),
          ElevatedButton(
            child: Text("POP"),
            onPressed: () {
              setState(() {
                final internalPages =
                    Provider.of<InternalPagesModel>(context, listen: false);
                internalPages.pop();
              });
            },
          ),
        ],
      ),
    );
  }

  void _addPage(Widget page) {
    setState(() {
      final internalPages =
          Provider.of<InternalPagesModel>(context, listen: false);
      internalPages.push(page);
    });
  }
}
