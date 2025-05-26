import 'package:app/home/widgets/home_drawer.dart';
import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:app/home/home.dart';
import 'package:app/home/widgets/home_tab.dart';

class HomePage extends StatefulWidget {
  final List<HomeTab> tabs;
  const HomePage({super.key, required this.tabs});

  static Route<dynamic> route(List<HomeTab> tabs) {
    return MaterialPageRoute<dynamic>(builder: (_) => HomePage(tabs: tabs));
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _drawerController = ZoomDrawerController();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      mainScreenScale: 0.15,
      controller: _drawerController,
      menuScreen: const HomeDrawer(),
      mainScreen: _buildMainScreen(context),
      showShadow: true,
      borderRadius: 30,
      angle: 0,
      drawerShadowsBackgroundColor: Theme.of(context).colorScheme.onSecondary,
      slideWidth: MediaQuery.of(context).size.width * 0.8,
      menuBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      mainScreenTapClose: true,
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    final currentTab = widget.tabs[_selectedTabIndex];
    final tabColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
    ];
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: HomeAppBar(
          onPressed: () {
            _drawerController.toggle?.call();
          },
          tabTitle: currentTab.tabTitle,
          tabSubtitle: currentTab.tabSubtitle,
          color: tabColors[_selectedTabIndex],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: currentTab.tabBody,
      ),
      bottomNavigationBar: BottomAppBar(
        child: ChicletSegmentedButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          height: 66,
          buttonHeight: 6,
          padding: EdgeInsets.zero,
          children: List.generate(widget.tabs.length, (index) {
            final tab = widget.tabs[index];
            return Expanded(
              child: ChicletButtonSegment(
                onPressed: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                backgroundColor: _selectedTabIndex == index
                    ? tabColors[index]
                    : null,
                child: tab.tabIcon,
              ),
            );
          }),
        ),
      ),
    );
  }
}
