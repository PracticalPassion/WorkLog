import 'package:flutter/cupertino.dart';

class SetupModel extends ChangeNotifier {
  int _selectedSetup = 1;

  int get selectedSetup => _selectedSetup;

  void selectSetup(int setup) {
    _selectedSetup = setup;
    notifyListeners();
  }
}
