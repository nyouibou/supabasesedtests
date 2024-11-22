import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../detailedproductscreen.dart';
import 'profilescreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchProducts() async {
    final response = await _supabase.from('products').select();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: FutureBuilder(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching products'));
          }

          final products = snapshot.data as List<dynamic>;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product['image_url']),
                title: Text(product['name']),
                subtitle: Text('\$${product['price']}'),
                onTap: () {
                  // Navigate to Product Details
                   // Navigate to Product Details Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedProductPage(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ProfilePage()),
);

      },),
    );
  }
}
