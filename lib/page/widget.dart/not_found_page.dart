import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("404"),
      ),
    );
  }
}
