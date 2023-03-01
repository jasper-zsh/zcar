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

  void sweep(double value, Duration duration) {
    var step = 200;
    var current = 0.0;
    Timer.periodic(Duration(milliseconds: step), (timer) {
      current += value / (duration.inMilliseconds / step);
      if (current >= value) {
        timer.cancel();
        setValue(value);
        Timer(Duration(milliseconds: (duration.inMilliseconds / 3).floor()), () {
          current = value;
          Timer.periodic(Duration(milliseconds: step), (timer) {
            current -= value / (duration.inMilliseconds / step);
            if (current <= 0) {
              timer.cancel();
              setValue(0);
            } else {
              setValue(current);
            }
          });
        });
      } else {
        setValue(current);
      }
    });
  }
}