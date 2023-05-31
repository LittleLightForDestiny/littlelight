import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/widgets/dialogs/busy.dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AddCustomWishlistForm extends StatefulWidget {
  @override
  _AddCustomWishlistFormState createState() => _AddCustomWishlistFormState();
}

enum ImportType { Link, File }

class _AddCustomWishlistFormState extends State<AddCustomWishlistForm> with WishlistsConsumer {
  bool loadingError = false;
  WishlistFile? wishlistFile;
  final Map<String, TextEditingController> fieldControllers = {};
  TextEditingController? get urlController => fieldControllers["URL"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16) + MediaQuery.of(context).viewPadding.copyWith(top: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          buildInfo(context),
          Container(
            height: 16,
          ),
          buildTextField(context, "URL", maxLength: null, onInput: () {
            setState(() {});
          }),
          Container(height: 16),
          ElevatedButton(
            onPressed: isURLValid ? () => loadWishlist() : null,
            child: Text("Load wishlist".translate(context)),
          ),
          Container(
            height: 8,
          ),
          if (loadingError) buildErrorMessage(),
          if (wishlistFile != null) buildWishlistInfoFields(),
        ]));
  }

  Widget buildErrorMessage() {
    return Container(
      decoration: BoxDecoration(
        color: LittleLightTheme.of(context).errorLayers,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(FontAwesomeIcons.exclamationCircle),
        ),
        Expanded(
            child: Text(
                "Error loading wishlist file. Please make sure you're pointing to a raw json file using the Little Light wishlist format"
                    .translate(context)))
      ]),
    );
  }

  Widget buildWishlistInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildTextField(context, "Name",
            maxLength: 50,
            initialValue: wishlistFile?.name ?? wishlistFile?.url?.split('/').last ?? "Untitled Wishlist"),
        buildTextField(context, "Description",
            maxLength: 300, multiline: true, initialValue: wishlistFile?.description ?? ""),
        Container(height: 16),
        ElevatedButton(
          onPressed: () => addWishlist(),
          child: Text("Add wishlist".translate(context)),
        ),
      ],
    );
  }

  bool get isURLValid => urlController?.text.startsWith(RegExp('http?s://')) ?? false;

  void loadWishlist() async {
    final url = urlController?.text;
    if (url == null) return;
    final validWishlist =
        await Navigator.push(context, BusyDialogRoute(context, awaitFuture: wishlistsService.loadWishlistFromUrl(url)));
    wishlistFile = validWishlist;
    loadingError = wishlistFile == null;
    fieldControllers["Name"]?.text = wishlistFile?.name ?? "";
    fieldControllers["Description"]?.text = wishlistFile?.description ?? "";
    setState(() {});
  }

  void addWishlist() async {
    final wishlist = wishlistFile?.copyWith(
      name: fieldControllers["Name"]?.value.text,
      description: fieldControllers["Description"]?.value.text,
    );
    if (wishlist == null) return;
    await Navigator.push(context, BusyDialogRoute(context, awaitFuture: wishlistsService.addWishlist(wishlist)));
    await Future.delayed(const Duration(milliseconds: 10));
    Navigator.pop(context);
  }

  onLinkClick(LinkableElement link) {
    launch(link.url, forceSafariVC: true);
  }

  Widget buildInfo(BuildContext context) {
    return Column(
      children: [
        Text("To create your own wishlists, please check:".translate(context), textAlign: TextAlign.center),
        Container(
          height: 8,
        ),
        Linkify(
          text: "https://wishlists.littlelight.club",
          linkStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          onOpen: onLinkClick,
        ),
        Container(
          height: 8,
        ),
        Text(
          "To use these wishlists on Little Light, you will need to export them as json and publish it somewhere (github.com for example), and then paste the url to raw file on the field below:"
              .translate(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildTextField(BuildContext context, String label,
      {String? initialValue, int? maxLength = 50, bool multiline = false, void Function()? onInput}) {
    var controller = fieldControllers[label];
    if (controller == null) {
      controller = fieldControllers[label] = TextEditingController(
        text: initialValue,
      );
      if (onInput != null) {
        controller.addListener(() {
          onInput();
        });
      }
    }
    return TextField(
      maxLines: multiline ? null : 1,
      maxLength: maxLength,
      autocorrect: false,
      controller: controller,
      decoration: InputDecoration(labelText: context.translate(label)),
    );
  }
}
