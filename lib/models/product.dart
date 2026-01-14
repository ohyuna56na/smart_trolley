class Product {
  final int id;
  final int productId;
  final String name;
  final int price;
  final String? image;
  int qty;

  Product({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productId: json['product_id'],
      name: json['product_name'],
      price: json['price'],
      qty: json['quantity'],
      image: json['product_image'],
    );
  }
}
