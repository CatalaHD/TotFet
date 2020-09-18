import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totfet/models/Finestra.dart';
import 'package:totfet/pages/accounts/profile.dart';
import 'package:totfet/pages/menu_principal.dart';
import 'package:totfet/pages/tasques/carregar_BD_tasques.dart';
import 'package:totfet/shared/some_error_page.dart';
import 'package:totfet/models/Usuari.dart';
import 'package:totfet/pages/accounts/Authenticate.dart';
import 'package:totfet/pages/compres/carregar_BD.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  Finestra finestra = Finestra.Menu;

  void canviarFinestra(Finestra nova) {
    if (nova != finestra) {
      // Si cliquem el botó de la mateixa finestra,
      // No fem res (més optimitzat)
      setState(() {
        finestra = nova;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Usuari>(context);

    if (user == null) {
      // Si no hi ha un usuari autentificat, mostra la pagina
      return Authenticate();
    } else {
      // Si hi ha algun usuari dins, mirem la finestra que volem
      if (finestra == Finestra.Menu)
        return MenuPrincipal(canviarFinestra: canviarFinestra);
      else if (finestra == Finestra.Compres)
        return CarregarBD(canviarFinestra: canviarFinestra);
      else if (finestra == Finestra.Perfil)
        return Perfil(canviarFinestra: canviarFinestra);
      else if (finestra == Finestra.Tasques)
        return Tasques(canviarFinestra: canviarFinestra);
      else
        return SomeErrorPage(error: "No s'ha trobat la pàgina!");
    }
  }
}
