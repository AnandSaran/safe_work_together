import 'package:safe_work_together/constants/ImageConstants.dart';
import 'package:flutter/material.dart';
import 'package:safe_work_together/style/theme.dart' as Theme;

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              Theme.Colors.loginGradientStart,
              Theme.Colors.loginGradientEnd
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              ICON_LOGIN_PAGE_TOP,
              width: size.width * 0.3,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              ICON_LOGIN_PAGE_BOTTOM,
              width: size.width * 0.4,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
