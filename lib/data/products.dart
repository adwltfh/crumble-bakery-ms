/// Menu demo mengikuti tujuh varian dan harga di foto yang diberikan pengguna.
/// Ubah daftar ini untuk menyesuaikan stok dan harga nyata.
class BakeryProduct {
  const BakeryProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.asset,
  });

  final String id;
  final String name;
  final int price;
  final String asset;
}

const products = <BakeryProduct>[
  BakeryProduct(
    id: 'garlic_beef', name: 'Garlic Beef', price: 19000,
    asset: 'assets/products/current_menu_7/garlic_beef.png',
  ),
  BakeryProduct(
    id: 'ube_mochi', name: 'Ube Mochi', price: 17000,
    asset: 'assets/products/current_menu_7/ube_mochi.png',
  ),
  BakeryProduct(
    id: 'original', name: 'Original', price: 13000,
    asset: 'assets/products/current_menu_7/original.png',
  ),
  BakeryProduct(
    id: 'cheesy_jalapeno', name: 'Cheesy Jalapeno', price: 23000,
    asset: 'assets/products/current_menu_7/cheesy_jalapeno.png',
  ),
  BakeryProduct(
    id: 'choco_mochi', name: 'Choco Mochi', price: 17000,
    asset: 'assets/products/current_menu_7/choco_mochi.png',
  ),
  BakeryProduct(
    id: 'cheese', name: 'Cheese', price: 17000,
    asset: 'assets/products/current_menu_7/cheese.png',
  ),
  BakeryProduct(
    id: 'double_choco', name: 'Double Choco', price: 17000,
    asset: 'assets/products/current_menu_7/double_choco.png',
  ),
];
