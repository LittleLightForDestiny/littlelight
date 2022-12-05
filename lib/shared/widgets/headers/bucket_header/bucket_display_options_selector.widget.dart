import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/headers/bucket_header/bucket_display_options_overlay_menu.widget.dart';
import 'package:little_light/shared/widgets/overlay/show_overlay.dart';
import 'package:provider/provider.dart';

class BucketDisplayOptionsSelector extends StatelessWidget {
  final int bucketHash;

  const BucketDisplayOptionsSelector(this.bucketHash, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Container(
          width: 48,
          alignment: Alignment.center,
          child: Icon(getCurrentType(context).equippableIcon, size: 24),
        ),
        onTap: () => openMenu(context),
      ),
    );
  }

  BucketDisplayType getCurrentType(BuildContext context) =>
      context.watch<BucketOptionsBloc>().getDisplayTypeForCharacterBucket(bucketHash);

  void setCurrentType(BuildContext context, BucketDisplayType type) =>
      context.read<BucketOptionsBloc>().setDisplayTypeForCharacterBucket(bucketHash, type);

  void openMenu(BuildContext context) {
    showOverlay(
      context,
      (context, rect, onClose) => BucketDisplayOptionsOverlayMenu(
        currentValue: getCurrentType(context),
        sourceRenderBox: rect,
        onSelect: (type) {
          if (type != null) setCurrentType(context, type);
        },
        onClose: onClose,
      ),
    );
  }
}
