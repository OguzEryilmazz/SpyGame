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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// The word list (JSON key: "items")
  List<String> get items => throw _privateConstructorUsedError;

  /// Spy hints shown when hintsEnabled is true
  List<String> get hints => throw _privateConstructorUsedError;

  /// Can be unlocked by watching a rewarded ad
  bool get unlockedByAd => throw _privateConstructorUsedError;

  /// Currently unlocked (by ad or purchase)
  bool get isUnlocked => throw _privateConstructorUsedError;

  /// Create a copy of SubCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubCategoryCopyWith<SubCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubCategoryCopyWith<$Res> {
  factory $SubCategoryCopyWith(
    SubCategory value,
    $Res Function(SubCategory) then,
  ) = _$SubCategoryCopyWithImpl<$Res, SubCategory>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String> items,
    List<String> hints,
    bool unlockedByAd,
    bool isUnlocked,
  });
}

/// @nodoc
class _$SubCategoryCopyWithImpl<$Res, $Val extends SubCategory>
    implements $SubCategoryCopyWith<$Res> {
  _$SubCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? items = null,
    Object? hints = null,
    Object? unlockedByAd = null,
    Object? isUnlocked = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            hints: null == hints
                ? _value.hints
                : hints // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            unlockedByAd: null == unlockedByAd
                ? _value.unlockedByAd
                : unlockedByAd // ignore: cast_nullable_to_non_nullable
                      as bool,
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubCategoryImplCopyWith<$Res>
    implements $SubCategoryCopyWith<$Res> {
  factory _$$SubCategoryImplCopyWith(
    _$SubCategoryImpl value,
    $Res Function(_$SubCategoryImpl) then,
  ) = __$$SubCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String> items,
    List<String> hints,
    bool unlockedByAd,
    bool isUnlocked,
  });
}

