import 'package:flutter/material.dart';

class KnoknokBottomSheet extends StatefulWidget {
  final Widget Function(BuildContext)? builder;
  final String? title;

  const KnoknokBottomSheet({super.key, this.builder, this.title});

  @override
  KnoknokBottomSheetState createState() => KnoknokBottomSheetState();
}

class KnoknokBottomSheetState extends State<KnoknokBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16.0, top: 16.0),
                child: Text(
                  widget.title!,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: widget.builder != null ? widget.builder!(context) : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
