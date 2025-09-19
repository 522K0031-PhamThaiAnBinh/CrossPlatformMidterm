import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/add_expense_screen.dart';

class AddExpenseFab extends ConsumerWidget {
  const AddExpenseFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}