import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:voislate/models/tag_editing_message.dart';

// ignore: must_be_immutable
class TagChips extends StatefulWidget {
  final BuildContext context;
  List<String> tagList;
  TagChips({
    Key? key,
    required this.context,
    required this.tagList,
  }) : super(key: key);

  @override
  State<TagChips> createState() => _TagChipsState();
}

class _TagChipsState extends State<TagChips> {
  var chipList = List<Chip>.empty(growable: true);
  String newObject = '';

  AlertDialog editOrAddTagDialog(TagEditingMessage message) {
    var cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    var confirmButton = TextButton(
      child: Text(message.dialogType),
      onPressed: () {
        message.onConfirm();
        Navigator.of(context).pop();
      },
    );

    var tagEditField = TextField(
      controller: TextEditingController(text: message.tagText),
      onChanged: (value) {
        newObject = value;
      },
    );

    var editingDialog = AlertDialog(
      title: Text('${message.dialogType} Object'),
      content: tagEditField,
      actions: [cancelButton, confirmButton],
    );

    return editingDialog;
  }

  void initChipList() {
    chipList = List<Chip>.empty(growable: true);
    for (int index = 0; index < widget.tagList.length; index++) {
      var object = widget.tagList[index];

      void copyTag(String object) {
        Clipboard.setData(ClipboardData(text: object));
        Fluttertoast.showToast(
          msg: "话筒信息已复制",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      void editTagText() {
        setState(() => widget.tagList[index] = newObject);
      }

      var editDialog = editOrAddTagDialog(TagEditingMessage()
        ..dialogType = 'Edit'
        ..onConfirm = editTagText
        ..tagText = object);
      showEditDialog() => showDialog(
            context: context,
            builder: (BuildContext context) {
              newObject = '';
              return editDialog;
            },
          );

      chipList.add(Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        label: TextButton(
            onLongPress: () {
              copyTag(object);
            },
            onPressed: showEditDialog,
            child: Text(
              object,
              style: const TextStyle(
                fontSize: 14,
              ),
            )),
        onDeleted: () {
          setState(() => widget.tagList.remove(object));
        },
      ));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void addNewTag() {
    setState(() => widget.tagList.add(newObject));
  }

  @override
  Widget build(context) {
    initChipList();
    var addTagDialog = editOrAddTagDialog(TagEditingMessage()
      ..dialogType = 'Add'
      ..onConfirm = addNewTag
      ..tagText = '');
    chipList.add(Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        label: TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              newObject = '';
              return addTagDialog;
            },
          ),
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        )));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chipList
            .map((chip) => Transform.scale(scale: 1, child: chip))
            .toList(),
      ),
    );
  }
}
