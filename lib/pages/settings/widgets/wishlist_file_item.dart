//@dart=2.12
import 'package:flutter/material.dart';
import 'package:little_light/models/wishlist_index.dart';

class WishlistFileItem extends StatelessWidget {
  final WishlistFile file;
  final List<Widget>? actions;

  const WishlistFileItem({
    Key? key,
    required this.file,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.secondary,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            file.name!,
                            style: Theme.of(context).textTheme.button,
                          ),
                          Text(
                            file.description!,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                if ((actions?.length ?? 0) > 0) buildActions(context),
              ],
            ),
          )));

  Widget buildActions(BuildContext context) {
    final actions = this.actions;
    if (actions == null) return Container();
    return Container(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions.map((e) => Container(child: e)).toList(),
      ),
    );
  }
}
