import 'package:flutter/material.dart';
import 'package:little_light/modules/item_tags/views/select_tags.view.dart';

import 'edit_item_tags.bloc.dart';

class EditItemTagsView extends SelectTagsView {
  const EditItemTagsView({
    Key? key,
    required EditItemTagsBloc bloc,
    required EditItemTagsBloc state,
  }) : super(
          key: key,
          bloc: bloc,
          state: state,
        );
}
