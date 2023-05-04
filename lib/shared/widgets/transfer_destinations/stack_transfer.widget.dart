import 'dart:math';

import 'package:flutter/material.dart';
import 'package:little_light/shared/models/transfer_destination.dart';

import 'transfer_destinations.widget.dart';

typedef OnTransferPressed = void Function(int selectedCount, TransferDestination destination);

class StackTransferWidget extends StatefulWidget {
  final int total;
  final OnTransferPressed onTransferPressed;
  final List<TransferDestination> transferDestinations;
  const StackTransferWidget({
    Key? key,
    required this.total,
    required this.onTransferPressed,
    required this.transferDestinations,
  }) : super(key: key);

  @override
  State<StackTransferWidget> createState() => _StackTransferWidgetState();
}

class _StackTransferWidgetState extends State<StackTransferWidget> {
  double sliderValue = 0;
  int selectedCount = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    selectedCount = widget.total;
    total = widget.total;
    sliderValue = selectedCount / total;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedCount = min(selectedCount, widget.total);
    total = widget.total;
    sliderValue = selectedCount / total;
    setState(() {});
  }

  void updateValues(double value) {
    sliderValue = value;
    selectedCount = 1 + (value * (total - 1)).ceil();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildSlider(context),
          buildCounts(context),
          buildTransferDestinations(context),
        ],
      ),
    );
  }

  Widget buildSlider(BuildContext context) => Row(
        children: [
          Expanded(
              child: Container(
            child: Slider(
              value: sliderValue,
              onChanged: updateValues,
              divisions: total,
            ),
          )),
        ],
      );

  Widget buildCounts(BuildContext context) => AnimatedContainer(
        padding: EdgeInsets.symmetric(horizontal: 16),
        duration: Duration(milliseconds: 150),
        alignment: Alignment((selectedCount / total) * 2 - 1, 0),
        child: Text("$selectedCount"),
      );

  Widget buildTransferDestinations(BuildContext context) {
    return TransferDestinationsWidget(
      transferDestinations: widget.transferDestinations,
      onAction: (type, destination) {
        widget.onTransferPressed(selectedCount, destination);
      },
    );
  }
}
