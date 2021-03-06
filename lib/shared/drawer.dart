import 'package:flutter/material.dart';

import 'package:totfet/models/Finestra.dart';
import 'package:totfet/models/Report.dart';
import 'package:totfet/models/Tipus_report.dart';
import 'package:totfet/pages/admin/report_bug.dart';
import 'package:totfet/services/database.dart';
import 'package:totfet/shared/constants.dart';
import 'package:totfet/shared/opcions_page.dart';
import 'package:totfet/shared/sortir_sessio.dart';

class MyDrawer extends StatelessWidget {
  final Function canviarFinestra;
  final Finestra actual;
  MyDrawer({this.canviarFinestra, this.actual});

  bool escenaActual(Finestra finestra) {
    return finestra != actual;
  }

  final Color color = Colors.grey[100];
  final Color disabledColor = Colors.grey[200];
  final Color disabledTextColor = Colors.blue[400];

  final LinearGradient gradient = LinearGradient(colors: [
    Colors.blue[900],
    Colors.blue[400],
  ]);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: "Calaix on es guarden totes les opcions importants.",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.only(
                  //bottomLeft: const Radius.circular(18.0),
                  bottomRight: const Radius.circular(18.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.dynamic_feed,
                    size: 60,
                    color: Colors.white,
                  ),
                  Text(
                    appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: escenaActual(Finestra.Menu)
                      ? () {
                          canviarFinestra(Finestra.Menu);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(Icons.apps),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Menu Principal"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: escenaActual(Finestra.Compres)
                      ? () {
                          canviarFinestra(Finestra.Compres);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Les meves Compres"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                RaisedButton(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: escenaActual(Finestra.Tasques)
                      ? () {
                          canviarFinestra(Finestra.Tasques);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(Icons.assignment),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Les meves Tasques"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                Divider(),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: escenaActual(Finestra.Perfil)
                      ? () {
                          canviarFinestra(Finestra.Perfil);
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(
                        width: 20,
                      ),
                      Text("El meu Perfil"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                SortirSessio(),
                Divider(),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => OpcionsPage())),
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Configuració"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: () async {
                    // Mostrar la pàgina de report que retorna un report o null
                    Report report = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportBug(),
                      ),
                    );
                    // Afegir el report a la taula de reports.
                    if (report != null) {
                      await DatabaseService().afegirReport(report);
                      print("Informe enviat correctament!");
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text("L'informe s'ha enviat correctament."),
                            children: [
                              Text(tipusReportDescripcio(report.tipus))
                            ],
                            contentPadding: EdgeInsets.all(24),
                          );
                        },
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.bug_report),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Informa d'un error"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  disabledTextColor: disabledTextColor,
                  disabledColor: disabledColor,
                  color: color,
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon:
                          Image.asset("images/favicon.png", height: 50),
                      applicationName: appName,
                      applicationVersion: versionNumber,
                      applicationLegalese:
                          'Desenvolupat per $appCreator\n\nCC0 SVG Icons by unDraw',
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.help),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Més info"),
                      Expanded(
                        child: Container(),
                      ),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text("$appName © ${DateTime.now().year} $appCreator"),
                Text("Versió $versionNumber"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
