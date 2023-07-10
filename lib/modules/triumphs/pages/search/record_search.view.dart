import 'package:flutter/material.dart';
import 'package:little_light/modules/search/widgets/text_search_filter_field.widget.dart';
import 'package:little_light/modules/triumphs/widgets/record_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/fixed_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';

import 'record_search.bloc.dart';

class RecordsSearchView extends StatelessWidget {
  final RecordsSearchBloc bloc;
  final RecordsSearchBloc state;
  const RecordsSearchView(this.bloc, this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextSearchFilterFieldWidget(
          onUpdate: (query) => bloc.textSearch = query,
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Stack(
          children: [
            buildResultList(context),
            Positioned(
              child: buildNotifications(context),
              bottom: 0,
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
    ]);
  }

  Widget buildResultList(BuildContext context) {
    return MultiSectionScrollView(
      [
        FixedHeightScrollSection(
          128.0,
          itemBuilder: (context, index) {
            final recordHash = state.filteredItems?[index];
            return RecordItemWidget(
              recordHash,
              progress: state.getProgressData(recordHash),
            );
          },
          itemsPerRow: context.mediaQuery.responsiveValue(1, tablet: 2, desktop: 3),
          itemCount: state.filteredItems?.length ?? 0,
        ),
      ],
      padding: EdgeInsets.all(4) + EdgeInsets.only(bottom: context.mediaQuery.viewPadding.bottom),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );
  }

  Widget buildNotifications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: NotificationsWidget(),
        ),
        context.mediaQuery.viewPadding.bottom > 0 ? BusyIndicatorBottomGradientWidget() : BusyIndicatorLineWidget(),
      ],
    );
  }
}
