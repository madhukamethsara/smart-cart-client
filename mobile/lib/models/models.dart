// ── PRODUCT MODEL ──
class Product {
  final int id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final String? category;
  final double? weight;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.category,
    this.weight,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        barcode: j['barcode'] ?? '',
        price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
        stock: int.tryParse(j['stock']?.toString() ?? '0') ?? 0,
        category: j['category'],
        weight: j['weight'] != null
            ? double.tryParse(j['weight'].toString())
            : null,
      );
}

// ── CART ITEM MODEL ──
class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final String productName;
  final String barcode;
  final double price;
  final int quantity;
  final double? weight;
  final String? category;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.price,
    required this.quantity,
    this.weight,
    this.category,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: j['id'] ?? 0,
        cartId: j['cart_id'] ?? j['cartId'] ?? 0,
        productId: j['product_id'] ?? j['productId'] ?? 0,
        productName: j['product_name'] ?? j['name'] ?? 'Unknown Item',
        barcode: j['barcode'] ?? '',
        price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
        quantity: int.tryParse(j['quantity']?.toString() ?? '1') ?? 1,
        weight: j['weight'] != null
            ? double.tryParse(j['weight'].toString())
            : null,
        category: j['category'],
      );
}

class CartLiveSnapshot {
  final int cartId;
  final List<CartItem> items;
  final double total;
  final double expectedWeight;
  final String? message;
  final String? lcdMessage;

  const CartLiveSnapshot({
    required this.cartId,
    required this.items,
    required this.total,
    required this.expectedWeight,
    this.message,
    this.lcdMessage,
  });

  factory CartLiveSnapshot.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] as Map<String, dynamic>?) ?? const {};
    final rawItems = (payload['items'] as List<dynamic>?) ?? const [];

    return CartLiveSnapshot(
      cartId: int.tryParse(payload['cartId']?.toString() ?? '0') ?? 0,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList(),
      total: double.tryParse(payload['total']?.toString() ?? '0') ?? 0,
      expectedWeight:
          double.tryParse(payload['expectedWeight']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString(),
      lcdMessage: json['lcdMessage']?.toString(),
    );
  }
}

// ── CART MODEL ──
class Cart {
  final int id;
  final String cartCode;
  final String status;
  final List<CartItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Cart({
    required this.id,
    required this.cartCode,
    required this.status,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.fromJson(Map<String, dynamic> j, {List<CartItem>? items}) =>
      Cart(
        id: j['id'] ?? 0,
        cartCode: j['cart_code'] ?? j['code'] ?? j['id']?.toString() ?? '',
        status: j['status'] ?? 'active',
        items: items ?? [],
        createdAt:
            j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
        updatedAt:
            j['updated_at'] != null ? DateTime.tryParse(j['updated_at']) : null,
      );
}

// ── BILL MODEL ──
class Bill {
  final int id;
  final String billNumber;
  final int cartId;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;

  const Bill({
    required this.id,
    required this.billNumber,
    required this.cartId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> j) => Bill(
        id: j['id'] ?? 0,
        billNumber: j['bill_number'] ?? '',
        cartId: j['cart_id'] ?? 0,
        totalAmount: double.tryParse(j['total_amount']?.toString() ?? '0') ?? 0,
        paymentMethod: j['payment_method'] ?? 'Cash',
        status: j['status'] ?? 'paid',
        createdAt:
            j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
      );
}

// ── DEMO DATA (used when backend is unreachable) ──
class DemoData {
  static Cart demoCart(String cartCode) => Cart(
        id: 42,
        cartCode: cartCode,
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(minutes: 23)),
        items: [
          const CartItem(
              id: 1,
              cartId: 42,
              productId: 1,
              productName: 'Organic Whole Milk 1L',
              barcode: '4891234567890',
              price: 485.00,
              quantity: 2,
              category: 'Dairy',
              weight: 1000),
          const CartItem(
              id: 2,
              cartId: 42,
              productId: 2,
              productName: 'Brown Basmati Rice 1kg',
              barcode: '4891234567891',
              price: 320.00,
              quantity: 1,
              category: 'Grains',
              weight: 1000),
          const CartItem(
              id: 3,
              cartId: 42,
              productId: 3,
              productName: 'Free Range Eggs x6',
              barcode: '4891234567892',
              price: 290.00,
              quantity: 1,
              category: 'Dairy',
              weight: 360),
          const CartItem(
              id: 4,
              cartId: 42,
              productId: 4,
              productName: 'Extra Virgin Olive Oil 500ml',
              barcode: '4891234567893',
              price: 1450.00,
              quantity: 1,
              category: 'Oils',
              weight: 500),
          const CartItem(
              id: 5,
              cartId: 42,
              productId: 5,
              productName: 'Greek Yoghurt 400g',
              barcode: '4891234567894',
              price: 380.00,
              quantity: 3,
              category: 'Dairy',
              weight: 400),
        ],
      );
}
