import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/shared/modals/bucket_display_options_overlay/bucket_display_options_overlay_menu.route.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:provider/provider.dart';

class BucketDisplayOptionsSelector extends StatelessWidget {
  final String identifier;
  final BucketDisplayType defaultType;
  final List<BucketDisplayType> availableOptions;
  final GlobalKey globalKey;

  const BucketDisplayOptionsSelector(
    this.identifier, {
    Key? key,
    this.defaultType = BucketDisplayType.Medium,
    required GlobalKey this.globalKey,
    required this.availableOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentType = getCurrentType(context);
    final canEquip = availableOptions.contains(BucketDisplayType.OnlyEquipped);
    return Material(
      color: Colors.transparent,
      key: globalKey,
      child: InkWell(
        child: Container(
          width: 48,
          alignment: Alignment.center,
          child: Icon(canEquip ? currentType.equippableIcon : currentType.nonEquippableIcon, size: 24),
        ),
        onTap: () => openMenu(context, globalKey),
      ),
    );
  }

  BucketDisplayType getCurrentType(BuildContext context) =>
      context.watch<ItemSectionOptionsBloc>().getDisplayTypeForItemSection(identifier, defaultValue: defaultType);

  void setCurrentType(BuildContext context, BucketDisplayType type) =>
      context.read<ItemSectionOptionsBloc>().setDisplayTypeForItemSection(identifier, type);

  void openMenu(BuildContext context, GlobalKey globalKey) async {
    final type = await Navigator.of(context).push(BucketDisplayOptionsOverlayMenuRoute(
      identifier: identifier,
      defaultValue: defaultType,
      availableOptions: this.availableOptions,
      buttonKey: globalKey,
    ));
    if (type != null) {
      setCurrentType(context, type);
    }
  }
}
