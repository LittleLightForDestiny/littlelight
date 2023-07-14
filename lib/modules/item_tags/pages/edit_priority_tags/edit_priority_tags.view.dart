import 'package:flutter/material.dart';
import 'package:little_light/modules/item_tags/views/select_tags.view.dart';
import 'edit_priority_tags.bloc.dart';

class EditPriorityTagsView extends SelectTagsView {
  const EditPriorityTagsView({
    Key? key,
    required EditPriorityTagsBloc bloc,
    required EditPriorityTagsBloc state,
  }) : super(
          key: key,
          bloc: bloc,
          state: state,
        );
}
