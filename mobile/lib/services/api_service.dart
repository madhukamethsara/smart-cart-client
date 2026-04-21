import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String _baseUrlKey = 'api_base_url';
  static const String _defaultUrl = 'http://localhost:8787/api';

  static String _baseUrl = _defaultUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_baseUrlKey) ?? _defaultUrl;
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

  // ── HEALTH CHECK ──
  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse(_baseUrl.replaceAll('/api', '/api/health'));
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── GET CART BY CODE ──
  static Future<Cart?> getCart(String cartCode) async {
    try {
      final uri = Uri.parse('$_baseUrl/carts/$cartCode');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final cartData = data['data'];
          // Try to get items from cart data or fetch separately
          List<CartItem> items = [];
          if (cartData['items'] != null) {
            items = (cartData['items'] as List)
                .map((i) => CartItem.fromJson(i))
                .toList();
          } else {
            items = await getCartItems(cartData['id'] ?? 0);
          }
          return Cart.fromJson(cartData, items: items);
        }
      }
      return null;
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── GET CART ITEMS ──
  static Future<List<CartItem>> getCartItems(int cartId) async {
    try {
      final uri = Uri.parse('$_baseUrl/carts/$cartId/items');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((i) => CartItem.fromJson(i))
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── GET BILL FOR CART ──
  static Future<Bill?> getBillForCart(int cartId) async {
    try {
      final uri = Uri.parse('$_baseUrl/checkout/bills?cart_id=$cartId');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final bills = data['data'] as List;
          if (bills.isNotEmpty) return Bill.fromJson(bills.first);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── GET ALL PRODUCTS ──
  static Future<List<Product>> getProducts() async {
    try {
      final uri = Uri.parse('$_baseUrl/products');
      final res = await http.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((p) => Product.fromJson(p))
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
