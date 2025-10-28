import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EV Ride App',
      // Add global themes, routes here later
      home: Scaffold(body: Center(child: Text('App Root'))),
    );
  }
}