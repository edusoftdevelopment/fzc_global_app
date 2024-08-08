import 'package:fzc_global_app/components/bottom_navigaton_bar.dart';
import 'package:flutter/material.dart';

class TabsNavigation extends StatefulWidget {
  const TabsNavigation({super.key});

  @override
  State<TabsNavigation> createState() => _TabsNavigationState();
}

class _TabsNavigationState extends State<TabsNavigation> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: true,
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }
}
