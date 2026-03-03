// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameSettings {
  /// 3–9 inclusive (mirrors Kotlin validation)
  int get playerCount => throw _privateConstructorUsedError;

  /// 1–15 minutes inclusive
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Whether a hint is shown to the spy
  bool get hintsEnabled => throw _privateConstructorUsedError;

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSettingsCopyWith<GameSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSettingsCopyWith<$Res> {
  factory $GameSettingsCopyWith(
    GameSettings value,
    $Res Function(GameSettings) then,
  ) = _$GameSettingsCopyWithImpl<$Res, GameSettings>;
  @useResult
  $Res call({int playerCount, int durationMinutes, bool hintsEnabled});
}

/// @nodoc
class _$GameSettingsCopyWithImpl<$Res, $Val extends GameSettings>
    implements $GameSettingsCopyWith<$Res> {
  _$GameSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerCount = null,
    Object? durationMinutes = null,
    Object? hintsEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            playerCount: null == playerCount
                ? _value.playerCount
                : playerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            hintsEnabled: null == hintsEnabled
                ? _value.hintsEnabled
                : hintsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSettingsImplCopyWith<$Res>
    implements $GameSettingsCopyWith<$Res> {
  factory _$$GameSettingsImplCopyWith(
    _$GameSettingsImpl value,
    $Res Function(_$GameSettingsImpl) then,
  ) = __$$GameSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int playerCount, int durationMinutes, bool hintsEnabled});
}

/// @nodoc
class __$$GameSettingsImplCopyWithImpl<$Res>
    extends _$GameSettingsCopyWithImpl<$Res, _$GameSettingsImpl>
    implements _$$GameSettingsImplCopyWith<$Res> {
  __$$GameSettingsImplCopyWithImpl(
    _$GameSettingsImpl _value,
    $Res Function(_$GameSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerCount = null,
    Object? durationMinutes = null,
    Object? hintsEnabled = null,
  }) {
    return _then(
      _$GameSettingsImpl(
        playerCount: null == playerCount
            ? _value.playerCount
            : playerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        hintsEnabled: null == hintsEnabled
            ? _value.hintsEnabled
            : hintsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GameSettingsImpl extends _GameSettings {
  const _$GameSettingsImpl({
    this.playerCount = 4,
    this.durationMinutes = 5,
    this.hintsEnabled = true,
  }) : super._();

  /// 3–9 inclusive (mirrors Kotlin validation)
  @override
  @JsonKey()
  final int playerCount;

  /// 1–15 minutes inclusive
  @override
  @JsonKey()
  final int durationMinutes;

  /// Whether a hint is shown to the spy
  @override
  @JsonKey()
  final bool hintsEnabled;

  @override
  String toString() {
    return 'GameSettings(playerCount: $playerCount, durationMinutes: $durationMinutes, hintsEnabled: $hintsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSettingsImpl &&
            (identical(other.playerCount, playerCount) ||
                other.playerCount == playerCount) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.hintsEnabled, hintsEnabled) ||
                other.hintsEnabled == hintsEnabled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, playerCount, durationMinutes, hintsEnabled);

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSettingsImplCopyWith<_$GameSettingsImpl> get copyWith =>
      __$$GameSettingsImplCopyWithImpl<_$GameSettingsImpl>(this, _$identity);
}

abstract class _GameSettings extends GameSettings {
  const factory _GameSettings({
    final int playerCount,
    final int durationMinutes,
    final bool hintsEnabled,
  }) = _$GameSettingsImpl;
  const _GameSettings._() : super._();

  /// 3–9 inclusive (mirrors Kotlin validation)
  @override
  int get playerCount;

  /// 1–15 minutes inclusive
  @override
  int get durationMinutes;

  /// Whether a hint is shown to the spy
  @override
  bool get hintsEnabled;

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSettingsImplCopyWith<_$GameSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
