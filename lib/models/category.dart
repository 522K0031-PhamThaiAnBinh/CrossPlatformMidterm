import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class ExpenseCategory with _$ExpenseCategory {
  const factory ExpenseCategory({
    required String id,
    required String name,
    required String icon,
    @JsonKey(
      fromJson: _colorFromJson,
      toJson: _colorToJson,
    )
    required Color color,
    @Default(0.0) double budgetLimit,
  }) = _ExpenseCategory;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => 
      _$ExpenseCategoryFromJson(json);
}

// Helper functions to convert Color to/from JSON
Color _colorFromJson(int colorValue) => Color(colorValue);
int _colorToJson(Color color) => color.value;