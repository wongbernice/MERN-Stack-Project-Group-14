import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("This is where I would keep the graphs...if I had any")
    );
  }
}