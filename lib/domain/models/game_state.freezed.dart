// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameState {
  GameSettings get settings => throw _privateConstructorUsedError;

  /// Plain players as entered on PlayerSetupScreen.
  List<Player> get players => throw _privateConstructorUsedError;

  /// Selected sub-category for this round.
  SubCategory? get selectedSubCategory => throw _privateConstructorUsedError;

  /// Players with roles — populated after GameEngine.assignRoles.
  List<GamePlayer> get gamePlayers => throw _privateConstructorUsedError;

  /// Currently active phase.
  GamePhase get phase => throw _privateConstructorUsedError;

  /// Index of the player whose role card is being shown.
  int get currentPlayerIndex => throw _privateConstructorUsedError;

  /// Populated after the voting phase completes.
  VotingResult? get votingResult => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    GameSettings settings,
    List<Player> players,
    SubCategory? selectedSubCategory,
    List<GamePlayer> gamePlayers,
    GamePhase phase,
    int currentPlayerIndex,
    VotingResult? votingResult,
  });

  $GameSettingsCopyWith<$Res> get settings;
  $SubCategoryCopyWith<$Res>? get selectedSubCategory;
  $VotingResultCopyWith<$Res>? get votingResult;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? settings = null,
    Object? players = null,
    Object? selectedSubCategory = freezed,
    Object? gamePlayers = null,
    Object? phase = null,
    Object? currentPlayerIndex = null,
    Object? votingResult = freezed,
  }) {
    return _then(
      _value.copyWith(
            settings: null == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as GameSettings,
            players: null == players
                ? _value.players
                : players // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            selectedSubCategory: freezed == selectedSubCategory
                ? _value.selectedSubCategory
                : selectedSubCategory // ignore: cast_nullable_to_non_nullable
                      as SubCategory?,
            gamePlayers: null == gamePlayers
                ? _value.gamePlayers
                : gamePlayers // ignore: cast_nullable_to_non_nullable
                      as List<GamePlayer>,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as GamePhase,
            currentPlayerIndex: null == currentPlayerIndex
                ? _value.currentPlayerIndex
                : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            votingResult: freezed == votingResult
                ? _value.votingResult
                : votingResult // ignore: cast_nullable_to_non_nullable
                      as VotingResult?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSettingsCopyWith<$Res> get settings {
    return $GameSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubCategoryCopyWith<$Res>? get selectedSubCategory {
    if (_value.selectedSubCategory == null) {
      return null;
    }

    return $SubCategoryCopyWith<$Res>(_value.selectedSubCategory!, (value) {
      return _then(_value.copyWith(selectedSubCategory: value) as $Val);
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VotingResultCopyWith<$Res>? get votingResult {
    if (_value.votingResult == null) {
      return null;
    }

    return $VotingResultCopyWith<$Res>(_value.votingResult!, (value) {
      return _then(_value.copyWith(votingResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GameSettings settings,
    List<Player> players,
    SubCategory? selectedSubCategory,
    List<GamePlayer> gamePlayers,
    GamePhase phase,
    int currentPlayerIndex,
    VotingResult? votingResult,
  });

  @override
  $GameSettingsCopyWith<$Res> get settings;
  @override
  $SubCategoryCopyWith<$Res>? get selectedSubCategory;
  @override
  $VotingResultCopyWith<$Res>? get votingResult;
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? settings = null,
    Object? players = null,
    Object? selectedSubCategory = freezed,
    Object? gamePlayers = null,
    Object? phase = null,
    Object? currentPlayerIndex = null,
    Object? votingResult = freezed,
  }) {
    return _then(
      _$GameStateImpl(
        settings: null == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as GameSettings,
        players: null == players
            ? _value._players
            : players // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        selectedSubCategory: freezed == selectedSubCategory
            ? _value.selectedSubCategory
            : selectedSubCategory // ignore: cast_nullable_to_non_nullable
                  as SubCategory?,
        gamePlayers: null == gamePlayers
            ? _value._gamePlayers
            : gamePlayers // ignore: cast_nullable_to_non_nullable
                  as List<GamePlayer>,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as GamePhase,
        currentPlayerIndex: null == currentPlayerIndex
            ? _value.currentPlayerIndex
            : currentPlayerIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        votingResult: freezed == votingResult
            ? _value.votingResult
            : votingResult // ignore: cast_nullable_to_non_nullable
                  as VotingResult?,
      ),
    );
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl({
    this.settings = const GameSettings(),
    final List<Player> players = const [],
    this.selectedSubCategory,
    final List<GamePlayer> gamePlayers = const [],
    this.phase = GamePhase.setup,
    this.currentPlayerIndex = 0,
    this.votingResult,
  }) : _players = players,
       _gamePlayers = gamePlayers;

  @override
  @JsonKey()
  final GameSettings settings;

  /// Plain players as entered on PlayerSetupScreen.
  final List<Player> _players;

  /// Plain players as entered on PlayerSetupScreen.
  @override
  @JsonKey()
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  /// Selected sub-category for this round.
  @override
  final SubCategory? selectedSubCategory;

  /// Players with roles — populated after GameEngine.assignRoles.
  final List<GamePlayer> _gamePlayers;

  /// Players with roles — populated after GameEngine.assignRoles.
  @override
  @JsonKey()
  List<GamePlayer> get gamePlayers {
    if (_gamePlayers is EqualUnmodifiableListView) return _gamePlayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gamePlayers);
  }

  /// Currently active phase.
  @override
  @JsonKey()
  final GamePhase phase;

  /// Index of the player whose role card is being shown.
  @override
  @JsonKey()
  final int currentPlayerIndex;

  /// Populated after the voting phase completes.
  @override
  final VotingResult? votingResult;

  @override
  String toString() {
    return 'GameState(settings: $settings, players: $players, selectedSubCategory: $selectedSubCategory, gamePlayers: $gamePlayers, phase: $phase, currentPlayerIndex: $currentPlayerIndex, votingResult: $votingResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.selectedSubCategory, selectedSubCategory) ||
                other.selectedSubCategory == selectedSubCategory) &&
            const DeepCollectionEquality().equals(
              other._gamePlayers,
              _gamePlayers,
            ) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.currentPlayerIndex, currentPlayerIndex) ||
                other.currentPlayerIndex == currentPlayerIndex) &&
            (identical(other.votingResult, votingResult) ||
                other.votingResult == votingResult));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    settings,
    const DeepCollectionEquality().hash(_players),
    selectedSubCategory,
    const DeepCollectionEquality().hash(_gamePlayers),
    phase,
    currentPlayerIndex,
    votingResult,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);
}

abstract class _GameState implements GameState {
  const factory _GameState({
    final GameSettings settings,
    final List<Player> players,
    final SubCategory? selectedSubCategory,
    final List<GamePlayer> gamePlayers,
    final GamePhase phase,
    final int currentPlayerIndex,
    final VotingResult? votingResult,
  }) = _$GameStateImpl;

  @override
  GameSettings get settings;

  /// Plain players as entered on PlayerSetupScreen.
  @override
  List<Player> get players;

  /// Selected sub-category for this round.
  @override
  SubCategory? get selectedSubCategory;

  /// Players with roles — populated after GameEngine.assignRoles.
  @override
  List<GamePlayer> get gamePlayers;

  /// Currently active phase.
  @override
  GamePhase get phase;

  /// Index of the player whose role card is being shown.
  @override
  int get currentPlayerIndex;

  /// Populated after the voting phase completes.
  @override
  VotingResult? get votingResult;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