/// @nodoc
class __$$SubCategoryImplCopyWithImpl<$Res>
    extends _$SubCategoryCopyWithImpl<$Res, _$SubCategoryImpl>
    implements _$$SubCategoryImplCopyWith<$Res> {
  __$$SubCategoryImplCopyWithImpl(
    _$SubCategoryImpl _value,
    $Res Function(_$SubCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? items = null,
    Object? hints = null,
    Object? unlockedByAd = null,
    Object? isUnlocked = null,
  }) {
    return _then(
      _$SubCategoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hints: null == hints
            ? _value._hints
            : hints // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        unlockedByAd: null == unlockedByAd
            ? _value.unlockedByAd
            : unlockedByAd // ignore: cast_nullable_to_non_nullable
                  as bool,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$SubCategoryImpl extends _SubCategory {
  const _$SubCategoryImpl({
    required this.id,
    required this.name,
    final List<String> items = const [],
    final List<String> hints = const [],
    this.unlockedByAd = false,
    this.isUnlocked = false,
  }) : _items = items,
       _hints = hints,
       super._();

  @override
  final String id;
  @override
  final String name;

  /// The word list (JSON key: "items")
  final List<String> _items;

  /// The word list (JSON key: "items")
  @override
  @JsonKey()
  List<String> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Spy hints shown when hintsEnabled is true
  final List<String> _hints;

  /// Spy hints shown when hintsEnabled is true
  @override
  @JsonKey()
  List<String> get hints {
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hints);
  }

  /// Can be unlocked by watching a rewarded ad
  @override
  @JsonKey()
  final bool unlockedByAd;

  /// Currently unlocked (by ad or purchase)
  @override
  @JsonKey()
  final bool isUnlocked;

  @override
  String toString() {
    return 'SubCategory(id: $id, name: $name, items: $items, hints: $hints, unlockedByAd: $unlockedByAd, isUnlocked: $isUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._hints, _hints) &&
            (identical(other.unlockedByAd, unlockedByAd) ||
                other.unlockedByAd == unlockedByAd) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_hints),
    unlockedByAd,
    isUnlocked,
  );

  /// Create a copy of SubCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubCategoryImplCopyWith<_$SubCategoryImpl> get copyWith =>
      __$$SubCategoryImplCopyWithImpl<_$SubCategoryImpl>(this, _$identity);
}

abstract class _SubCategory extends SubCategory {
  const factory _SubCategory({
    required final String id,
    required final String name,
    final List<String> items,
    final List<String> hints,
    final bool unlockedByAd,
    final bool isUnlocked,
  }) = _$SubCategoryImpl;
  const _SubCategory._() : super._();

  @override
  String get id;
  @override
  String get name;

  /// The word list (JSON key: "items")
  @override
  List<String> get items;

  /// Spy hints shown when hintsEnabled is true
  @override
  List<String> get hints;

  /// Can be unlocked by watching a rewarded ad
  @override
  bool get unlockedByAd;

  /// Currently unlocked (by ad or purchase)
  @override
  bool get isUnlocked;

  /// Create a copy of SubCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubCategoryImplCopyWith<_$SubCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Category {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Material icon name string (e.g. "work", "restaurant")
  String get iconName => throw _privateConstructorUsedError;

  /// Hex color string (e.g. "#2196F3")
  String get colorHex => throw _privateConstructorUsedError;

  /// Requires purchase to play
  bool get isLocked => throw _privateConstructorUsedError;

  /// Price in Turkish Lira; 0.0 means free
  double get priceTL => throw _privateConstructorUsedError;

  /// True when this category uses subcategories instead of a flat item list
  bool get hasSubcategories => throw _privateConstructorUsedError;

  /// Flat item list — only populated when hasSubcategories is false
  List<String> get items => throw _privateConstructorUsedError;

  /// Flat hint list — only populated when hasSubcategories is false
  List<String> get hints => throw _privateConstructorUsedError;

  /// Populated when hasSubcategories is true
  List<SubCategory> get subcategories => throw _privateConstructorUsedError;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call({
    String id,
    String name,
    String iconName,
    String colorHex,
    bool isLocked,
    double priceTL,
    bool hasSubcategories,
    List<String> items,
    List<String> hints,
    List<SubCategory> subcategories,
  });
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconName = null,
    Object? colorHex = null,
    Object? isLocked = null,
    Object? priceTL = null,
    Object? hasSubcategories = null,
    Object? items = null,
    Object? hints = null,
    Object? subcategories = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            isLocked: null == isLocked
                ? _value.isLocked
                : isLocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            priceTL: null == priceTL
                ? _value.priceTL
                : priceTL // ignore: cast_nullable_to_non_nullable
                      as double,
            hasSubcategories: null == hasSubcategories
                ? _value.hasSubcategories
                : hasSubcategories // ignore: cast_nullable_to_non_nullable
                      as bool,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            hints: null == hints
                ? _value.hints
                : hints // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            subcategories: null == subcategories
                ? _value.subcategories
                : subcategories // ignore: cast_nullable_to_non_nullable
                      as List<SubCategory>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
    _$CategoryImpl value,
    $Res Function(_$CategoryImpl) then,
  ) = __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String iconName,
    String colorHex,
    bool isLocked,
    double priceTL,
    bool hasSubcategories,
    List<String> items,
    List<String> hints,
    List<SubCategory> subcategories,
  });
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
    _$CategoryImpl _value,
    $Res Function(_$CategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconName = null,
    Object? colorHex = null,
    Object? isLocked = null,
    Object? priceTL = null,
    Object? hasSubcategories = null,
    Object? items = null,
    Object? hints = null,
    Object? subcategories = null,
  }) {
    return _then(
      _$CategoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        isLocked: null == isLocked
            ? _value.isLocked
            : isLocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        priceTL: null == priceTL
            ? _value.priceTL
            : priceTL // ignore: cast_nullable_to_non_nullable
                  as double,
        hasSubcategories: null == hasSubcategories
            ? _value.hasSubcategories
            : hasSubcategories // ignore: cast_nullable_to_non_nullable
                  as bool,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hints: null == hints
            ? _value._hints
            : hints // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        subcategories: null == subcategories
            ? _value._subcategories
            : subcategories // ignore: cast_nullable_to_non_nullable
                  as List<SubCategory>,
      ),
    );
  }
}

