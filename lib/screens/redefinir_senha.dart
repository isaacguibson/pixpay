import 'package:dnro/models/usuario.dart';
import 'package:dnro/screens/auth_screen.dart';
import 'package:dnro/service/UsuarioService.dart';
import 'package:flutter/material.dart';

class RedefinirSenha extends StatefulWidget {
  static final String route = '/redefinir-senha';

  @override
  _RedefinirSenhaState createState() => _RedefinirSenhaState();
}

class _RedefinirSenhaState extends State<RedefinirSenha>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UsuarioService usuarioService = UsuarioService();
  String senha;
  String senhaCopia;
  bool isLoading = false;
  Usuario usuario;

  void _showToast(BuildContext context, final String mensagem) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  _redefinirSenha(BuildContext context) {
    _formKey.currentState.save();

    if (this.senha == null || this.senha == '') {
      _showToast(context, 'A senha não pode estar vazia');
      return;
    }
    if(this.senha != this.senhaCopia) {
      _showToast(context, 'As senhas não são iguais');
      return;
    }

    setState(() {
      this.isLoading = true;
    });

    this.usuario.senha = this.senha;
    this.usuarioService.redefinirSenha(usuario).then((value) {
      setState(() {
        this.isLoading = false;
      });
      if (value) {
        _showToast(context, 'Senha redefinida');
        Navigator.popUntil(context, ModalRoute.withName(AuthScreen.route));
        Navigator.pushNamed(context, AuthScreen.route);
      } else {
        _showToast(context, 'Não foi possível redefinir a senha');
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    Map<String, Usuario> mapArgument = ModalRoute.of(context).settings.arguments as Map<String, Usuario>;
    this.usuario = mapArgument['usuario'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Redefinir Senha'),
      ),
      body: this.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
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
                      'Digite sua nova senha',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSaved: (value) {
                        this.senha = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Repetir senha',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSaved: (value) {
                        this.senhaCopia = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {_redefinirSenha(context)},
        label: Text('Enviar'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
