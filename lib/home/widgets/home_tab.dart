import 'package:flutter/material.dart';

class HomeTab {
  final Widget tabBody;
  final String tabTitle;
  final String tabSubtitle;
  final Widget tabIcon;

  const HomeTab({
    required this.tabBody,
    required this.tabTitle,
    required this.tabSubtitle,
    required this.tabIcon,
  });
}