/// @nodoc

class _$CategoryImpl extends _Category {
  const _$CategoryImpl({
    required this.id,
    required this.name,
    this.iconName = 'category',
    this.colorHex = '#607D8B',
    this.isLocked = false,
    this.priceTL = 0.0,
    this.hasSubcategories = false,
    final List<String> items = const [],
    final List<String> hints = const [],
    final List<SubCategory> subcategories = const [],
  }) : _items = items,
       _hints = hints,
       _subcategories = subcategories,
       super._();

  @override
  final String id;
  @override
  final String name;

  /// Material icon name string (e.g. "work", "restaurant")
  @override
  @JsonKey()
  final String iconName;

  /// Hex color string (e.g. "#2196F3")
  @override
  @JsonKey()
  final String colorHex;

  /// Requires purchase to play
  @override
  @JsonKey()
  final bool isLocked;

  /// Price in Turkish Lira; 0.0 means free
  @override
  @JsonKey()
  final double priceTL;

  /// True when this category uses subcategories instead of a flat item list
  @override
  @JsonKey()
  final bool hasSubcategories;

  /// Flat item list — only populated when hasSubcategories is false
  final List<String> _items;

  /// Flat item list — only populated when hasSubcategories is false
  @override
  @JsonKey()
  List<String> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Flat hint list — only populated when hasSubcategories is false
  final List<String> _hints;

  /// Flat hint list — only populated when hasSubcategories is false
  @override
  @JsonKey()
  List<String> get hints {
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hints);
  }

  /// Populated when hasSubcategories is true
  final List<SubCategory> _subcategories;

  /// Populated when hasSubcategories is true
  @override
  @JsonKey()
  List<SubCategory> get subcategories {
    if (_subcategories is EqualUnmodifiableListView) return _subcategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subcategories);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, iconName: $iconName, colorHex: $colorHex, isLocked: $isLocked, priceTL: $priceTL, hasSubcategories: $hasSubcategories, items: $items, hints: $hints, subcategories: $subcategories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.priceTL, priceTL) || other.priceTL == priceTL) &&
            (identical(other.hasSubcategories, hasSubcategories) ||
                other.hasSubcategories == hasSubcategories) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._hints, _hints) &&
            const DeepCollectionEquality().equals(
              other._subcategories,
              _subcategories,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    iconName,
    colorHex,
    isLocked,
    priceTL,
    hasSubcategories,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_hints),
    const DeepCollectionEquality().hash(_subcategories),
  );

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);
}

abstract class _Category extends Category {
  const factory _Category({
    required final String id,
    required final String name,
    final String iconName,
    final String colorHex,
    final bool isLocked,
    final double priceTL,
    final bool hasSubcategories,
    final List<String> items,
    final List<String> hints,
    final List<SubCategory> subcategories,
  }) = _$CategoryImpl;
  const _Category._() : super._();

  @override
  String get id;
  @override
  String get name;

  /// Material icon name string (e.g. "work", "restaurant")
  @override
  String get iconName;

  /// Hex color string (e.g. "#2196F3")
  @override
  String get colorHex;

  /// Requires purchase to play
  @override
  bool get isLocked;

  /// Price in Turkish Lira; 0.0 means free
  @override
  double get priceTL;

  /// True when this category uses subcategories instead of a flat item list
  @override
  bool get hasSubcategories;

  /// Flat item list — only populated when hasSubcategories is false
  @override
  List<String> get items;

  /// Flat hint list — only populated when hasSubcategories is false
  @override
  List<String> get hints;

  /// Populated when hasSubcategories is true
  @override
  List<SubCategory> get subcategories;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
