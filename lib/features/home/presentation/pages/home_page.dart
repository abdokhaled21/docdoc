import 'package:flutter/material.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/routes/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LocalStorage.instance.clearToken();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
          )
        ],
      ),
      body: const Center(child: Text('Welcome to Docdoc!')),
    );
  }
}
