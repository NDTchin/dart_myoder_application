import 'dart:convert';
import 'dart:io';
import '../models/order.dart';

class OrderService {
  static const String ordersFile = 'orders.json';
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  // Initialize with sample data from the provided string
  void initializeWithSampleData() {
    const String sampleData = '''[
      {"Item": "A1000","ItemName": "Iphone 15","Price": 1200,"Currency": "USD","Quantity":1},
      {"Item": "A1001","ItemName": "Iphone 16","Price": 1500,"Currency": "USD","Quantity":1}
    ]''';
    
    loadFromString(sampleData);
  }

  // Load orders from JSON string
  void loadFromString(String jsonString) {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      _orders = jsonData.map((item) => Order.fromJson(item)).toList();
      print('Loaded ${_orders.length} orders from string');
    } catch (e) {
      print('Error loading orders from string: $e');
    }
  }

  // Load orders from file
  Future<void> loadFromFile() async {
    try {
      final file = File(ordersFile);
      if (await file.exists()) {
        final String contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        _orders = jsonData.map((item) => Order.fromJson(item)).toList();
        print('Loaded ${_orders.length} orders from file');
      } else {
        print('Orders file does not exist, starting with empty list');
      }
    } catch (e) {
      print('Error loading orders from file: $e');
    }
  }

  // Save orders to file
  Future<void> saveToFile() async {
    try {
      final file = File(ordersFile);
      final String jsonString = json.encode(_orders.map((order) => order.toJson()).toList());
      await file.writeAsString(jsonString);
      print('Saved ${_orders.length} orders to file');
    } catch (e) {
      print('Error saving orders to file: $e');
    }
  }

  // Add a new order
  Future<void> addOrder(Order order) async {
    _orders.add(order);
    await saveToFile();
    print('Added order: ${order.itemName}');
  }

  // Search orders by item name (case-insensitive)
  List<Order> searchByItemName(String itemName) {
    if (itemName.isEmpty) return _orders;
    
    return _orders.where((order) => 
      order.itemName.toLowerCase().contains(itemName.toLowerCase())
    ).toList();
  }

  // Display all orders
  void displayOrders() {
    if (_orders.isEmpty) {
      print('No orders found.');
      return;
    }

    print('\n=== ORDER LIST ===');
    for (int i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      print('${i + 1}. ${order.item} - ${order.itemName} - \$${order.price} ${order.currency} (Qty: ${order.quantity})');
    }
    print('==================\n');
  }

  // Get orders as JSON string for API
  String getOrdersAsJson() {
    return json.encode(_orders.map((order) => order.toJson()).toList());
  }

  // Delete order by index
  Future<void> deleteOrder(int index) async {
    if (index >= 0 && index < _orders.length) {
      final removedOrder = _orders.removeAt(index);
      await saveToFile();
      print('Removed order: ${removedOrder.itemName}');
    }
  }
}
