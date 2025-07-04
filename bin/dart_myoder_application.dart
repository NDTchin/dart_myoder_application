import 'dart:io';
import 'package:dart_myoder_application/services/order_service.dart';
import 'package:dart_myoder_application/web/web_server.dart';

void main(List<String> arguments) async {
  print('=== My Order Application ===');
  
  // Create order service
  final orderService = OrderService();
  
  // Initialize with sample data
  orderService.initializeWithSampleData();
  
  // Try to load existing orders from file
  await orderService.loadFromFile();
  
  // Display current orders in console
  orderService.displayOrders();
  
  // Start web server
  final webServer = WebServer(orderService);
  await webServer.start();
  
  print('Press Ctrl+C to stop the server');
  
  // Handle shutdown gracefully
  ProcessSignal.sigint.watch().listen((signal) async {
    print('\nShutting down server...');
    await webServer.stop();
    exit(0);
  });
}
