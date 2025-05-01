import 'package:flutter/material.dart';

Widget buildBotomForAppBar(var tabController) {
  return TabBar(
    controller: tabController,
    tabs: const [Tab(text: 'INFO'), Tab(text: 'GAMES'), Tab(text: 'LEADER')],
  );
}
