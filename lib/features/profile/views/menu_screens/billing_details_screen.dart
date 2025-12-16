import 'package:flutter/material.dart';

class BillingDetailsScreen extends StatelessWidget {
  const BillingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing Details'), centerTitle: true),
      body: const Center(child: Text('Billing Details Screen Content')),
    );
  }
}
