import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo'),
      ),
      body: const Center(
        child: Text('Form Modifica Profilo (Fase 3)'),
      ),
    );
  }
}
