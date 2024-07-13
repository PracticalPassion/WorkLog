import 'package:flutter/cupertino.dart';

enum BorderType { all, top, bottom, none }

extension BorderTypeExtension on BorderType {
  BorderRadius get borderRadius {
    switch (this) {
      case BorderType.all:
        return const BorderRadius.all(Radius.circular(20));
      case BorderType.top:
        return const BorderRadius.vertical(top: Radius.circular(20));
      case BorderType.bottom:
        return const BorderRadius.vertical(bottom: Radius.circular(20));
      case BorderType.none:
        return BorderRadius.zero;
    }
  }

  static BorderType borderRadius_top_widget_expanded_state(BorderType borderType) {
    switch (borderType) {
      case BorderType.all:
        return BorderType.top;
      case BorderType.top:
        return BorderType.top;
      case BorderType.bottom:
        return BorderType.none;
      case BorderType.none:
        return BorderType.none;
    }
  }

  static BorderType borderRadius_expanded(BorderType borderType) {
    switch (borderType) {
      case BorderType.all:
        return BorderType.bottom;
      case BorderType.top:
        return BorderType.none;
      case BorderType.bottom:
        return BorderType.bottom;
      case BorderType.none:
        return BorderType.none;
    }
  }
}
