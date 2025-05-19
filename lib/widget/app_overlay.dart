import 'package:flutter/material.dart';

class AppOverlay extends StatelessWidget {
  const AppOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black.withOpacity(0.2));
  }
}
