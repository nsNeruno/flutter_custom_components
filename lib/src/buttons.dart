import 'package:flutter/material.dart';

class SFBackButton extends StatelessWidget {

  final Icon icon;
  final Color color;
  final VoidCallback onPressed;

  SFBackButton({
    Key key,
    this.icon,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      key: key,
      icon: icon ?? BackButtonIcon(),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}