import 'dart:ui';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share/share.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() async {
  //Firebase를 사용하기 위해서는 다음 두 줄을 꼭 입력해야 함.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '영적 나무',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Tree(),
    );
  }
}

class Tree extends StatefulWidget {
  @override
  _TreeState createState() => _TreeState();
}

Timer _timerLink;

class _TreeState extends State<Tree> with WidgetsBindingObserver {
  // TextEditingController _editingController = TextEditingController();

  CollectionReference counter = FirebaseFirestore.instance
      .collection('counter'); // Firestore 'conuter' 컬렉션에 연결
  int _counter = 0;
  int _bottlecounter = 0;
  String _imagePath = './images/grass.jpg';

  //_counter 변수의 값을 1 증가, Firestore의 값도 동일하게 1 증가
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    counter
        .doc('counter')
        .update({'counter': _counter})
        .then((value) => null)
        .catchError((error) => print('Error'));
  }

  //Firestore에 있는 counter와 bottle 값을 불러옴
  void _initializeCounter() {
    counter.doc('counter').get().then((DocumentSnapshot snapshot) {
      setState(() {
        _counter = snapshot.data()['counter'];
        _bottlecounter = snapshot.data()['bottle'];
      });
    }).catchError(
        (error) => print('Failed to initialize counter value : $error'));
  }

  //_bottlecounter 변수의 값을 1 증가, Firestore의 값도 동일하게 1 증가
  void _decrementBottleCounter() {
    setState(() {
      _bottlecounter--;
    });
    counter
        .doc('counter')
        .update({'bottle': _bottlecounter})
        .then((value) => null)
        .catchError((error) => print('Error'));
  }

  _createAndShare() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://bibletr22.page.link/Eit5',
      link: Uri.parse('https://bibletr22.com/welcome'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.bible_tree',
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'com.example.bootcamp_deeplinking',
      // ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Example of a Dynamic Link',
        description: 'This link works whether app is installed or not!',
      ),
    );
    final Uri dynamicUrl = await parameters.buildUrl();

    // final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    // final Uri shortUrl = shortDynamicLink.shortUrl;
    // print(shortUrl);
    Share.share('Here is my deeplink $dynamicUrl');
    // Share.share('https://bibletr22.page.link/Eit5');
  }

  Future<void> _retrieveDynamicLink() async {
    FirebaseDynamicLinks.instance.onLink(onSuccess: (data) async {
      final Uri deepLink = data?.link;

      print("DeepLink is: ${data?.link}");
      if (deepLink != null) {
        deepLink.toString();
        print(deepLink.toString());
        String params = "";
        deepLink.queryParameters.forEach((k, v) {
          params += "$k : $v \n";
        });
        // Here we need to perform operations and navigation based on data we received
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text("Data you sent"),
                children: <Widget>[
                  Center(
                    child: Text(
                      params,
                    ),
                  )
                ],
              );
            });
      }
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      _timerLink =
          Timer(Duration(milliseconds: 500), () => _retrieveDynamicLink());
    }
  }

  @override
  void dispose() {
    _timerLink.cancel();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // TODO: implement initState
    super.initState();
    _initializeCounter();
  }

  @override
  Widget build(BuildContext context) {
    _initializeCounter(); //Firestore에 있는 bottle과 counter의 값이 변경될 때마다 어플에 실시간 적용 되는 거 같음
    return Scaffold(
      appBar: AppBar(
        title: Text("영적 나무"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_imagePath),
            SizedBox(
              height: 10,
            ),
            Text("물주기"),
            SizedBox(
              height: 20,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (BuildContext context) {
                    return FloatingActionButton(
                      tooltip: 'I have $_bottlecounter\'s bottle!',
                      onPressed: () {
                        if (_bottlecounter > 0) {
                          _incrementCounter();
                          _decrementBottleCounter();
                          setState(() {
                            if (_counter < 6) {
                              _imagePath = 'images/grass.jpg';
                            } else if (6 <= _counter && _counter < 11) {
                              _imagePath = 'images/plant.jpg';
                            } else {
                              _imagePath = 'images/tree.jpg';
                            }
                          });
                          _bottlecounter--;
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'No bottle!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.teal,
                            duration: Duration(seconds: 1),
                          ));
                        }
                      },
                      child: Image.asset('images/waterbottle.png'),
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RaisedButton(
                  child: Text("Create DeepLink and Share"),
                  onPressed: () {
                    _createAndShare();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
