import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compres/services/auth.dart';

class Llista {
  String id;
  String nom;
  String descripcio;
  String idCreador;

  Llista({
    @required this.id,
    @required this.nom,
    this.idCreador,
    this.descripcio,
  });

  Map<String, String> toDBMap() {
    return {
      "nom": nom,
      "descripcio": descripcio,
      "idCreador": idCreador,
    };
  }

  static Llista fromDB(QueryDocumentSnapshot doc) {
    return Llista(
      id: doc.id,
      nom: doc.data()['nom'] ?? "No disponible",
      descripcio:
          doc.data()['descripcio'] == "" ? null : doc.data()['descripcio'],
      idCreador: doc.data()['idCreador'],
    );
  }

  // Retorna un mapa de ID llista - Nom llista
  static List<Map<String, String>> llistaPairs(List<Llista> list) {
    List<Map<String, String>> llistaFinal = [];
    for (Llista l in list) {
      llistaFinal.add({
        "id": l.id,
        "nom": l.nom,
      });
    }
    return llistaFinal;
  }

  static Llista nova() {
    return Llista(
      id: null,
      nom: null,
      descripcio: null,
      idCreador: AuthService().userId,
    );
  }
}