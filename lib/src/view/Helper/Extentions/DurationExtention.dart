extension DateTimeString on Duration {
  String toTimeStringHours() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = this.inMinutes.remainder(60).toString().padLeft(1, "0");
    String twoDigitSeconds = twoDigits(this.inSeconds.remainder(60));
    return "${twoDigits(this.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // 30 min to 0.5 Hours
  String toFractionalHours() {
    return (inMinutes / 60).toStringAsFixed(2);
  }

  String formatDaration2H2M() {
    return "${inHours.toString().padLeft(2, '0')}:${(inMinutes % 60).toString().padLeft(2, '0')}";
  }

  String formatDaration1H2M() {
    return "${inHours.toString().padLeft(1, '0')}:${(inMinutes % 60).toString().padLeft(2, '0')}";
  }

  String formatDarationH2M() {
    return "${inHours.toString()}:${(inMinutes % 60).toString().padLeft(2, '0')}";
  }

  // round to minutes
  Duration roundedToFullMinutes() {
    // Total milliseconds in the duration
    int totalMilliseconds = inMilliseconds;

    // Total milliseconds in a full minute
    const int minuteMilliseconds = 60 * 1000;

    // Calculate the nearest full minute
    int roundedMilliseconds = ((totalMilliseconds + (minuteMilliseconds / 2)) ~/ minuteMilliseconds) * minuteMilliseconds;

    // Return the new Duration
    return Duration(milliseconds: roundedMilliseconds);
  }

  Duration roundToMinute() {
    int totalMinutes = inMinutes;
    int remainingSeconds = inSeconds % 60;

    // Wenn Restsekunden vorhanden sind, Minuten um eins erhöhen
    if (remainingSeconds > 0) {
      totalMinutes++;
    }

    return Duration(minutes: totalMinutes);
  }
}
