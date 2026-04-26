import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String _baseUrlKey = 'api_base_url';
  static const String _compiledBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8787',
  );

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return 'http://10.0.2.2:8787/api';
    }

    final clean = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;

    return clean.endsWith('/api') ? clean : '$clean/api';
  }

  static String _baseUrl = _normalizeBaseUrl(_compiledBaseUrl);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl =
        _normalizeBaseUrl(prefs.getString(_baseUrlKey) ?? _compiledBaseUrl);
  }

  static Future<void> setBaseUrl(String url) async {
    _baseUrl = _normalizeBaseUrl(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _baseUrl);
  }

  static String get baseUrl => _baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanBase = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$cleanBase$cleanPath').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static Uri _wsUri(String path, [Map<String, dynamic>? queryParams]) {
    final httpUri = _uri(path, queryParams);
    final wsScheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    return httpUri.replace(scheme: wsScheme);
  }

  static dynamic _decode(http.Response res) {
    return jsonDecode(res.body);
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  // ── HEALTH CHECK ────────────────────────────────────────────────────────────
  static Future<bool> checkHealth() async {
    try {
      final uri = _uri('/health');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return false;

      final data = _decode(res);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── GET CART BY RFID ────────────────────────────────────────────────────────
  static Future<Cart?> getCartByRFID(String rfidCode) async {
    try {
      final uri = _uri('/cart/rfid/${Uri.encodeComponent(rfidCode)}');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return null;

      final cartPayload = data['data'] as Map<String, dynamic>;
      final cartJson = cartPayload['cart'] as Map<String, dynamic>;

      return Cart.fromJson(cartJson);
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── GET CART BY QR ──────────────────────────────────────────────────────────
  static Future<Cart?> getCartByQR(String qrCode) async {
    try {
      final uri = _uri('/cart/qr/${Uri.encodeComponent(qrCode)}');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return null;

      final cartPayload = data['data'] as Map<String, dynamic>;
      final cartJson = cartPayload['cart'] as Map<String, dynamic>;

      return Cart.fromJson(cartJson);
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<CartLiveSnapshot?> getCartItemsSnapshot(int cartId) async {
    try {
      final uri = _uri('/cart/$cartId/items');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return null;

      final payload = data['data'] as Map<String, dynamic>;
      final normalizedPayload = <String, dynamic>{
        ...payload,
        'cartId': payload['cartId'] ?? payload['cart_id'] ?? cartId,
      };

      return CartLiveSnapshot.fromJson({
        'message': data['message'],
        'lcdMessage': data['lcdMessage'],
        'data': normalizedPayload,
      });
    } catch (_) {
      return null;
    }
  }

  static Stream<CartLiveSnapshot> watchCartItemsLatest(int cartId) {
    late StreamController<CartLiveSnapshot> controller;
    WebSocket? socket;
    bool disposed = false;
    int reconnectAttempts = 0;

    Duration reconnectDelay(int attempts) {
      if (attempts <= 1) return const Duration(seconds: 1);
      if (attempts == 2) return const Duration(seconds: 2);
      if (attempts == 3) return const Duration(seconds: 4);
      return const Duration(seconds: 8);
    }

    Future<void> connect() async {
      if (disposed) return;

      try {
        final uri = _wsUri('/cart/$cartId/items/latest');
        socket = await WebSocket.connect(
          uri.toString(),
        ).timeout(const Duration(seconds: 8));

        reconnectAttempts = 0;

        socket!.listen(
          (event) {
            try {
              final raw =
                  event is String ? event : utf8.decode(event as List<int>);
              final decoded = jsonDecode(raw);

              if (decoded is! Map<String, dynamic>) return;
              if (decoded['success'] != true) return;

              final snapshot = CartLiveSnapshot.fromJson(decoded);
              if (!controller.isClosed) {
                controller.add(snapshot);
              }
            } catch (_) {}
          },
          onDone: () async {
            await socket?.close();
            socket = null;

            if (disposed) return;

            reconnectAttempts += 1;
            Future.delayed(reconnectDelay(reconnectAttempts), connect);
          },
          onError: (Object error) async {
            await socket?.close();
            socket = null;

            if (disposed) return;

            if (!controller.isClosed) {
              controller.addError(error);
            }

            reconnectAttempts += 1;
            Future.delayed(reconnectDelay(reconnectAttempts), connect);
          },
          cancelOnError: false,
        );
      } catch (error) {
        if (disposed) return;

        if (!controller.isClosed) {
          controller.addError(error);
        }

        reconnectAttempts += 1;
        Future.delayed(reconnectDelay(reconnectAttempts), connect);
      }
    }

    controller = StreamController<CartLiveSnapshot>(
      onListen: connect,
      onCancel: () async {
        disposed = true;
        await socket?.close();
        socket = null;
      },
    );

    return controller.stream;
  }

  // ── GET ALL PRODUCTS ────────────────────────────────────────────────────────
  static Future<List<Product>> getProducts() async {
    try {
      final uri = _uri('/products');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return [];

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return [];

      return (data['data'] as List<dynamic>)
          .map((product) => Product.fromJson(product as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── GET ALL BILLS ───────────────────────────────────────────────────────────
  static Future<List<Bill>> getBills({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final uri = _uri('/checkout/bills', {
        'limit': limit,
        'offset': offset,
      });

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return [];

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return [];

      return (data['data'] as List<dynamic>)
          .map((bill) => Bill.fromJson(bill as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── GET BILL FOR CART ───────────────────────────────────────────────────────
  static Future<Bill?> getBillForCart(int cartId) async {
    try {
      final uri = _uri('/checkout/bills', {
        'limit': 100,
        'offset': 0,
      });

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return null;

      final rawBills = data['data'] as List<dynamic>;

      for (final raw in rawBills) {
        final map = raw as Map<String, dynamic>;
        final rawCartId = map['cartId'] ?? map['cart_id'];

        if (_toInt(rawCartId) == cartId) {
          return Bill.fromJson(map);
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ── GET BILL BY NUMBER ──────────────────────────────────────────────────────
  static Future<Bill?> getBillByNumber(String billNumber) async {
    try {
      final uri = _uri('/checkout/bill/${Uri.encodeComponent(billNumber)}');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return null;

      return Bill.fromJson(data['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── SCAN PRODUCT INTO CART ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> scanProductToCart({
    required int cartId,
    required String barcode,
    required double measuredWeight,
  }) async {
    try {
      final uri = _uri('/cart/$cartId/scan');
      final res = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'barcode': barcode,
              'measuredWeight': measuredWeight,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = _decode(res);

      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Unknown response',
        'lcdMessage': data['lcdMessage'],
        'data': data['data'],
        'statusCode': res.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to backend',
        'error': e.toString(),
      };
    }
  }

  // ── UPDATE CART ITEM QUANTITY ───────────────────────────────────────────────
  static Future<bool> updateCartItemQuantity({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    try {
      final uri = _uri('/cart/$cartId/items/$productId');
      final res = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode({
              'quantity': quantity,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return false;

      final data = _decode(res);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── REMOVE CART ITEM ────────────────────────────────────────────────────────
  static Future<bool> removeCartItem({
    required int cartId,
    required int productId,
  }) async {
    try {
      final uri = _uri('/cart/$cartId/items/$productId');
      final res = await http
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return false;

      final data = _decode(res);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── CHECKOUT ────────────────────────────────────────────────────────────────
  static Future<Bill?> checkout({
    required int cartId,
    required int cashierId,
    required String paymentMethod,
  }) async {
    try {
      final uri = _uri('/checkout');
      final res = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'cartId': cartId,
              'cashierId': cashierId,
              'paymentMethod': paymentMethod,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return null;

      final billJson = data['data']['bill'] as Map<String, dynamic>;
      return Bill.fromJson(billJson);
    } catch (_) {
      return null;
    }
  }
}
