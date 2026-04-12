import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:cristalyse/cristalyse.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ddSky,
      body: Column(
        children: [
          Text(
            "This is where we would keep the graphs...if we had any",
            style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
            textAlign: TextAlign.center
          ),
          ElevatedButton(
            child: const Text(
              "Logout"
            ), onPressed: () {},
          )
        ])
    );
  }
}