import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderPage extends StatelessWidget {
  final String orderId; // Pass the Order ID to the page

  OrderPage({required this.orderId});

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchOrderDetails() async {
    // Fetch the order and related items
    final response = await supabase
        .from('orders')
        .select('*, order_items(*, products(name, price))')
        .eq('id', orderId)
        .single();

    if (response == null) {
      throw Exception('Order not found');
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoice')),
      body: FutureBuilder(
        future: fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data as Map<String, dynamic>;
          final items = order['order_items'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${order['id']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Status: ${order['status']}'),
                SizedBox(height: 20),
                Text('Items:', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = item['products'];
                      return ListTile(
                        title: Text(product['name']),
                        subtitle: Text(
                          '${item['quantity']} x \$${product['price'].toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          '\$${(item['quantity'] * product['price']).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: \$${order['total_amount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
