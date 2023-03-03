part of 'custom_tab.dart';

const _defaultDuration = Duration(milliseconds: 700);
const _defaultDragMultiplier = 1.2;

class CustomTabController extends ChangeNotifier {
  final AnimationController _animationController;
  final int length;
  final double dragMultiplier;

  Animation<double> get animation => _animationController.view;
  double get position => _animationController.view.value;
  double _currentValue;
  bool _isDragging = false;

  factory CustomTabController({
    required int length,
    required TickerProvider vsync,
    Duration duration = _defaultDuration,
    int initialIndex = 0,
    double dragMultiplier = _defaultDragMultiplier,
  }) {
    final last = length - 1;
    final initialValue = initialIndex.clamp(0, last).toDouble();
    final animationController = AnimationController(
      vsync: vsync,
      value: initialValue,
      duration: duration,
      lowerBound: 0,
      upperBound: last.toDouble(),
    );
    return CustomTabController._(
      animationController: animationController,
      initialValue: initialValue,
      length: length,
      dragMultiplier: dragMultiplier,
    );
  }

  CustomTabController._({
    required double initialValue,
    required AnimationController animationController,
    required this.length,
    required this.dragMultiplier,
  })  : _currentValue = initialValue,
        _animationController = animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dragBy(double amount) {
    _isDragging = true;
    _currentValue += amount * dragMultiplier;
    _currentValue = _currentValue.clamp(0, length - 1);
    _animationController.animateTo(_currentValue, duration: const Duration(milliseconds: 0));
  }

  void _dragStop() async {
    _isDragging = false;
    _currentValue = _currentValue.roundToDouble();
    _animationController.animateTo(_currentValue, curve: Curves.easeIn);
  }

  bool get isMoving => _isDragging || _animationController.isAnimating;

  int get index => _animationController.value.floor();

  void goToPage(int index) {
    _currentValue = index.toDouble();
    _animationController.animateTo(_currentValue, curve: Curves.easeIn);
  }
}
