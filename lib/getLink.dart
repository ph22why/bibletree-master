import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RootWidget extends StatefulWidget {
  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  int Gold;
  String ID;
  int tree;
  int water;

  CollectionReference nonFamily =
      FirebaseFirestore.instance.collection('Non-Family');

  CollectionReference Family = FirebaseFirestore.instance.collection('Family');

  void _initializeNonFamily() {
    nonFamily.doc('pheemily').get().then((DocumentSnapshot snapshot) {
      setState(() {
        Gold = snapshot.data()['Gold'];
        ID = snapshot.data()['ID'];
        tree = snapshot.data()['tree'];
        water = snapshot.data()['water'];
      });
    });
  }

  void _initializeFamily() {}

  void _groupFamily() {}

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      print(deepLink);
      print(deepLink.path);

      if (deepLink != null) {
        // do something
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    print(deepLink);

    if (deepLink != null) {
      _groupFamily();
    }
  }

  @override
  Widget build(BuildContext context) {}
}
