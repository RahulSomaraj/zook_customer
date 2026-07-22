import 'package:flutter/material.dart';

import '../../../shell/presentation/widgets/placeholder_scaffold.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScaffold(
        title: 'Orders',
        emoji: '📦',
        message: 'Your orders will appear here.',
      );
}
