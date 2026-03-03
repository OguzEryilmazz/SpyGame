abstract class Failure {
  final String message;
  const Failure(this.message);
}

class GameFailure extends Failure {
  const GameFailure(super.message);
}

class DataFailure extends Failure {
  const DataFailure(super.message);
}
