import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/modules/initial/pages/main/initial.bloc.dart';
import 'package:little_light/pages/initial/notifiers/select_wishlists.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:provider/provider.dart';

class SelectWishlistsSubPage extends StatefulWidget {
  const SelectWishlistsSubPage();

  @override
  SelectWishlistsSubPageState createState() => SelectWishlistsSubPageState();
}

class SelectWishlistsSubPageState extends SubpageBaseState<SelectWishlistsSubPage> {
  @override
  void initState() {
    super.initState();
    context.read<SelectWishlistNotifier>().getFeaturedWishlists();
  }

  @override
  Widget buildTitle(BuildContext context) => Text(
        "Select Wishlists".translate(context),
        key: const Key("title"),
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [buildWishlistsContent(context), buildProceedButton(context)],
      ));

  Widget buildWishlistsContent(BuildContext context) {
    final root = context.watch<SelectWishlistNotifier>().isRootFolder;
    if (root) {
      return buildWishlistsRootContent(context);
    }
    return buildWishlistsFolderContent(context);
  }

  Widget buildProceedButton(BuildContext context) {
    final count = context.watch<SelectWishlistNotifier>().selectedCount;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(8),
        child: Text(
            "{count} wishlists selected".translate(
              context,
              replace: {"count": "$count"},
            ),
            key: Key("select_count_$count")),
      ),
      ElevatedButton(
          onPressed: () async {
            await context.read<SelectWishlistNotifier>().saveSelections();
            context.read<InitialPageStateNotifier>().wishlistsSelected();
          },
          child:
              Text(count == 0 ? "I don't want weapon recommendations".translate(context) : "Done".translate(context)))
    ]);
  }

  Widget buildWishlistsRootContent(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: max(240, MediaQuery.of(context).size.height - 300)),
        child: SingleChildScrollView(
            child: Container(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildDescription(context),
            buildWishlists(context),
            buildFolders(context),
          ],
        ))));
  }

  Widget buildWishlistsFolderContent(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: max(240, MediaQuery.of(context).size.height - 300)),
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
    final folder = context.watch<SelectWishlistNotifier>().currentFolder;
    return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            BackButton(
              onPressed: () {
                context.read<SelectWishlistNotifier>().goToRoot();
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
                  style: context.textTheme.button,
                ),
                Container(height: 4),
                Text(
                  folder.description!,
                  style: context.textTheme.caption,
                ),
              ],
            ))
          ],
        ));
  }

  Widget buildDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 16),
      child: Column(
        children: [
          Text(
            "Wishlists are perk recommendations from community buildcrafters that may help you decide on what to shard or keep, by showing good/godroll crests on your weapons and perks, for both PvE and PvP."
                .translate(context),
          ),
          Text(
            "You can add bundles from multiple curators or pick specific seasons from each one of them and mix and match to your liking."
                .translate(context),
          ),
          Text(
            "These selections can be changed later through the settings menu, and you can see which wishlist matches each weapon through weapon details or collections."
                .translate(context),
          ),
          Text(
            "Please remember that these recommendations are based on personal choices and some may fit your playstyle more than others."
                .translate(context),
          ),
        ],
      ),
    );
  }

  Widget buildWishlists(BuildContext context) {
    final currentFolder = context.watch<SelectWishlistNotifier>().currentFolder;
    final files = currentFolder?.files;
    if (files == null) return Container();
    return Column(children: files.map((f) => buildWishlistFile(context, f)).toList());
  }

  Widget buildFolders(BuildContext context) {
    final currentFolder = context.watch<SelectWishlistNotifier>().currentFolder;
    final folders = currentFolder?.folders;
    if (folders == null) return Container();
    return Column(children: folders.map((f) => buildWishlistFolder(context, f)).toList());
  }

  Widget buildWishlistFile(BuildContext context, WishlistFile file) {
    bool checked = context.watch<SelectWishlistNotifier>().isChecked(file);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
          borderRadius: BorderRadius.circular(8),
          color: context.theme.secondarySurfaceLayers.layer1,
          child: InkWell(
              onTap: () {
                context.read<SelectWishlistNotifier>().toggleChecked(file);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8).copyWith(right: 16),
                        child: Icon(checked ? FontAwesomeIcons.squareCheck : FontAwesomeIcons.square)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            file.name!,
                            style: context.textTheme.button,
                          ),
                          Text(
                            file.description!,
                            style: context.textTheme.caption,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))),
    );
  }

  Widget buildWishlistFolder(BuildContext context, WishlistFolder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
          borderRadius: BorderRadius.circular(8),
          color: context.theme.secondarySurfaceLayers.layer1,
          child: InkWell(
              onTap: () {
                context.read<SelectWishlistNotifier>().goToFolder(folder);
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
                            style: context.textTheme.button,
                          ),
                          Text(
                            folder.description!,
                            style: context.textTheme.caption,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}
