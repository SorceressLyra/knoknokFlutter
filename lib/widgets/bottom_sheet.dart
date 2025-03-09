import 'package:flutter/material.dart';

class KnoknokBottomSheet extends StatefulWidget {
  final Widget Function(BuildContext)? builder;

  const KnoknokBottomSheet({super.key, this.builder});

  @override
  KnoknokBottomSheetState createState() => KnoknokBottomSheetState();
}

class KnoknokBottomSheetState extends State<KnoknokBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: widget.builder != null ? widget.builder!(context) : Container(),
    );
  }
}
