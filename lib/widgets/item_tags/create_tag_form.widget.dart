import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';

class CreateTagFormWidget extends StatefulWidget {
  final ItemNotesService service = ItemNotesService();
  final ItemNotesTag tag;
  CreateTagFormWidget(this.tag) : super();
  @override
  _CreateTagFormWidgetState createState() => _CreateTagFormWidgetState();
}

const _availableColors = [
  Colors.grey,
  Colors.blueGrey,
  Colors.red,
  Colors.deepOrange,
  Colors.orange,
  Colors.amber,
  Colors.yellow,
  Colors.lime,
  Colors.lightGreen,
  Colors.green,
  Colors.teal,
  Colors.cyan,
  Colors.lightBlue,
  Colors.blue,
  Colors.indigo,
  Colors.deepPurple,
  Colors.purple,
  Colors.pink,
  Colors.brown,
];

class _CreateTagFormWidgetState extends State<CreateTagFormWidget> with LanguageConsumer{
  List<String> colors;
  String tagNameLabel = "";
  TextEditingController tagNameController;

  @override
  void initState() {
    super.initState();
    tagNameController = TextEditingController(text: widget.tag?.name ?? "");
    initData();
  }

  initData() async {
    colors = [];
    _availableColors.forEach((element) {
      colors.addAll([
        element.shade900,
        element.shade700,
        element.shade500,
        element.shade400,
        element.shade300,
        element.shade100,
      ].map(hexFromColor));
    });

    tagNameLabel = await languageService.getTranslation("Tag name");
    setState(() {});

    tagNameController.addListener(() {
      widget?.tag?.name = tagNameController.text;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      buildPreview(context),
      Expanded(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 16),
          buildNameField(context),
          Container(height: 16),
          TranslatedTextWidget("Background color"),
          buildColors(context, widget?.tag?.backgroundColorHex, (color) {
            widget?.tag?.backgroundColorHex = color;
            setState(() {});
          }, ["#00000000", "#FF000000", "#FFFFFFFF"]),
          Container(height: 16),
          TranslatedTextWidget("Text/icon color"),
          buildColors(context, widget?.tag?.foregroundColorHex, (color) {
            widget?.tag?.foregroundColorHex = color;
            setState(() {});
          }),
          Container(height: 16),
          TranslatedTextWidget("Tag icon"),
          buildIcons(context, widget?.tag?.icon, (icon) {
            widget?.tag?.icon = icon;
            setState(() {});
          })
        ],
      )))
    ]));
  }

  Widget buildPreview(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ItemTagWidget(widget?.tag),
          Container(
            width: 8,
          ),
          Flexible(
              child:
                  ItemTagWidget(widget?.tag, includeLabel: true, padding: 4)),
        ]));
  }

  Widget buildNameField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          labelText: tagNameLabel,
          floatingLabelBehavior: FloatingLabelBehavior.auto),
      controller: tagNameController,
      maxLength: 20,
    );
  }

  Widget buildColors(BuildContext context, String currentColorHex,
      Function(String color) onChange,
      [List<String> additionalColors = const []]) {
    return Container(
        height: 150,
        child: GridView.count(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            crossAxisCount: 3,
            children: additionalColors.followedBy(colors).map((c) {
              return AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 2,
                              color: currentColorHex == c
                                  ? Colors.white
                                  : Colors.transparent)),
                      padding: EdgeInsets.all(3),
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        color: colorFromHex(c),
                        child: InkWell(
                          onTap: () {
                            onChange(c);
                          },
                        ),
                      )));
            }).toList()));
  }

  Widget buildIcons(BuildContext context, ItemTagIcon currentIcon,
      Function(ItemTagIcon icon) onChange) {
    return Container(
        height: 150,
        child: GridView.count(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            crossAxisCount: 3,
            children: ItemTagIcon.values.map((i) {
              return AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 2,
                              color: currentIcon == i
                                  ? Colors.white
                                  : Colors.transparent)),
                      padding: EdgeInsets.all(3),
                      child: Material(
                          borderRadius: BorderRadius.circular(8),
                          color: widget.tag.backgroundColor,
                          child: InkWell(
                            child: Icon(tagIconData[i],
                                color: widget.tag.foregroundColor),
                            onTap: () {
                              onChange(i);
                            },
                          ))));
            }).toList()));
  }
}
