import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Definiere einen Typ für die Callback-Funktion, die beim Tippen auf ein Element aufgerufen wird.
typedef OnSelectCallback = void Function(int index);

class VerticalSelection extends StatefulWidget {
  final List<String> data; // Die Daten, die angezeigt werden sollen.
  final int selectedIndex; // Der aktuell ausgewählte Index.
  final OnSelectCallback onSelect; // Die Callback-Funktion für die Auswahl.
  final Color selectedColor; // Die Farbe für das ausgewählte Element.
  final Color unselectedColor; // Die Farbe für nicht ausgewählte Elemente.
  const VerticalSelection({
    Key? key,
    required this.data,
    required this.selectedIndex,
    required this.onSelect,
    this.selectedColor = const Color.fromARGB(255, 61, 140, 90),
    this.unselectedColor = const Color.fromARGB(255, 227, 231, 234),
  }) : super(key: key);

  @override
  _VerticalSelectionState createState() => _VerticalSelectionState();
}

class _VerticalSelectionState extends State<VerticalSelection> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedIndex();
    });
  }

  void _scrollToSelectedIndex() {
    if (_scrollController.hasClients) {
      double offset = widget.selectedIndex * 90.0; // 90.0 ist der geschätzte Item-Breite mit Padding und Margin.
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 15),
      height: 37.0,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.data.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => widget.onSelect(index),
            child: Container(
              constraints: const BoxConstraints(minWidth: 80),
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: widget.selectedIndex == index ? widget.selectedColor : widget.unselectedColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  widget.data[index],
                  style: TextStyle(color: widget.selectedIndex == index ? CupertinoColors.white : CupertinoColors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
