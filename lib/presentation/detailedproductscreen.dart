

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'orderscreen.dart'; // Import the OrderPage

// class DetailedProductPage extends StatelessWidget {
//   final dynamic product;

//   DetailedProductPage({required this.product});

//   final supabase = Supabase.instance.client;

//   // This function simulates adding an item to the cart and generating an order ID.
//   // Future<String> addToCartAndCreateOrder() async {
//   //   final userId = 'user_id'; // Replace with actual user ID from your app's auth system
//   //   final response = await supabase
//   //       .from('orders')
//   //       .insert([
//   //         {
//   //           'user_id': userId,
//   //           'status': 'pending',
//   //           'total_amount': product['price'],
//   //           'created_at': DateTime.now().toIso8601String(),
//   //         }
//   //       ])
//   //       .select('id')
//   //       .single();

//   //   if (response != null) {
//   //     final orderId = response['id'];
//   //     // Add the product to the order items table (cart items)
//   //     await supabase.from('order_items').insert([
//   //       {
//   //         'order_id': orderId,
//   //         'product_id': product['id'],
//   //         'quantity': 1, // Set the default quantity as 1
//   //       }
//   //     ]);
//   //     return orderId;
//   //   } else {
//   //     throw Exception('Failed to create order');
//   //   }
//   // }

//   Future<String> addToCartAndCreateOrder() async {
//   final user = Supabase.instance.client.auth.currentUser;

//   if (user == null) {
//     throw Exception('No user is logged in');
//   }

//   final userId = user.id; // Get the user ID from Supabase Auth

//   // Check if the user exists in the 'profiles' table
//   final profileResponse = await supabase
//       .from('profiles')
//       .select('id')
//       .eq('id', userId)
//       .maybeSingle(); // Use maybeSingle instead of single

//   if (profileResponse == null) {
//     // If the profile doesn't exist, create a new profile entry
//     await supabase.from('profiles').insert([
//       {
//         'id': userId,
//         'email': user.email,
//         'created_at': DateTime.now().toIso8601String(),
//       }
//     ]);
//   }

//   // Now that we are sure the user profile exists, insert the order
//   final response = await supabase
//       .from('orders')
//       .insert([
//         {
//           'user_id': userId, // Insert the user ID into the orders table
//           'status': 'pending',
//           'total_amount': product['price'],
//           'created_at': DateTime.now().toIso8601String(),
//         }
//       ])
//       .select('id')
//       .single();

//   if (response != null) {
//     final orderId = response['id'];

//     // Add the product to the order items table (cart items)
//     await supabase.from('order_items').insert([
//       {
//         'order_id': orderId,
//         'product_id': product['id'],
//         'quantity': 1, // Set the default quantity as 1
//       }
//     ]);
//     return orderId;
//   } else {
//     throw Exception('Failed to create order');
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(product['name']),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Image
//             Center(
//               child: Image.network(
//                 product['image_url'],
//                 width: 250,
//                 height: 250,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SizedBox(height: 16),
//             // Product Name
//             Text(
//               product['name'],
              
//             ),
//             SizedBox(height: 8),
//             // Product Price
//             Text(
//               '\$${product['price']}',
              
//             ),
//             SizedBox(height: 16),
//             // Product Description
//             Text(
//               product['description'] ?? 'No description available.',
             
//             ),
//             SizedBox(height: 16),
//             // Add to Cart Button
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   // Create an order and navigate to the OrderPage
//                   final orderId = await addToCartAndCreateOrder();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => OrderPage(orderId: orderId),
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error adding to cart: $e')),
//                   );
//                 }
//               },
//               child: Text('Add to Cart'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'homescreen/cartscreen.dart';

class DetailedProductPage extends StatelessWidget {
  final dynamic product;

  DetailedProductPage({required this.product});

  final supabase = Supabase.instance.client;

  /// Adds the product to the cart and creates an order.
  Future<void> addToCart() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No user is logged in.');
    }

    final userId = user.id;

    // Ensure the user's profile exists
    final profileResponse = await supabase
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (profileResponse == null) {
      // Create a profile for the user if it doesn't exist
      await supabase.from('profiles').insert({
        'id': userId,
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Add product to the cart
    await supabase.from('cart').upsert({
      'user_id': userId,
      'product_id': product['id'],
      'quantity': 1, // Default quantity
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the Cart Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Image.network(
                product['image_url'],
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            // Product Name
            Text(
              product['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Product Price
            Text(
              '\$${product['price'].toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 16),

            // Product Description
            Text(
              product['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Add to Cart Button
            ElevatedButton(
              onPressed: () async {
                try {
                  await addToCart();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to cart!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding to cart: $e')),
                  );
                }
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
