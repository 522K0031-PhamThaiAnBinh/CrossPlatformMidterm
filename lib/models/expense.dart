import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? description,
    
    // NEW OPTIONAL FIELDS (backward compatible)
    @Default([]) List<String> tags,
    @Default(false) bool isPaid,
    @Default('medium') String priority,
    @Default(false) bool isFavorite,
    String? location,
    String? notes,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}