//@dart=2.12

import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/item_list/items/quick_select_item_wrapper.widget.dart';

enum LoadoutSlotOptionsResponse { Details, Remove, EditMods }

class LoadoutSlotOptionsDialogRoute extends DialogRoute<LoadoutSlotOptionsResponse?> {
  LoadoutSlotOptionsDialogRoute(BuildContext context, {required DestinyItemComponent item})
      : super(
          context: context,
          builder: (context) => LoadoutSlotOptionsDialog(),
          settings: RouteSettings(arguments: item),
        );
}

extension on BuildContext {
  DestinyItemComponent? get itemArgument {
    final argument = ModalRoute.of(this)?.settings.arguments;
    if (argument is DestinyItemComponent) {
      return argument;
    }
    return null;
  }
}

class LoadoutSlotOptionsDialog extends LittleLightBaseDialog with ProfileConsumer {
  LoadoutSlotOptionsDialog()
      : super(
          titleBuilder: (context) => TranslatedTextWidget('Loadout item options'),
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
    final item = context.itemArgument;
    final instanceID = item?.itemInstanceId;
    if (instanceID == null || item == null) return Container();
    final String? ownerID = profile.getItemOwner(instanceID);
    final itemWithOwner = ItemWithOwner(item, ownerID);
    return Container(
        child: QuickSelectItemWrapperWidget(itemWithOwner, null, characterId: ownerID ?? ItemWithOwner.OWNER_VAULT));
  }

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: TranslatedTextWidget("Cancel", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: TranslatedTextWidget("Details", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(LoadoutSlotOptionsResponse.Details);
          },
        ),
        TextButton(
          child: TranslatedTextWidget("Edit mods", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(LoadoutSlotOptionsResponse.EditMods);
          },
        ),
        TextButton(
          child: TranslatedTextWidget("Remove", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(LoadoutSlotOptionsResponse.Remove);
          },
        ),
      ],
    );
  }
}
