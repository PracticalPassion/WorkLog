extension DateTimeString on Duration {
  String toTimeStringHours() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = this.inMinutes.remainder(60).toString().padLeft(1, "0");
    String twoDigitSeconds = twoDigits(this.inSeconds.remainder(60));
    return "${twoDigits(this.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // 30 min to 0.5 Hours
  String toFractionalHours() {
    return (this.inMinutes / 60).toStringAsFixed(2);
  }
}
