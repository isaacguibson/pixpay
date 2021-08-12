import '../models/usuario.dart';
import '../constantes/constantes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {

  static Usuario _usuarioLogado;

  Future<Usuario> doLogin(Usuario usuario){

    return singIn(usuario);
  }

  Future<bool> salvar(Usuario usuario) async {
    await SharedPreferences.getInstance().then((prefs) async {
      final response = await http.put(Uri.parse(Constantes.ENDPOINT_ALTERAR),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': prefs.getString('token')
      },body: jsonEncode(<String, Object> {
        'id': usuario.id,
        'email': usuario.email,
        'tipoPix': usuario.tipoPix,
        'pix': usuario.pix
      }));

      if (response.statusCode == 200) {
        Usuario usuarioRetorno = Usuario.fromJson(jsonDecode(response.body));
        _usuarioLogado.pix = usuarioRetorno.pix;
        _usuarioLogado.tipoPix = usuarioRetorno.tipoPix;
        return true;
      } else if(response.statusCode == 401) {
        _usuarioLogado = null;
        return false;
      } else {
        return false;
      }
    }).catchError((err) {
      return false;
    });

    return false;
  }

  Future<String> criar(Usuario usuario) {
    Usuario novoUsuario = Usuario();

    novoUsuario.email = usuario.email;
    novoUsuario.tipoPix = usuario.tipoPix;
    novoUsuario.pix = usuario.pix;
    novoUsuario.senha = usuario.senha;
    novoUsuario.primeiroLogin = true;

    return singUp(novoUsuario);
  }

  String tipoPixString(int tipoPix) {
    switch (tipoPix) {
      case 1:
        return 'CPF';
      case 2:
        return 'Telefone';
      case 3:
        return 'E-Mail';
      case 4:
        return 'Chave aleatória';
      default:
        return 'CPF';
    }
  }

  int tipoPixInteger(String tipoPix) {
    if (tipoPix == 'CPF') {
      return 1;
    } else if (tipoPix == 'Telefone') {
      return 2;
    } else if (tipoPix == 'E-mail') {
      return 3;
    } else if (tipoPix == 'Chave aleatória') {
      return 4;
    } else {
      return 0;
    }

  }

  static Usuario get usuarioLogado {
    return _usuarioLogado;
  }

  Future<String> singUp(Usuario usuario) async {
    final response = await http.post(Uri.parse(Constantes.ENDPOINT_SINGUP),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, Object> {
      'email': usuario.email,
      'senha': usuario.senha,
      'tipoPix': usuario.tipoPix,
      'pix': usuario.pix
    }));

    if (response.statusCode == 201) {
      _usuarioLogado = Usuario.fromJson(jsonDecode(response.body));
      return null;
    } else {
      return jsonDecode(response.body)['mensagem'];
    }
  }

  Future<Usuario> singIn(Usuario usuario) async {
    final response = await http.post(Uri.parse(Constantes.ENDPOINT_SINGIN),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, Object> {
      'email': usuario.email,
      'senha': usuario.senha
    }));

    if (response.statusCode == 200) {
      _usuarioLogado = Usuario.fromJson(jsonDecode(response.body));
      return _usuarioLogado;
    } else {
      return null;
    }
  }

  Future<bool> validar(Usuario usuario, bool redefinirSenha) async {
    final response = await http.post(Uri.parse(Constantes.ENDPOINT_VALIDAR),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, Object> {
      'email': usuario.email,
      'codigoValidacao': usuario.codigoValidacao
    }));

    if (response.statusCode == 200) {
      if(!redefinirSenha) {
        _usuarioLogado = Usuario.fromJson(jsonDecode(response.body));

        SharedPreferences.getInstance().then((prefs) {
            prefs.setString('token', _usuarioLogado.token);
            prefs.setInt('id', _usuarioLogado.id);
        });
        
      } else {
        _usuarioLogado = new Usuario();
      }
      return true;
    } else {
      return false;
    }
  }

  Future<Map> gerarCodigoValidacao(String email) async {

    final response = await http.post(Uri.parse(Constantes.ENDPOINT_GERAR_COD_VALIDACAO),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, Object> {
      'email': email,
    }));

    Map map = new Map();
    if (response.statusCode == 200) {
      String mensagem = jsonDecode(response.body)['mensagem'];
      map['resultado'] = true;
      map['mensagem'] = mensagem;
    } else {
      String mensagem = jsonDecode(response.body)['mensagem'];
      map['resultado'] = false;
      map['mensagem'] = mensagem;
    }

    return map;
  }


  Future<bool> redefinirSenha(Usuario usuario) async {
    final response = await http.post(Uri.parse(Constantes.ENDPOINT_REDEFINIR_SENHA),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, Object> {
      'email': usuario.email,
      'codigoValidacao': usuario.codigoValidacao,
      'senha': usuario.senha
    }));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Usuario> buscarUsuarioPorId(int id) async {

    Usuario usuario;
    await SharedPreferences.getInstance().then((prefs) async {
      final response = await http.get(Uri.parse(Constantes.ENDPOINT_OBTER_POR_ID + id.toString()),headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-access-token': prefs.getString('token')
      });

      if (response.statusCode == 200) {
        _usuarioLogado = Usuario.fromJson(jsonDecode(response.body));
        usuario = _usuarioLogado;
      } else if(response.statusCode == 401){
        usuario = null;
      } else {
        usuario = new Usuario();
      }
    });

    return usuario;
  }


  Future<String> verificarToken(int id, jwt) async {

    final response = await http.get(Uri.parse(Constantes.ENDPOINT_VERIFICAR_TOKEN+id.toString()),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-access-token': jwt
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<Usuario> resetarUsuarioLogado(SharedPreferences prefs) async {

    String jwt= prefs.getString('token');
    int id = prefs.getInt('id');

    Usuario usuario = new Usuario();
    if(id!=null && jwt != null) {

      await verificarToken(id, jwt).then((token) async {

        if(token == null) {
          usuario = new Usuario();
          _usuarioLogado = usuario;
          return usuario;
        }
        jwt = jsonDecode(token)['token'];
        prefs.setString('token', jwt);
        usuario = new Usuario();

        await buscarUsuarioPorId(id).then((usr) {
          if(usr.id == null) {
            usuario = new Usuario();
          } else {
            usuario = usr;
            usuario.token = jwt;
          }
        }).catchError((err) {
          usuario = new Usuario();
        });
      }).catchError((err) {
        usuario = new Usuario();
        return usuario;
      });
    } else {
      usuario = new Usuario();
    }
    
    _usuarioLogado = usuario;
    return usuario;
     
  }

  Future<bool> deletar(int id) async {

    bool retorno;
    await SharedPreferences.getInstance().then((prefs) async {
      final response = await http.delete(Uri.parse(Constantes.ENDPOINT_DELETAR+id.toString()), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-access-token': prefs.getString('token')
      });

      if (response.statusCode == 200) {
        retorno = true;
      } else {
        retorno = false;
      }
    });

    return retorno;
  }

  Future<bool> reenviarEmail(String email) async {

    bool retorno;
    final response = await http.post(Uri.parse(Constantes.ENDPOINT_REENVIAR_EMAIL), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },body: jsonEncode(<String, Object> {
      'email': email,
    }));

    if (response.statusCode == 200) {
      retorno = true;
    } else {
      retorno = false;
    }

    return retorno;
  }

}