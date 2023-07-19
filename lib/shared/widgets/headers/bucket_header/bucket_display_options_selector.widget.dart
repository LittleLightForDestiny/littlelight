import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/headers/bucket_header/bucket_display_options_overlay_menu.widget.dart';
import 'package:little_light/shared/widgets/overlay/show_overlay.dart';
import 'package:provider/provider.dart';

class BucketDisplayOptionsSelector extends StatelessWidget {
  final String identifier;
  final BucketDisplayType defaultType;
  final Set<BucketDisplayType> availableOptions;

  const BucketDisplayOptionsSelector(
    this.identifier, {
    Key? key,
    this.defaultType = BucketDisplayType.Medium,
    required this.availableOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentType = getCurrentType(context);
    final canEquip = availableOptions.contains(BucketDisplayType.OnlyEquipped);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Container(
          width: 48,
          alignment: Alignment.center,
          child: Icon(canEquip ? currentType.equippableIcon : currentType.nonEquippableIcon, size: 24),
        ),
        onTap: () => openMenu(context),
      ),
    );
  }

  BucketDisplayType getCurrentType(BuildContext context) =>
      context.watch<ItemSectionOptionsBloc>().getDisplayTypeForItemSection(identifier, defaultValue: defaultType);

  void setCurrentType(BuildContext context, BucketDisplayType type) =>
      context.read<ItemSectionOptionsBloc>().setDisplayTypeForItemSection(identifier, type);

  void openMenu(BuildContext context) {
    final buttonKey = GlobalKey();
    showOverlay(
      context,
      (context, rect, animation, secondaryAnimation) => BucketDisplayOptionsOverlayMenu(
        currentValue: getCurrentType(context),
        sourceRenderBox: rect,
        availableOptions: this.availableOptions,
        buttonKey: buttonKey,
        onSelect: (type) {
          if (type != null) setCurrentType(context, type);
        },
      ),
    );
  }
}
