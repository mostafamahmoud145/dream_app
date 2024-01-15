import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/tool_tip/tooltib_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CurrentToolTip {
  notification,
  none,
  search,
}

CurrentToolTip currentToolTip = CurrentToolTip.none;

class CustomTooltipManager extends StatefulWidget {
  final List<TooltipData> tooltips;

  final Widget Function(BuildContext, String, VoidCallback, int, int)
      tooltipBuilder;

  CustomTooltipManager({
    Key? key,
    required this.tooltips,
    required this.tooltipBuilder,
  }) : super(key: key);

  @override
  _CustomTooltipManagerState createState() => _CustomTooltipManagerState();
}

class _CustomTooltipManagerState extends State<CustomTooltipManager> {
  OverlayEntry? _overlayEntry;
  int _currentTooltipIndex = 0;
  String _firstLaunchKey = 'firstLaunchToolTip';
  GroceryUser user = new GroceryUser();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
  }

  Future<bool> getFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ??
        true; // Default to true if key doesn't exist
  }

  Future<void> saveTooltipState(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        key, true); // Save that the tooltip with this key has been shown
  }

  Future<bool> isTooltipShown(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ??
        false; // Return false if the key does not exist
  }

  void _showOverlay() async {
    bool shown =
        await isTooltipShown(widget.tooltips[_currentTooltipIndex].key);

    if (!shown) {
      _overlayEntry?.remove();
      final RenderBox renderBox = widget
          .tooltips[_currentTooltipIndex].globalKey.currentContext
          ?.findRenderObject() as RenderBox;
      final Offset position = renderBox.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: widget.tooltips[_currentTooltipIndex].position.dx,
          top: widget.tooltips[_currentTooltipIndex].position.dy +
              renderBox.size.height,
          child: widget.tooltipBuilder(
            context,
            widget.tooltips[_currentTooltipIndex].message,
            _showNextTooltip,
            _currentTooltipIndex,
            widget.tooltips.length,
          ),
        ),
      );

      Overlay.of(context)?.insert(_overlayEntry!);
      saveTooltipState(widget.tooltips[_currentTooltipIndex].key);
    }
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .update({'tooltipShown': true});
  }

  void _showNextTooltip() {
    if (_currentTooltipIndex < widget.tooltips.length - 1) {
      setState(() {
        if (_currentTooltipIndex == 0) {
          currentToolTip = CurrentToolTip.notification;
        } else {
          currentToolTip = CurrentToolTip.search;
        }
        _currentTooltipIndex++;
        _showOverlay();
      });
    } else {
      _overlayEntry?.remove();
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
