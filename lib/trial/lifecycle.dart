// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyAudioPlayer2 extends StatefulWidget {
  final String music;
  MyAudioPlayer2({Key key, this.music}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<MyAudioPlayer2> {
  int counter;

  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    print("init state");
    counter = 1;
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  void increase() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("-----build");
    return Center(
      child: Column(
        children: <Widget>[
          Text(widget.music),
          Text(counter.toString()),
          IconButton(icon: Icon(Icons.add), onPressed: increase)
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(MyAudioPlayer2 oldWidget) {
    print("-------didUpdateWidget");
    super.didUpdateWidget(oldWidget);
    setState(() {
      counter++;
    });

  }
}
