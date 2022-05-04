import 'package:flutter/material.dart';

class searchFriend extends StatefulWidget {
  const searchFriend({Key? key}) : super(key: key);

  @override
  State<searchFriend> createState() => _searchFriendState();
}

class _searchFriendState extends State<searchFriend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              child: TextField(),
            )
          ],
        ),
      ),
    );
  }
}
