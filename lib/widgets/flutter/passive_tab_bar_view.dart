import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A page view that displays the widget which corresponds to the currently
/// selected tab. Typically used in conjunction with a [TabBar].
///
/// If a [TabController] is not provided, then there must be a [DefaultTabController]
/// ancestor.
class PassiveTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const PassiveTabBarView({
    Key key,
    @required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : assert(children != null),
       assert(dragStartBehavior != null),
       super(key: key);

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController controller;

  /// One widget per tab.
  final List<Widget> children;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _TabBarViewState createState() => _TabBarViewState();
}

final PageScrollPhysics _kTabBarViewPhysics = const PageScrollPhysics().applyTo(const ClampingScrollPhysics());

class _TabBarViewState extends State<PassiveTabBarView> {
  TabController _controller;
  PageController _pageController;
  List<Widget> _children;
  int _currentIndex;
  int _warpUnderwayCount = 0;

  void _updateTabController() {
    final TabController newController = widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.'
        );
      }
      return true;
    }());

    assert(() {
      if (newController.length != widget.children.length) {
        throw FlutterError(
          'Controller\'s length property (${newController.length}) does not match the \n'
          'number of elements (${widget.children.length}) present in TabBarView\'s children property.'
        );
      }
      return true;
    }());

    if (newController == _controller)
      return;

    if (_controller != null)
      _controller.animation.removeListener(_handleTabControllerAnimationTick);
    _controller = newController;
    if (_controller != null)
      _controller.animation.addListener(_handleTabControllerAnimationTick);
  }

  @override
  void initState() {
    super.initState();
    _children = widget.children;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = _controller?.index;
    _pageController = PageController(initialPage: _currentIndex ?? 0);
  }

  @override
  void didUpdateWidget(PassiveTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller)
      _updateTabController();
    if (widget.children != oldWidget.children && _warpUnderwayCount == 0)
      _children = widget.children;
  }

  @override
  void dispose() {
    if (_controller != null)
      _controller.animation.removeListener(_handleTabControllerAnimationTick);
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _handleTabControllerAnimationTick() {
    var mq = MediaQuery.of(context);
    _pageController.jumpTo((_controller.index + _controller.offset)*mq.size.width);
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: PageView(
        dragStartBehavior: widget.dragStartBehavior,
        controller: _pageController,
        physics: widget.physics == null ? _kTabBarViewPhysics : _kTabBarViewPhysics.applyTo(widget.physics),
        children: _children,
      ),
    );
  }
}