// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_manager.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerState {
  int get timeLeft => throw _privateConstructorUsedError;
  String get formattedTime => throw _privateConstructorUsedError;

  /// 1.0 = full, 0.0 = done
  double get progress => throw _privateConstructorUsedError;
  bool get isFinished => throw _privateConstructorUsedError;
  WarningLevel get warningLevel => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
    TimerState value,
    $Res Function(TimerState) then,
  ) = _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({
    int timeLeft,
    String formattedTime,
    double progress,
    bool isFinished,
    WarningLevel warningLevel,
  });
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeLeft = null,
    Object? formattedTime = null,
    Object? progress = null,
    Object? isFinished = null,
    Object? warningLevel = null,
  }) {
    return _then(
      _value.copyWith(
            timeLeft: null == timeLeft
                ? _value.timeLeft
                : timeLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            formattedTime: null == formattedTime
                ? _value.formattedTime
                : formattedTime // ignore: cast_nullable_to_non_nullable
                      as String,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
            isFinished: null == isFinished
                ? _value.isFinished
                : isFinished // ignore: cast_nullable_to_non_nullable
                      as bool,
            warningLevel: null == warningLevel
                ? _value.warningLevel
                : warningLevel // ignore: cast_nullable_to_non_nullable
                      as WarningLevel,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
    _$TimerStateImpl value,
    $Res Function(_$TimerStateImpl) then,
  ) = __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int timeLeft,
    String formattedTime,
    double progress,
    bool isFinished,
    WarningLevel warningLevel,
  });
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
    _$TimerStateImpl _value,
    $Res Function(_$TimerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timeLeft = null,
    Object? formattedTime = null,
    Object? progress = null,
    Object? isFinished = null,
    Object? warningLevel = null,
  }) {
    return _then(
      _$TimerStateImpl(
        timeLeft: null == timeLeft
            ? _value.timeLeft
            : timeLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        formattedTime: null == formattedTime
            ? _value.formattedTime
            : formattedTime // ignore: cast_nullable_to_non_nullable
                  as String,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
        isFinished: null == isFinished
            ? _value.isFinished
            : isFinished // ignore: cast_nullable_to_non_nullable
                  as bool,
        warningLevel: null == warningLevel
            ? _value.warningLevel
            : warningLevel // ignore: cast_nullable_to_non_nullable
                  as WarningLevel,
      ),
    );
  }
}

/// @nodoc

class _$TimerStateImpl implements _TimerState {
  const _$TimerStateImpl({
    required this.timeLeft,
    required this.formattedTime,
    required this.progress,
    required this.isFinished,
    required this.warningLevel,
  });

  @override
  final int timeLeft;
  @override
  final String formattedTime;

  /// 1.0 = full, 0.0 = done
  @override
  final double progress;
  @override
  final bool isFinished;
  @override
  final WarningLevel warningLevel;

  @override
  String toString() {
    return 'TimerState(timeLeft: $timeLeft, formattedTime: $formattedTime, progress: $progress, isFinished: $isFinished, warningLevel: $warningLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.timeLeft, timeLeft) ||
                other.timeLeft == timeLeft) &&
            (identical(other.formattedTime, formattedTime) ||
                other.formattedTime == formattedTime) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.warningLevel, warningLevel) ||
                other.warningLevel == warningLevel));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    timeLeft,
    formattedTime,
    progress,
    isFinished,
    warningLevel,
  );

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState implements TimerState {
  const factory _TimerState({
    required final int timeLeft,
    required final String formattedTime,
    required final double progress,
    required final bool isFinished,
    required final WarningLevel warningLevel,
  }) = _$TimerStateImpl;

  @override
  int get timeLeft;
  @override
  String get formattedTime;

  /// 1.0 = full, 0.0 = done
  @override
  double get progress;
  @override
  bool get isFinished;
  @override
  WarningLevel get warningLevel;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
