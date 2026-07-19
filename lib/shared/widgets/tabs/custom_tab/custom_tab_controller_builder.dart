part of 'custom_tab.dart';

typedef _TabControllerWidgetBuilder = Widget Function(BuildContext context, CustomTabController controller);

class CustomTabControllerBuilder extends StatefulWidget {
  final int length;
  final _TabControllerWidgetBuilder builder;

  const CustomTabControllerBuilder(
    this.length, {
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CustomTabControllerBuilderState();
}

class CustomTabControllerBuilderState extends State<CustomTabControllerBuilder> with TickerProviderStateMixin {
  late CustomTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomTabController(length: widget.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomTabControllerBuilder oldWidget) {
    if (widget.length != _controller.length) {
      final initialIndex = _controller.index;
      _controller.dispose();
      _controller = CustomTabController(length: widget.length, vsync: this, initialIndex: initialIndex);
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
