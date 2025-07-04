import 'dart:io';
import 'package:dart_myoder_application/services/order_service.dart';
import 'package:dart_myoder_application/models/order.dart';

void main() async {
  final orderService = OrderService();
  
  // Initialize with sample data
  orderService.initializeWithSampleData();
  
  // Load existing orders
  await orderService.loadFromFile();
  
  while (true) {
    print('\n=== ORDER MANAGEMENT SYSTEM ===');
    print('1. Display all orders');
    print('2. Add new order');
    print('3. Search orders by item name');
    print('4. Exit');
    print('Enter your choice (1-4): ');
    
    final choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        orderService.displayOrders();
        break;
        
      case '2':
        await addNewOrder(orderService);
        break;
        
      case '3':
        await searchOrders(orderService);
        break;
        
      case '4':
        print('Goodbye!');
        return;
        
      default:
        print('Invalid choice. Please try again.');
    }
  }
}

Future<void> addNewOrder(OrderService orderService) async {
  print('\n--- Add New Order ---');
  
  print('Enter item code: ');
  final item = stdin.readLineSync() ?? '';
  
  print('Enter item name: ');
  final itemName = stdin.readLineSync() ?? '';
  
  print('Enter price: ');
  final priceStr = stdin.readLineSync() ?? '0';
  final price = double.tryParse(priceStr) ?? 0.0;
  
  print('Enter currency (USD, EUR, GBP, etc.): ');
  final currency = stdin.readLineSync() ?? 'USD';
  
  print('Enter quantity: ');
  final quantityStr = stdin.readLineSync() ?? '1';
  final quantity = int.tryParse(quantityStr) ?? 1;
  
  final order = Order(
    item: item,
    itemName: itemName,
    price: price,
    currency: currency,
    quantity: quantity,
  );
  
  await orderService.addOrder(order);
  print('Order added successfully!');
}

Future<void> searchOrders(OrderService orderService) async {
  print('\n--- Search Orders ---');
  print('Enter item name to search: ');
  final searchTerm = stdin.readLineSync() ?? '';
  
  final results = orderService.searchByItemName(searchTerm);
  
  if (results.isEmpty) {
    print('No orders found matching "$searchTerm"');
  } else {
    print('\nSearch Results:');
    for (int i = 0; i < results.length; i++) {
      final order = results[i];
      print('${i + 1}. ${order.item} - ${order.itemName} - \$${order.price} ${order.currency} (Qty: ${order.quantity})');
    }
  }
}
