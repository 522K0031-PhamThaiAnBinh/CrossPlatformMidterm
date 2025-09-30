// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseCategoryImpl _$$ExpenseCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ExpenseCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: _colorFromJson((json['color'] as num).toInt()),
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$ExpenseCategoryImplToJson(
        _$ExpenseCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': _colorToJson(instance.color),
      'budgetLimit': instance.budgetLimit,
    };
