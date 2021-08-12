import 'package:dnro/screens/redefinir_senha.dart';
import '../service/UsuarioService.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../screens/home_screen.dart';

class ValidarScreen extends StatefulWidget {
  static final route = '/validar';

  @override
  _ValidarScreenState createState() => _ValidarScreenState();
}

class _ValidarScreenState extends State<ValidarScreen> {
  UsuarioService usuarioService = UsuarioService();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String codigoValidacao;
  Usuario usuario;

  void _showToast(BuildContext context, final String mensagem) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  _reenviarEmail(context) {
    setState(() {
      _formKey.currentState.reset();
      this.codigoValidacao = null;
    });

    usuarioService.reenviarEmail(this.usuario.email).then((sendRes) {
      if (sendRes) {
        _showToast(context, 'E-mail reenviado');
      } else {
        _showToast(context, 'Não foi reenviar o e-mail, tente mais tarde');
      }
    }).catchError((err) {
      _showToast(context, 'Não foi reenviar o e-mail, tente mais tarde');
    });
  }

  _validarCodigo() {
    _formKey.currentState.save();

    if (this.codigoValidacao == null) {
      return;
    }

    Usuario usuarioParaValidar = new Usuario();
    bool redefinicaoSenha = false;

    // Verificando se o usuário vem da tela de redefinição de senha ou de novo usuário
    if (UsuarioService.usuarioLogado != null &&
        UsuarioService.usuarioLogado.email != null) {
      UsuarioService.usuarioLogado.codigoValidacao = this.codigoValidacao;
      usuarioParaValidar = UsuarioService.usuarioLogado;
    } else {
      usuarioParaValidar = usuario;
      usuarioParaValidar.codigoValidacao = this.codigoValidacao;
      redefinicaoSenha = true;
    }

    this
        .usuarioService
        .validar(usuarioParaValidar, redefinicaoSenha)
        .then((value) {
      if (value) {
        if (redefinicaoSenha) {
          Navigator.pushNamed(context, RedefinirSenha.route,
              arguments: {'usuario': usuarioParaValidar});
        } else {
          Navigator.popUntil(context, ModalRoute.withName(MyHomePage.route));
          Navigator.pushNamed(context, MyHomePage.route,
              arguments: {'usuario': usuarioParaValidar});
          return;
        }
      } else {
        _showToast(context, 'Não foi possível validar esse código');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Usuario> mapArgument =
        ModalRoute.of(context).settings.arguments as Map<String, Usuario>;
    this.usuario = mapArgument['usuario'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Validar'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(
            top: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Um código de verificação foi enviado para seu e-mail. informe o código para validação.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Código',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _reenviarEmail(context);
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ),
                onSaved: (value) {
                  this.codigoValidacao = value;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _validarCodigo,
        label: Text('Validar'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
