class Product {
  String name;
  int price;
  String image;
  int qty;

  Product({
    required this.name,
    required this.price,
    required this.image,
    this.qty = 1,
  });
}
