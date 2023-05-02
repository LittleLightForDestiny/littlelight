import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/widgets/headers/bucket_header/bucket_display_options_selector.widget.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

class ItemSectionHeaderWidget extends StatelessWidget {
  final String sectionIdentifier;
  final Widget title;
  final Widget? trailing;
  final bool canEquip;
  final BucketDisplayType defaultType;

  final Set<BucketDisplayType> availableOptions;

  const ItemSectionHeaderWidget({
    required this.title,
    required this.sectionIdentifier,
    this.canEquip = false,
    Key? key,
    this.trailing,
    this.defaultType = BucketDisplayType.Medium,
    required this.availableOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderWidget(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: title),
          buildTrailing(context),
        ],
      ),
    );
  }

  Widget buildTrailing(BuildContext context) {
    return Row(children: [
      BucketDisplayOptionsSelector(
        sectionIdentifier,
        defaultType: this.defaultType,
        availableOptions: this.availableOptions,
      ),
      if (trailing != null) Container(padding: EdgeInsets.only(left: 8), child: trailing),
    ]);
  }
}
