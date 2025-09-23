// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isPaid: json['isPaid'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      isFavorite: json['isFavorite'] as bool? ?? false,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'category': instance.category,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
      'tags': instance.tags,
      'isPaid': instance.isPaid,
      'priority': instance.priority,
      'isFavorite': instance.isFavorite,
      'location': instance.location,
      'notes': instance.notes,
    };
