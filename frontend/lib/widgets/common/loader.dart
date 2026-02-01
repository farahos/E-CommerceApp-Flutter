import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const Loader({
    super.key,
    this.message,
    this.size = 40,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: color,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}