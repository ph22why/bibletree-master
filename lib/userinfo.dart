import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class _User extends State {
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
  Widget build(BuildContext context) {}
}
