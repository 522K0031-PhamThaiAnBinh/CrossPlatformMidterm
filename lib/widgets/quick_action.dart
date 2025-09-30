import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onFavoritesToggle;
  final Function(String) onPriorityFilter;
  final bool showFavoritesOnly;
  final String currentPriorityFilter;

  const QuickActions({
    super.key,
    required this.onFavoritesToggle,
    required this.onPriorityFilter,
    required this.showFavoritesOnly,
    required this.currentPriorityFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Favorites Toggle
          Expanded(
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: showFavoritesOnly ? Colors.white : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    showFavoritesOnly ? 'Favorites' : 'All',
                    style: TextStyle(
                      color: showFavoritesOnly ? Colors.white : null,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              selected: showFavoritesOnly,
              onSelected: (_) => onFavoritesToggle(),
              selectedColor: Colors.red,
              checkmarkColor: Colors.white,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Priority Filter
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: currentPriorityFilter,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                const DropdownMenuItem(value: 'urgent', child: Text('🔴 Urgent')),
                const DropdownMenuItem(value: 'high', child: Text('🟠 High')),
                const DropdownMenuItem(value: 'medium', child: Text('🟡 Medium')),
                const DropdownMenuItem(value: 'low', child: Text('🟢 Low')),
              ],
              onChanged: (value) => onPriorityFilter(value!),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}