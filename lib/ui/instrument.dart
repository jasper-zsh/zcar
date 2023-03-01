import 'dart:async';

class InstrumentController {
  final StreamController<double> _valueStreamController = StreamController.broadcast();

  double value = 0;

  StreamSubscription<double> listen(Function(double) listener) {
    var sub = _valueStreamController.stream.listen(listener);
    _valueStreamController.sink.add(value);
    return sub;
  }

  void setValue(double value) {
    this.value = value;
    _valueStreamController.sink.add(this.value);
  }
}