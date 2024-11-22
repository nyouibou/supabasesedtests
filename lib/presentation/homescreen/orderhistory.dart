import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryPage extends StatelessWidget {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in.');

    final response = await supabase
        .from('orders')
        .select('*, order_items(*, products(name, price))')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: FutureBuilder(
        future: _loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data as List<Map<String, dynamic>>;
          if (orders.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['order_items'] as List<dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order #${order['id']}'),
                  subtitle: Text(
                    'Total: \$${order['total_amount'].toStringAsFixed(2)}\n'
                    'Items: ${items.length}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
