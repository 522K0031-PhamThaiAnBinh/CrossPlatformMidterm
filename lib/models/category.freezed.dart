// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpenseCategory _$ExpenseCategoryFromJson(Map<String, dynamic> json) {
  return _ExpenseCategory.fromJson(json);
}

/// @nodoc
mixin _$ExpenseCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color get color => throw _privateConstructorUsedError;
  double get budgetLimit => throw _privateConstructorUsedError;

  /// Serializes this ExpenseCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCategoryCopyWith<ExpenseCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCategoryCopyWith<$Res> {
  factory $ExpenseCategoryCopyWith(
          ExpenseCategory value, $Res Function(ExpenseCategory) then) =
      _$ExpenseCategoryCopyWithImpl<$Res, ExpenseCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color color,
      double budgetLimit});
}

/// @nodoc
class _$ExpenseCategoryCopyWithImpl<$Res, $Val extends ExpenseCategory>
    implements $ExpenseCategoryCopyWith<$Res> {
  _$ExpenseCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? budgetLimit = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      budgetLimit: null == budgetLimit
          ? _value.budgetLimit
          : budgetLimit // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseCategoryImplCopyWith<$Res>
    implements $ExpenseCategoryCopyWith<$Res> {
  factory _$$ExpenseCategoryImplCopyWith(_$ExpenseCategoryImpl value,
          $Res Function(_$ExpenseCategoryImpl) then) =
      __$$ExpenseCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color color,
      double budgetLimit});
}

/// @nodoc
class __$$ExpenseCategoryImplCopyWithImpl<$Res>
    extends _$ExpenseCategoryCopyWithImpl<$Res, _$ExpenseCategoryImpl>
    implements _$$ExpenseCategoryImplCopyWith<$Res> {
  __$$ExpenseCategoryImplCopyWithImpl(
      _$ExpenseCategoryImpl _value, $Res Function(_$ExpenseCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExpenseCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? budgetLimit = null,
  }) {
    return _then(_$ExpenseCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      budgetLimit: null == budgetLimit
          ? _value.budgetLimit
          : budgetLimit // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseCategoryImpl implements _ExpenseCategory {
  const _$ExpenseCategoryImpl(
      {required this.id,
      required this.name,
      required this.icon,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
      required this.color,
      this.budgetLimit = 0.0});

  factory _$ExpenseCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;
  @override
  @JsonKey()
  final double budgetLimit;

  @override
  String toString() {
    return 'ExpenseCategory(id: $id, name: $name, icon: $icon, color: $color, budgetLimit: $budgetLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.budgetLimit, budgetLimit) ||
                other.budgetLimit == budgetLimit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, icon, color, budgetLimit);

  /// Create a copy of ExpenseCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseCategoryImplCopyWith<_$ExpenseCategoryImpl> get copyWith =>
      __$$ExpenseCategoryImplCopyWithImpl<_$ExpenseCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseCategoryImplToJson(
      this,
    );
  }
}

abstract class _ExpenseCategory implements ExpenseCategory {
  const factory _ExpenseCategory(
      {required final String id,
      required final String name,
      required final String icon,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
      required final Color color,
      final double budgetLimit}) = _$ExpenseCategoryImpl;

  factory _ExpenseCategory.fromJson(Map<String, dynamic> json) =
      _$ExpenseCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color get color;
  @override
  double get budgetLimit;

  /// Create a copy of ExpenseCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseCategoryImplCopyWith<_$ExpenseCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
