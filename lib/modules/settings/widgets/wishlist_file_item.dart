import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/modules/settings/widgets/settings_option.widget.dart';

class WishlistFileItem extends SettingsOptionWidget {
  final WishlistFile file;
  final bool isAdded;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  WishlistFileItem({
    Key? key,
    required this.file,
    bool this.isAdded = false,
    VoidCallback? this.onAdd,
    VoidCallback? this.onRemove,
  }) : super(
          file.name ?? "",
          Text(file.description ?? ""),
        );

  @override
  Widget? buildTrailing(BuildContext context) {
    if (isAdded && onAdd != null) {
      return ElevatedButton(
        onPressed: onAdd,
        child: Text("Add".translate(context)),
        style: ButtonStyle(visualDensity: VisualDensity.compact),
      );
    }
    if (!isAdded && onRemove != null) {
      return ElevatedButton(
        onPressed: onRemove,
        child: Text("Remove".translate(context)),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          backgroundColor: MaterialStatePropertyAll<Color>(context.theme.errorLayers),
        ),
      );
    }
    return null;
  }

  @override
  getBackgroundColor() {}
}
