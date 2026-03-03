// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Player {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Index into PlayerManager.availableColors
  int get colorIndex => throw _privateConstructorUsedError;

  /// 0-based index into CharacterAvatar (0–8)
  int get avatarIndex => throw _privateConstructorUsedError;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res, Player>;
  @useResult
  $Res call({String id, String name, int colorIndex, int avatarIndex});
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res, $Val extends Player>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorIndex = null,
    Object? avatarIndex = null,
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
            colorIndex: null == colorIndex
                ? _value.colorIndex
                : colorIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            avatarIndex: null == avatarIndex
                ? _value.avatarIndex
                : avatarIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerImplCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$$PlayerImplCopyWith(
    _$PlayerImpl value,
    $Res Function(_$PlayerImpl) then,
  ) = __$$PlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int colorIndex, int avatarIndex});
}

/// @nodoc
class __$$PlayerImplCopyWithImpl<$Res>
    extends _$PlayerCopyWithImpl<$Res, _$PlayerImpl>
    implements _$$PlayerImplCopyWith<$Res> {
  __$$PlayerImplCopyWithImpl(
    _$PlayerImpl _value,
    $Res Function(_$PlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorIndex = null,
    Object? avatarIndex = null,
  }) {
    return _then(
      _$PlayerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        colorIndex: null == colorIndex
            ? _value.colorIndex
            : colorIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        avatarIndex: null == avatarIndex
            ? _value.avatarIndex
            : avatarIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PlayerImpl implements _Player {
  const _$PlayerImpl({
    required this.id,
    required this.name,
    required this.colorIndex,
    this.avatarIndex = 0,
  });

  @override
  final String id;
  @override
  final String name;

  /// Index into PlayerManager.availableColors
  @override
  final int colorIndex;

  /// 0-based index into CharacterAvatar (0–8)
  @override
  @JsonKey()
  final int avatarIndex;

  @override
  String toString() {
    return 'Player(id: $id, name: $name, colorIndex: $colorIndex, avatarIndex: $avatarIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorIndex, colorIndex) ||
                other.colorIndex == colorIndex) &&
            (identical(other.avatarIndex, avatarIndex) ||
                other.avatarIndex == avatarIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, colorIndex, avatarIndex);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      __$$PlayerImplCopyWithImpl<_$PlayerImpl>(this, _$identity);
}

abstract class _Player implements Player {
  const factory _Player({
    required final String id,
    required final String name,
    required final int colorIndex,
    final int avatarIndex,
  }) = _$PlayerImpl;

  @override
  String get id;
  @override
  String get name;

  /// Index into PlayerManager.availableColors
  @override
  int get colorIndex;

  /// 0-based index into CharacterAvatar (0–8)
  @override
  int get avatarIndex;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GamePlayer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get colorIndex => throw _privateConstructorUsedError;
  int get avatarIndex => throw _privateConstructorUsedError;
  PlayerRole get role => throw _privateConstructorUsedError;

  /// Shared word that civilians see. null for the spy.
  String? get word => throw _privateConstructorUsedError;

  /// Hint shown only to the spy when hintsEnabled is true.
  String? get spyHint => throw _privateConstructorUsedError;

  /// Create a copy of GamePlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamePlayerCopyWith<GamePlayer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamePlayerCopyWith<$Res> {
  factory $GamePlayerCopyWith(
    GamePlayer value,
    $Res Function(GamePlayer) then,
  ) = _$GamePlayerCopyWithImpl<$Res, GamePlayer>;
  @useResult
  $Res call({
    String id,
    String name,
    int colorIndex,
    int avatarIndex,
    PlayerRole role,
    String? word,
    String? spyHint,
  });
}

/// @nodoc
class _$GamePlayerCopyWithImpl<$Res, $Val extends GamePlayer>
    implements $GamePlayerCopyWith<$Res> {
  _$GamePlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamePlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorIndex = null,
    Object? avatarIndex = null,
    Object? role = null,
    Object? word = freezed,
    Object? spyHint = freezed,
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
            colorIndex: null == colorIndex
                ? _value.colorIndex
                : colorIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            avatarIndex: null == avatarIndex
                ? _value.avatarIndex
                : avatarIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as PlayerRole,
            word: freezed == word
                ? _value.word
                : word // ignore: cast_nullable_to_non_nullable
                      as String?,
            spyHint: freezed == spyHint
                ? _value.spyHint
                : spyHint // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GamePlayerImplCopyWith<$Res>
    implements $GamePlayerCopyWith<$Res> {
  factory _$$GamePlayerImplCopyWith(
    _$GamePlayerImpl value,
    $Res Function(_$GamePlayerImpl) then,
  ) = __$$GamePlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int colorIndex,
    int avatarIndex,
    PlayerRole role,
    String? word,
    String? spyHint,
  });
}

/// @nodoc
class __$$GamePlayerImplCopyWithImpl<$Res>
    extends _$GamePlayerCopyWithImpl<$Res, _$GamePlayerImpl>
    implements _$$GamePlayerImplCopyWith<$Res> {
  __$$GamePlayerImplCopyWithImpl(
    _$GamePlayerImpl _value,
    $Res Function(_$GamePlayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamePlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? colorIndex = null,
    Object? avatarIndex = null,
    Object? role = null,
    Object? word = freezed,
    Object? spyHint = freezed,
  }) {
    return _then(
      _$GamePlayerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        colorIndex: null == colorIndex
            ? _value.colorIndex
            : colorIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        avatarIndex: null == avatarIndex
            ? _value.avatarIndex
            : avatarIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as PlayerRole,
        word: freezed == word
            ? _value.word
            : word // ignore: cast_nullable_to_non_nullable
                  as String?,
        spyHint: freezed == spyHint
            ? _value.spyHint
            : spyHint // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$GamePlayerImpl extends _GamePlayer {
  const _$GamePlayerImpl({
    required this.id,
    required this.name,
    required this.colorIndex,
    required this.avatarIndex,
    required this.role,
    this.word,
    this.spyHint,
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final int colorIndex;
  @override
  final int avatarIndex;
  @override
  final PlayerRole role;

  /// Shared word that civilians see. null for the spy.
  @override
  final String? word;

  /// Hint shown only to the spy when hintsEnabled is true.
  @override
  final String? spyHint;

  @override
  String toString() {
    return 'GamePlayer(id: $id, name: $name, colorIndex: $colorIndex, avatarIndex: $avatarIndex, role: $role, word: $word, spyHint: $spyHint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamePlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorIndex, colorIndex) ||
                other.colorIndex == colorIndex) &&
            (identical(other.avatarIndex, avatarIndex) ||
                other.avatarIndex == avatarIndex) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.spyHint, spyHint) || other.spyHint == spyHint));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    colorIndex,
    avatarIndex,
    role,
    word,
    spyHint,
  );

  /// Create a copy of GamePlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamePlayerImplCopyWith<_$GamePlayerImpl> get copyWith =>
      __$$GamePlayerImplCopyWithImpl<_$GamePlayerImpl>(this, _$identity);
}

abstract class _GamePlayer extends GamePlayer {
  const factory _GamePlayer({
    required final String id,
    required final String name,
    required final int colorIndex,
    required final int avatarIndex,
    required final PlayerRole role,
    final String? word,
    final String? spyHint,
  }) = _$GamePlayerImpl;
  const _GamePlayer._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  int get colorIndex;
  @override
  int get avatarIndex;
  @override
  PlayerRole get role;

  /// Shared word that civilians see. null for the spy.
  @override
  String? get word;

  /// Hint shown only to the spy when hintsEnabled is true.
  @override
  String? get spyHint;

  /// Create a copy of GamePlayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamePlayerImplCopyWith<_$GamePlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
