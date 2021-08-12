import 'package:dnro/service/UsuarioService.dart';
import 'package:flutter/material.dart';

class Premio {

  int id;
  int valor;
  bool ativo;
  int usuarioId;
  DateTime dataAtivacao;
  bool isBanner;

  Premio(this.id, this.valor, {this.ativo: false, this.usuarioId, this.dataAtivacao, this.isBanner = false});

  String get status {
    if(this.ativo) {
      return 'RESGATAR';
    } else {
      if(this.usuarioId == null) {
        return 'EM ESPERA';
      } else {
        if(this.usuarioId == UsuarioService.usuarioLogado.id) {
          return 'RESGATADO';
        } else {
          return 'INDISPONÍVEL';
        }
        
      }
      
    }
  }

  Color get color {

    if(!this.ativo)  {
      return Colors.grey.shade700;
    } else {
      return Colors.yellow[600];
    }
  }

  List<Color> get gradient {

    if(!this.ativo) {
      return [Colors.grey, Colors.grey.shade700];
    } else {
      return [
          Colors.yellow[600],
          Colors.yellow[800],
      ];
    }
  }
}
