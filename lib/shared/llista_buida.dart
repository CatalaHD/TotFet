import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LlistaBuida extends StatelessWidget {
  LlistaBuida({this.missatge, @required this.esTaronja});
  final String missatge;
  final bool esTaronja;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 250,
          child: SvgPicture.asset(
            esTaronja ? "images/empty_tasques.svg" : "images/empty.svg",
            alignment: Alignment.topCenter,
            placeholderBuilder: (context) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCubeGrid(
                    color: esTaronja ? Colors.deepOrange : Colors.blue,
                    size: 100,
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Text(
          missatge ?? "Aquí no hi ha res...",
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
