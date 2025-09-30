import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/add_expense_screen.dart';

class AddExpenseFab extends ConsumerWidget {
  // When an expense is created, we return whether it's paid (true) or unpaid (false)
  final void Function(bool isPaid)? onCreated;

  const AddExpenseFab({super.key, this.onCreated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () async {
        // Navigate to AddExpenseScreen and await the result.
        // We expect the AddExpenseScreen to pop with: Navigator.pop(context, isPaidBool)
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const AddExpenseScreen(),
          ),
        );

        if (result is bool && onCreated != null) {
          onCreated!(result); // true => Paid tab, false => Unpaid tab
        }
      },
      child: const Icon(Icons.add),
    );
  }
}