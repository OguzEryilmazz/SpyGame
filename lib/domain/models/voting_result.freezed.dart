// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voting_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VotingResult {
  /// Player who received the most votes. null on a tie.
  GamePlayer? get mostVotedPlayer => throw _privateConstructorUsedError;

  /// The actual spy in this round.
  GamePlayer get spyPlayer => throw _privateConstructorUsedError;

  /// True when the most-voted player IS the spy.
  bool get isSpyCaught => throw _privateConstructorUsedError;

  /// playerName → vote count
  Map<String, int> get voteCounts => throw _privateConstructorUsedError;

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VotingResultCopyWith<VotingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VotingResultCopyWith<$Res> {
  factory $VotingResultCopyWith(
    VotingResult value,
    $Res Function(VotingResult) then,
  ) = _$VotingResultCopyWithImpl<$Res, VotingResult>;
  @useResult
  $Res call({
    GamePlayer? mostVotedPlayer,
    GamePlayer spyPlayer,
    bool isSpyCaught,
    Map<String, int> voteCounts,
  });

  $GamePlayerCopyWith<$Res>? get mostVotedPlayer;
  $GamePlayerCopyWith<$Res> get spyPlayer;
}

/// @nodoc
class _$VotingResultCopyWithImpl<$Res, $Val extends VotingResult>
    implements $VotingResultCopyWith<$Res> {
  _$VotingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mostVotedPlayer = freezed,
    Object? spyPlayer = null,
    Object? isSpyCaught = null,
    Object? voteCounts = null,
  }) {
    return _then(
      _value.copyWith(
            mostVotedPlayer: freezed == mostVotedPlayer
                ? _value.mostVotedPlayer
                : mostVotedPlayer // ignore: cast_nullable_to_non_nullable
                      as GamePlayer?,
            spyPlayer: null == spyPlayer
                ? _value.spyPlayer
                : spyPlayer // ignore: cast_nullable_to_non_nullable
                      as GamePlayer,
            isSpyCaught: null == isSpyCaught
                ? _value.isSpyCaught
                : isSpyCaught // ignore: cast_nullable_to_non_nullable
                      as bool,
            voteCounts: null == voteCounts
                ? _value.voteCounts
                : voteCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GamePlayerCopyWith<$Res>? get mostVotedPlayer {
    if (_value.mostVotedPlayer == null) {
      return null;
    }

    return $GamePlayerCopyWith<$Res>(_value.mostVotedPlayer!, (value) {
      return _then(_value.copyWith(mostVotedPlayer: value) as $Val);
    });
  }

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GamePlayerCopyWith<$Res> get spyPlayer {
    return $GamePlayerCopyWith<$Res>(_value.spyPlayer, (value) {
      return _then(_value.copyWith(spyPlayer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VotingResultImplCopyWith<$Res>
    implements $VotingResultCopyWith<$Res> {
  factory _$$VotingResultImplCopyWith(
    _$VotingResultImpl value,
    $Res Function(_$VotingResultImpl) then,
  ) = __$$VotingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GamePlayer? mostVotedPlayer,
    GamePlayer spyPlayer,
    bool isSpyCaught,
    Map<String, int> voteCounts,
  });

  @override
  $GamePlayerCopyWith<$Res>? get mostVotedPlayer;
  @override
  $GamePlayerCopyWith<$Res> get spyPlayer;
}

/// @nodoc
class __$$VotingResultImplCopyWithImpl<$Res>
    extends _$VotingResultCopyWithImpl<$Res, _$VotingResultImpl>
    implements _$$VotingResultImplCopyWith<$Res> {
  __$$VotingResultImplCopyWithImpl(
    _$VotingResultImpl _value,
    $Res Function(_$VotingResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mostVotedPlayer = freezed,
    Object? spyPlayer = null,
    Object? isSpyCaught = null,
    Object? voteCounts = null,
  }) {
    return _then(
      _$VotingResultImpl(
        mostVotedPlayer: freezed == mostVotedPlayer
            ? _value.mostVotedPlayer
            : mostVotedPlayer // ignore: cast_nullable_to_non_nullable
                  as GamePlayer?,
        spyPlayer: null == spyPlayer
            ? _value.spyPlayer
            : spyPlayer // ignore: cast_nullable_to_non_nullable
                  as GamePlayer,
        isSpyCaught: null == isSpyCaught
            ? _value.isSpyCaught
            : isSpyCaught // ignore: cast_nullable_to_non_nullable
                  as bool,
        voteCounts: null == voteCounts
            ? _value._voteCounts
            : voteCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc

class _$VotingResultImpl extends _VotingResult {
  const _$VotingResultImpl({
    this.mostVotedPlayer,
    required this.spyPlayer,
    this.isSpyCaught = false,
    final Map<String, int> voteCounts = const {},
  }) : _voteCounts = voteCounts,
       super._();

  /// Player who received the most votes. null on a tie.
  @override
  final GamePlayer? mostVotedPlayer;

  /// The actual spy in this round.
  @override
  final GamePlayer spyPlayer;

  /// True when the most-voted player IS the spy.
  @override
  @JsonKey()
  final bool isSpyCaught;

  /// playerName → vote count
  final Map<String, int> _voteCounts;

  /// playerName → vote count
  @override
  @JsonKey()
  Map<String, int> get voteCounts {
    if (_voteCounts is EqualUnmodifiableMapView) return _voteCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_voteCounts);
  }

  @override
  String toString() {
    return 'VotingResult(mostVotedPlayer: $mostVotedPlayer, spyPlayer: $spyPlayer, isSpyCaught: $isSpyCaught, voteCounts: $voteCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VotingResultImpl &&
            (identical(other.mostVotedPlayer, mostVotedPlayer) ||
                other.mostVotedPlayer == mostVotedPlayer) &&
            (identical(other.spyPlayer, spyPlayer) ||
                other.spyPlayer == spyPlayer) &&
            (identical(other.isSpyCaught, isSpyCaught) ||
                other.isSpyCaught == isSpyCaught) &&
            const DeepCollectionEquality().equals(
              other._voteCounts,
              _voteCounts,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mostVotedPlayer,
    spyPlayer,
    isSpyCaught,
    const DeepCollectionEquality().hash(_voteCounts),
  );

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VotingResultImplCopyWith<_$VotingResultImpl> get copyWith =>
      __$$VotingResultImplCopyWithImpl<_$VotingResultImpl>(this, _$identity);
}

abstract class _VotingResult extends VotingResult {
  const factory _VotingResult({
    final GamePlayer? mostVotedPlayer,
    required final GamePlayer spyPlayer,
    final bool isSpyCaught,
    final Map<String, int> voteCounts,
  }) = _$VotingResultImpl;
  const _VotingResult._() : super._();

  /// Player who received the most votes. null on a tie.
  @override
  GamePlayer? get mostVotedPlayer;

  /// The actual spy in this round.
  @override
  GamePlayer get spyPlayer;

  /// True when the most-voted player IS the spy.
  @override
  bool get isSpyCaught;

  /// playerName → vote count
  @override
  Map<String, int> get voteCounts;

  /// Create a copy of VotingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VotingResultImplCopyWith<_$VotingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
