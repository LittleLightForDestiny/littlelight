import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/item_list/items/quick_select_item_wrapper.widget.dart';

import 'loadout_slot_options.dialog_route.dart';

extension on BuildContext {
  LoadoutIndexItem? get itemArgument {
    final argument = ModalRoute.of(this)?.settings.arguments;
    if (argument is LoadoutIndexItem) {
      return argument;
    }
    return null;
  }
}

class LoadoutSlotOptionsDialog extends LittleLightBaseDialog
    with ProfileConsumer {
  LoadoutSlotOptionsDialog()
      : super(
          titleBuilder: (context) =>
              Text("Loadout item options".translate(context)),
        );

  @override
  EdgeInsets? getDialogInsetPaddings(BuildContext context) {
    if (MediaQueryHelper(context).tabletOrBigger) {
      return super.getDialogInsetPaddings(context);
    }
    return super.getDialogInsetPaddings(context)?.copyWith(left: 0, right: 0);
  }

  @override
  Widget buildBodyContainer(BuildContext context) {
    final body = buildBody(context);
    if (body == null) return Container();
    final usePadding = MediaQueryHelper(context).tabletOrBigger;
    return Container(
        constraints: BoxConstraints(minWidth: maxWidth, maxHeight: maxHeight),
        padding: EdgeInsets.all(usePadding ? 16 : 4),
        child: body);
  }

  @override
  Widget? buildBody(BuildContext context) {
    final item = context.itemArgument?.item;
    final instanceID = item?.itemInstanceId;
    if (instanceID == null || item == null) return Container();
    final String? ownerID = profile.getItemOwner(instanceID);
    final itemWithOwner = ItemWithOwner(item, ownerID);
    return Container(
        child: QuickSelectItemWrapperWidget(itemWithOwner, null,
            characterId: ownerID ?? ItemWithOwner.OWNER_VAULT));
  }

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            "Cancel".translate(context).toUpperCase(),
          ),
          onPressed: () async {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: Text(
            "Details".translate(context).toUpperCase(),
          ),
          onPressed: () async {
            Navigator.of(context).pop(LoadoutSlotOptionsResponse.Details);
          },
        ),
        TextButton(
          child: Text(
            "Edit mods".translate(context).toUpperCase(),
          ),
          onPressed: () async {
            Navigator.of(context).pop(LoadoutSlotOptionsResponse.EditMods);
          },
        ),
        TextButton(
          child: Text(
            "Remove".translate(context).toUpperCase(),
          ),
          onPressed: () async {
            Navigator.of(context).pop(LoadoutSlotOptionsResponse.Remove);
          },
        ),
      ],
    );
  }
}
