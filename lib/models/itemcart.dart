import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartModel with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalQuantity =>
      _items.fold(0, (total, item) => total + item.quantity);

  void addItem(String id, String imageUrl) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, imageUrl: imageUrl));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
}
