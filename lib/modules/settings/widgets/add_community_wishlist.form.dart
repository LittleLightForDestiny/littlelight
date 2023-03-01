import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/modules/settings/pages/add_wishlist/add_wishlists.bloc.dart';

import 'package:little_light/widgets/dialogs/busy.dialog.dart';
import 'package:provider/provider.dart';

import 'wishlist_file_item.dart';

class AddCommunityWishlistForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddCommunityWishlistFormState();
  }
}

class AddCommunityWishlistFormState extends State<AddCommunityWishlistForm>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context.read<AddWishlistsBloc>().getWishlists();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final root = context.watch<AddWishlistsBloc>().isRootFolder;
    if (root) {
      return buildWishlistsRootContent(context);
    }
    return buildWishlistsFolderContent(context);
  }

  Widget buildWishlistsRootContent(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(8) +
                MediaQuery.of(context).viewPadding.copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildWishlists(context),
                buildFolders(context),
              ],
            )));
  }

  Widget buildWishlistsFolderContent(BuildContext context) {
    return Container(
        child: Column(children: [
      buildFolderHeader(context),
      Expanded(
          child: SingleChildScrollView(
              child: Container(
                  child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildWishlists(context),
          buildFolders(context),
        ],
      ))))
    ]));
  }

  Widget buildFolderHeader(BuildContext context) {
    final folder = context.watch<AddWishlistsBloc>().currentFolder;
    return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            BackButton(
              onPressed: () {
                context.read<AddWishlistsBloc>().goToRoot();
              },
            ),
            Container(
              width: 8,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  folder!.name!,
                  style: Theme.of(context).textTheme.button,
                ),
                Container(height: 4),
                Text(
                  folder.description!,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ))
          ],
        ));
  }

  Widget buildWishlists(BuildContext context) {
    final currentFolder = context.watch<AddWishlistsBloc>().currentFolder;
    final files = currentFolder?.files;
    if (files == null) return Container();
    return Column(
        children: files.map((f) => buildWishlistFile(context, f)).toList());
  }

  Widget buildFolders(BuildContext context) {
    final currentFolder = context.watch<AddWishlistsBloc>().currentFolder;
    final folders = currentFolder?.folders;
    if (folders == null) return Container();
    return Column(
        children: folders.map((f) => buildWishlistFolder(context, f)).toList());
  }

  Widget buildWishlistFile(BuildContext context, WishlistFile file) {
    final isAdded = context.watch<AddWishlistsBloc>().isAdded(file);
    final theme = LittleLightTheme.of(context);
    return WishlistFileItem(
      file: file,
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: isAdded ? theme.errorLayers : theme.primaryLayers,
                visualDensity: VisualDensity.compact),
            onPressed: () async {
              final provider = context.read<AddWishlistsBloc>();
              await Navigator.push(
                  context,
                  BusyDialogRoute(
                    context,
                    awaitFuture: isAdded
                        ? provider.removeWishlist(file)
                        : provider.addWishlist(file),
                  ));
            },
            child: isAdded ? const Text("Remove") : const Text("Add"))
      ],
    );
  }

  Widget buildWishlistFolder(BuildContext context, WishlistFolder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.secondary,
          child: InkWell(
              onTap: () {
                context.read<AddWishlistsBloc>().goToFolder(folder);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8).copyWith(right: 16),
                        child: const Icon(FontAwesomeIcons.solidFolder)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            folder.name!,
                            style: Theme.of(context).textTheme.button,
                          ),
                          Text(
                            folder.description!,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))),
    );
  }

  @override
  bool get wantKeepAlive => mounted;
}
