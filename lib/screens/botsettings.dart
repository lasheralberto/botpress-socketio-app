import 'package:flutter/material.dart';
import 'package:helloworld/models/constants.dart';
import 'package:helloworld/main.dart';
import 'package:helloworld/widgets/botbehavior.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BotSettingsScreen extends StatefulWidget {
  @override
  _BotSettingsScreenState createState() => _BotSettingsScreenState();
}

class _BotSettingsScreenState extends State<BotSettingsScreen> {
  bool? isLoading = true;
  bool? thereIsData = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return BotBehaviorCard();
              },
            )),
          ],
        ),
      ),
    );
  }
}
