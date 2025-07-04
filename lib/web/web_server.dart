import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class WebServer {
  final OrderService orderService;
  late HttpServer server;

  WebServer(this.orderService);

  Future<void> start() async {
    final router = Router();

    // API Routes
    router.get('/api/orders', _handleGetOrders);
    router.get('/api/orders/search', _handleSearchOrders);
    router.post('/api/orders', _handleAddOrder);
    router.delete('/api/orders/<index>', _handleDeleteOrder);

    // Static file handler for web assets
    final staticHandler = createStaticHandler('web', defaultDocument: 'index.html');
    
    // Main handler that combines static files and API routes
    final handler = Cascade()
        .add(router)
        .add(staticHandler)
        .handler;

    final pipeline = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware)
        .addHandler(handler);

    server = await serve(pipeline, InternetAddress.anyIPv4, 8080);
    print('Server running on http://localhost:${server.port}');
  }

  Future<void> stop() async {
    await server.close();
  }

  // CORS middleware
  Middleware get _corsMiddleware {
    return (Handler handler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }

        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  // Get all orders
  Future<Response> _handleGetOrders(Request request) async {
    try {
      final ordersJson = orderService.getOrdersAsJson();
      return Response.ok(
        ordersJson,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error retrieving orders: $e');
    }
  }

  // Search orders by item name
  Future<Response> _handleSearchOrders(Request request) async {
    try {
      final params = request.url.queryParameters;
      final query = params['q'] ?? '';
      
      final searchResults = orderService.searchByItemName(query);
      final searchJson = json.encode(searchResults.map((order) => order.toJson()).toList());
      
      return Response.ok(
        searchJson,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error searching orders: $e');
    }
  }

  // Add new order
  Future<Response> _handleAddOrder(Request request) async {
    try {
      final body = await request.readAsString();
      final Map<String, dynamic> orderData = json.decode(body);
      
      final order = Order.fromJson(orderData);
      await orderService.addOrder(order);
      
      return Response.ok(
        json.encode({'success': true, 'message': 'Order added successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error adding order: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Delete order by index
  Future<Response> _handleDeleteOrder(Request request, String indexStr) async {
    try {
      final index = int.parse(indexStr);
      await orderService.deleteOrder(index);
      
      return Response.ok(
        json.encode({'success': true, 'message': 'Order deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error deleting order: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
