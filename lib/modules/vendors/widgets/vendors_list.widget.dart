import 'package:flutter/material.dart';
import 'package:little_light/modules/vendors/pages/home/vendor_data.dart';
import 'package:little_light/modules/vendors/widgets/vendors_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';

typedef OnTapVendor = void Function(VendorData vendor);

class VendorsListWidget extends StatelessWidget {
  final List<VendorData> vendors;
  final OnTapVendor? onTapVendor;

  VendorsListWidget(
    List<VendorData> this.vendors, {
    Key? key,
    this.onTapVendor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSectionScrollView(
      [
        IntrinsicHeightScrollSection(
          itemBuilder: (context, index) => VendorsListItemWidget(
            vendors[index],
            onTap: () => onTapVendor?.call(vendors[index]),
          ),
          itemCount: vendors.length,
          itemsPerRow: context.mediaQuery.responsiveValue(1, tablet: 2, desktop: 3),
          rowAlignment: CrossAxisAlignment.stretch,
        )
      ],
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: MediaQuery.of(context).viewPadding.copyWith(top: 0) + const EdgeInsets.all(4),
    );
  }
}
