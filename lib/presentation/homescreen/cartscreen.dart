import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'orderhistory.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in.');

      final response = await supabase
          .from('cart')
          .select('*, products(name, price, image_url)')
          .eq('user_id', user.id);

      setState(() {
        _cartItems = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromCart(String cartId) async {
    try {
      await supabase.from('cart').delete().eq('id', cartId);
      await _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  Future<void> _placeOrder() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in.');

      if (_cartItems.isEmpty) throw Exception('Cart is empty.');

      // Calculate total
      final totalAmount = _cartItems.fold(0.0, (sum, item) {
        return sum + (item['quantity'] * item['products']['price']);
      });

      // Insert into orders
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'total_amount': totalAmount,
        'status': 'pending',
      }).select('id').single();

      final orderId = orderResponse['id'];

      // Insert into order_items
      for (var item in _cartItems) {
        await supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
        });
      }

      // Clear the cart
      await supabase.from('cart').delete().eq('user_id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );

      await _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(child: Text('Your cart is empty!'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return ListTile(
                            leading: Image.network(item['products']['image_url']),
                            title: Text(item['products']['name']),
                            subtitle: Text(
                              '${item['quantity']} x \$${item['products']['price'].toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeFromCart(item['id']),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    ElevatedButton(
                      onPressed: _placeOrder,
                      child: Text('Place Order'),
                    ),
                  ],
                ),floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => OrderHistoryPage()),
);

      },),
    );
  }
}
