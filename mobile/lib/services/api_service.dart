import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String _baseUrlKey = 'api_base_url';

  static String _defaultUrl() {
    if (kIsWeb) {
      return 'http://localhost:8787/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8787/api';
    }
    return 'http://localhost:8787/api';
  }

  static String _baseUrl = 'http://10.0.2.2:8787/api';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_baseUrlKey) ?? _defaultUrl();
  }

  static Future<void> setBaseUrl(String url) async {
    _baseUrl = url.endsWith('/api') ? url : '$url/api';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _baseUrl);
  }

  static String get baseUrl => _baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanBase =
        _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$cleanBase$cleanPath').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static dynamic _decode(http.Response res) {
    return jsonDecode(res.body);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
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

  // ── GET CART ITEMS ──────────────────────────────────────────────────────────
  static Future<List<CartItem>> getCartItems(int cartId) async {
    try {
      final uri = _uri('/cart/$cartId/items');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return [];

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return [];

      final payload = data['data'] as Map<String, dynamic>;
      final itemsJson = payload['items'] as List<dynamic>?;

      if (itemsJson == null) return [];

      return itemsJson
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── GET CART TOTAL ──────────────────────────────────────────────────────────
  static Future<double> getCartTotal(int cartId) async {
    try {
      final uri = _uri('/cart/$cartId/items');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return 0.0;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return 0.0;

      final payload = data['data'] as Map<String, dynamic>;
      return _toDouble(payload['total']);
    } catch (_) {
      return 0.0;
    }
  }

  // ── GET CART EXPECTED WEIGHT ────────────────────────────────────────────────
  static Future<double> getCartExpectedWeight(int cartId) async {
    try {
      final uri = _uri('/cart/$cartId/items');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return 0.0;

      final data = _decode(res);
      if (data['success'] != true || data['data'] == null) return 0.0;

      final payload = data['data'] as Map<String, dynamic>;
      return _toDouble(payload['expectedWeight']);
    } catch (_) {
      return 0.0;
    }
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