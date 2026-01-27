import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final String userId;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final product = cartItem.product;
    if (product == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: cartItem.qty > 1
                          ? () async {
                              final cartProvider =
                                  Provider.of<CartProvider>(context, listen: false);
                              await cartProvider.updateCartItem(
                                userId: userId,
                                productId: cartItem.productId,
                                qty: cartItem.qty - 1,
                              );
                            }
                          : null,
                    ),
                    Text(
                      '${cartItem.qty}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () async {
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        await cartProvider.updateCartItem(
                          userId: userId,
                          productId: cartItem.productId,
                          qty: cartItem.qty + 1,
                        );
                      },
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Item'),
                        content: const Text('Remove this item from cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      await cartProvider.removeCartItem(
                        userId: userId,
                        productId: cartItem.productId,
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
