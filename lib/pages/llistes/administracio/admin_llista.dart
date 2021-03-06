import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totfet/models/Finestra.dart';

import 'package:totfet/pages/llistes/administracio/expulsar_llista.dart';
import 'package:totfet/pages/llistes/administracio/QR/qr_viewer.dart';
import 'package:totfet/pages/llistes/administracio/canvar_host.dart';
import 'package:totfet/pages/llistes/administracio/detalls_llista.dart';
import 'package:totfet/models/Llista.dart';
import 'package:totfet/pages/llistes/administracio/editar_llista.dart';
import 'package:totfet/services/auth.dart';
import 'package:totfet/services/database.dart';
import 'package:totfet/shared/llista_buida.dart';
import 'package:totfet/shared/loading.dart';
import 'package:totfet/shared/some_error_page.dart';

class AdminLlistes extends StatefulWidget {
  @override
  _AdminLlistesState createState() => _AdminLlistesState();
}

class _AdminLlistesState extends State<AdminLlistes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administrador de llistes"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.blue[400],
                Colors.blue[900],
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
          stream: DatabaseService().getLlistesUsuarisData(AuthService().userId),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return SomeErrorPage(error: snapshot.error);
            }

            if (snapshot.hasData) {
              if (snapshot.data.docs.length == 0) {
                return LlistaBuida(
                  esTaronja: false,
                );
              }
              // Si hi ha dades i no estan buides, mostrem la llista
              return montarLlista(snapshot.data.docs);
            }

            return Loading(
              msg: "Carregant les llistes (1/2)...",
              esTaronja: false,
            );
          }),
    );
  }

  StreamBuilder<QuerySnapshot> montarLlista(
      List<QueryDocumentSnapshot> idLlistes) {
    List<String> llistaIDs = idLlistes
        .map(
          (e) => e.data()['llista'].toString(),
        )
        .toList();

    return StreamBuilder(
      stream: DatabaseService().getLlistesInData(llistaIDs),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return SomeErrorPage(error: snapshot.error);
        }

        if (snapshot.hasData) {
          List<Llista> llistes =
              snapshot.data.docs.map((e) => Llista.fromDB(e)).toList();

          PopupMenuButton<int> construirDesplegable(
              bool isOwner, Llista llista) {
            final List<Map<String, dynamic>> opcionsOwner = [
              {
                "nom": "Editar",
                "icon": Icon(Icons.edit),
                "function": () async {
                  Llista resultat = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditarLlista(llista: llista),
                    ),
                  );
                  // Actualitzar la llista a la BD
                  if (resultat != null) {
                    await DatabaseService().updateLlista(resultat);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Has editat la llista correctament!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    print("Llista editada correctament!");
                  }
                },
              },
              {
                "nom": "Canviar Host",
                "icon": Icon(Icons.face),
                "function": () async {
                  String resultat = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CanviarHost(
                        idLlista: llista.id,
                      ),
                    ),
                  );
                  if (resultat != null) {
                    await DatabaseService().setHost(llista.id, resultat);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "S'ha cambiat el host de la llista correctament!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    print("S'ha canviat de host correctament!");
                  }
                },
              },
              {
                "nom": "Expulsar",
                "icon": Icon(Icons.gavel),
                "function": () async {
                  String resultat = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExpulsarDeLlista(
                        idLlista: llista.id,
                      ),
                    ),
                  );
                  if (resultat != null) {
                    await DatabaseService()
                        .sortirUsuarideLlista(llista.id, resultat);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Has expulsat a l'usuari de la llista correctament!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    print("Usuari Expulsat correctament");
                  }
                },
              },
              {
                "nom": "Esborrar",
                "icon": Icon(Icons.delete_forever),
                "function": () async {
                  bool esborrar = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Vols esborrar la llista DEFINITIVAMENT?'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                'Aquesta acció esborrarà totes les compres assignades a aquesta llista, farà fora a tothom i finalment, esborrarà la informació de la llista.\nAQUESTA ACCIÓ NO ES POT DESFER!',
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Cancel·lar',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              'ESBORRAR DEFINITIVAMENT',
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (esborrar == true) {
                    await DatabaseService().esborrarLlista(llista.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Has esborrat la llista correctament!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    print("Llista esborrada correctament");
                  }
                },
              },
              {
                "nom": "Esborrar Comprats",
                "icon": Icon(Icons.remove_shopping_cart),
                "function": () async {
                  bool esborrar = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                            'Vols esborrar totes les compres completades de la llista?'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                'Aquesta acció esborrarà totes les compres completades d\'aquesta llista.\nAQUESTA ACCIÓ NO ES POT DESFER!',
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Cancel·lar',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              'ESBORRAR',
                              style: TextStyle(fontSize: 20, color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (esborrar == true) {
                    await DatabaseService().esborrarCompratsLlista(llista.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("S'han esborrat les compres correctament!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    print("Compres completades esborrades correctament");
                  }
                },
              },
            ];
            final List<Map<String, dynamic>> opcionsNormal = [
              {
                "nom": "Sortir",
                "icon": Icon(Icons.exit_to_app),
                "function": () async {
                  // Show alert box
                  bool sortir = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Vols sortir de la llista?'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(
                                'Pots tornar-te a unir amb el codi',
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Cancel·lar',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              'Sortir',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  // Si sortir és null o false, llavors no es fa res
                  if (sortir == true) {
                    await DatabaseService()
                        .sortirUsuarideLlista(llista.id, AuthService().userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Has sortit de la llista correctament!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return print(
                      "L'usuari ha sortit correctament de la llista!",
                    );
                  }
                },
              },
            ];

            List<Map<String, dynamic>> opcions =
                isOwner ? opcionsOwner : opcionsNormal;

            return PopupMenuButton<int>(
              tooltip: "Opcions de la llista",
              icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) {
                return opcions
                    .map(
                      (Map<String, dynamic> opcio) => PopupMenuItem(
                        value: opcions.indexOf(opcio),
                        child: Row(
                          children: [
                            opcio['icon'],
                            SizedBox(width: 5),
                            Text(opcio['nom']),
                          ],
                        ),
                      ),
                    )
                    .toList();
              },
              onSelected: (int index) {
                return opcions[index]['function']();
              },
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: llistes.length,
            itemBuilder: (context, index) {
              Llista llista = llistes[index];
              bool isOwner = AuthService().userId == llista.idCreador;
              return Card(
                child: ListTile(
                  onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("ID: ${llista.id}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LlistaDetalls(
                          llista: llista,
                          isOwner: isOwner,
                          finestra: Finestra.Perfil,
                        ),
                      ),
                    );
                  },
                  leading: IconButton(
                    tooltip:
                        "Ensenya el codi QR als teus amics per poder convidar-los!",
                    icon: Icon(
                      Icons.qr_code,
                      size: 32,
                      semanticLabel: "Escaneja el codi QR de la llista",
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QRViewer(
                            id: llista.id,
                            nom: llista.nom,
                            finestra: Finestra.Perfil,
                          ),
                        ),
                      );
                    },
                  ),
                  contentPadding: EdgeInsets.all(3),
                  title: Center(
                    child: Text(
                      llista.nom,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: (llista.descripcio != null)
                      ? Center(
                          child: Text(llista.descripcio),
                        )
                      : null,
                  trailing: construirDesplegable(isOwner, llista),
                ),
              );
            },
          );
        }

        // si encara no te dades, mostrem la pagina de carregant
        return Scaffold(
          body: Loading(
            msg: "Carregant les llistes (2/2)...",
            esTaronja: false,
          ),
        );
      },
    );
  }
}
