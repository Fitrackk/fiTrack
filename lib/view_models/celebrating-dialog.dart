import 'package:flutter/material.dart';
import '../views/celebrating-dialog.dart';

void showCelebratingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => const CelebratingDialog(),
  );
}
