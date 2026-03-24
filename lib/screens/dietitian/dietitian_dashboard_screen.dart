import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dietitian_provider.dart';

class DietitianDashboardScreen extends StatelessWidget {
  const DietitianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dietitian = Provider.of<DietitianProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Diyetisyen - ${auth.currentUser?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Toplam Danışan'),
                subtitle: Text('${dietitian.totalPatients}'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Bugün Aktif Danışan'),
                subtitle: Text('${dietitian.activeToday}'),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                title: Text('Otomatik Mesajlar (Demo)'),
                subtitle: Text(
                  'İleride burada: sabah hatırlatma, mesai dışı oto yanıt, '
                  '2 gün giriş yapmayanlara mesaj gibi kurallar yönetilecek.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
