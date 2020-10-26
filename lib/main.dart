import 'dart:math' as math;

import 'package:flutter/material.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  Widget page0;
  final page0Key = GlobalKey<BarPageState>();

  Widget page1;
  final page1Key = GlobalKey<BarPageState>();

  Widget page2;
  final page2Key = GlobalKey<BarPageState>();

  Widget menu;
  final menuKey = GlobalKey<BarPageState>();

  var pages = <BarPage>[];

  @override
  void initState() {
    super.initState();
    page0 = BarPage(
      key: page0Key,
      color: Colors.green,
      initialText: "TAB 0",
    );
    page1 = BarPage(
      key: page1Key,
      color: Colors.purple[200],
      initialText: "TAB 1",
    );
    page2 = BarPage(
      key: page2Key,
      color: Colors.blue,
      initialText: "TAB 2",
    );

    menu = BarPage(
      key: menuKey,
      color: Colors.cyanAccent,
      initialText: "MENU",
    );

    pages.addAll([page0, page1, page2, menu]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final menu = menuKey.currentState;
        final tab2 = page2Key.currentState;
        final tab1 = page1Key.currentState;
        final tab0 = page0Key.currentState;

        // handle menu
        if (_currentIndex == 3 && menu.canPop()) {
          menuKey.currentState.popPage();
          return false;
        }
        // handle tab 2
        else if (_currentIndex == 2 && tab2.canPop()) {
          tab2.popPage();
          return false;
        }
        // handle tab 1
        else if (_currentIndex == 1 && tab1.canPop()) {
          tab1.popPage();
          return false;
        }
        // handle tab 0
        else if (_currentIndex == 0 && tab0.canPop()) {
          tab0.popPage();
          return false;
        }
        // reset to first tab before actually close the app
        // (same behaviour of Gmail/LinkedIn...)
        else if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        // close app only if it is on tab 0 and
        else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = 3); // open MENU
                },
                child: Icon(Icons.menu),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          // select colors to both Selected/Unselected items
          // this way items will have the right color when menu is opened
          unselectedItemColor: Colors.black54,
          selectedItemColor: _currentIndex < 3 ? Colors.blue : Colors.black54,
          currentIndex: _currentIndex < 3 ? _currentIndex : 0,
          onTap: (int index) {
            if (index == _currentIndex) return;
            setState(() {
              // Pop all menu pages when exiting it
              if (_currentIndex == 3) menuKey.currentState.popAll();

              // select the new tab
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
  var internalPages = <MaterialPage>[];

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
    return Navigator(
      onPopPage: (route, response) {
        return true;
      },
      pages: [
        _buildRoot(context),
        for (var page in internalPages) page,
      ],
    );
  }

  MaterialPage _buildRoot(BuildContext context) {
    return MaterialPage(builder: (_) {
      return Container(
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
            ),
            ElevatedButton(
              child: Text("Push page Full screen"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return Center(child: Text("FULL SCREEN"));
                }));
              },
            )
          ],
        ),
      );
    });
  }

  Container _buildInternalPage() {
    final colors = [
      Colors.orange,
      Colors.pink,
      Colors.red,
      Colors.yellow,
      Colors.yellow[100],
      Colors.white70,
      Colors.cyanAccent,
      Colors.cyanAccent[100],
      Colors.black12,
      Colors.blueGrey,
    ];
    final randomIndex = math.Random().nextInt(colors.length - 1);
    return Container(
      color: colors[randomIndex],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text("Push another internally"),
            onPressed: () => _addPage(_buildInternalPage()),
          ),
          ElevatedButton(
            child: Text("POP"),
            onPressed: () {
              setState(() {
                internalPages.removeLast();
              });
            },
          ),
        ],
      ),
    );
  }

  void _addPage(Widget page) {
    setState(() {
      internalPages.add(
        MaterialPage(builder: (ctxBellowNav) {
          return page;
        }),
      );
    });
  }

  bool canPop() => internalPages.length > 0;

  void popPage() {
    setState(() {
      internalPages.removeLast();
    });
  }

  void popAll() {
    while (canPop()) {
      popPage();
    }
  }
}
