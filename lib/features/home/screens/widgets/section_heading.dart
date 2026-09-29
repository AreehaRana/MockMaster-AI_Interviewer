import 'package:flutter/material.dart';

class MSectionHeading extends StatelessWidget {
  final String title;

  const MSectionHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}
