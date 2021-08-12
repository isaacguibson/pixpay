import '../models/premio.dart';
import '../constantes/constantes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PremioService {

  Future<String> resgatar(int usuarioId, int premioId) async {

    String msg;
    await SharedPreferences.getInstance().then((prefs) async {
      final response = await http.post(Uri.parse(Constantes.ENDPOINT_RESGATE),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': prefs.getString('token')
      },body: jsonEncode(<String, Object> {
        'id_usuario': usuarioId,
        'id_premio': premioId,
      }));

      if (response.statusCode == 200) {
        msg = null;
      } else {
        msg = jsonDecode(response.body)['mensagem'];
      }
    });
    
    return msg;
  }

  Future<List<Premio>> obterTodos() async {
    List<Premio> premios = [];
    await SharedPreferences.getInstance().then((prefs) async {
      final response = await http.get(Uri.parse(Constantes.ENDPOINT_PREMIOS),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': prefs.getString('token')
      });
      if (response.statusCode == 200) {
        premios = [];
        premios = converterListaResposta(jsonDecode(response.body));
        return premios;
      } else if(response.statusCode == 401){
        return null;
      } else {
        return jsonDecode(response.body)['mensagem'];
      }
    }).catchError((err) {
      return premios;
    });

    return premios;
  }

  converterListaResposta(List<dynamic> json) {
    Premio premio;
    int id;
    int valor;
    List<Premio> premios = [];

    for (var index = 0; index < json.length; index++){

      if(json[index]['premioId'] != null) {
        id = json[index]['premioId'];
      } else {
        return null;
      }

      if(json[index]['valor'] != null) {
        valor = json[index]['valor'];
      }

      premio = new Premio(id, valor);
      if(json[index]['ativo'] != null) {
        if(json[index]['ativo'] > 0) {
          premio.ativo = true;
        } else {
          premio.ativo = false;
        }      
      }

      if(json[index]['usuarioId'] != null) {
        premio.usuarioId = json[index]['usuarioId'];
        premio.ativo = false;
      }

      if(json[index]['dataAtivacao'] != null) {
        premio.dataAtivacao = DateTime.parse(json[index]['dataAtivacao']);
      }

      premios.add(premio);
    }

    
    return premios;
  }

}