import 'package:dnro/models/usuario.dart';
import 'package:dnro/screens/validar_screen.dart';
import 'package:dnro/service/UsuarioService.dart';
import 'package:flutter/material.dart';

class EmailScreen extends StatefulWidget {
  static final route = '/email';

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UsuarioService usuarioService = UsuarioService();
  String email;
  bool isLoading = false;

  void _showToast(BuildContext context, final String mensagem) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  _gerarCodigo(BuildContext context) {
    _formKey.currentState.save();

    if (this.email == null || this.email == '') {
      _showToast(context, 'A email não pode estar vazio');
      return;
    }
    setState(() {
      this.isLoading = true;
    });

    this.usuarioService.gerarCodigoValidacao(email).then((value) {
      setState(() {
        this.isLoading = false;
      });
      if (value['resultado']) {
        Usuario usuario = new Usuario();
        usuario.email = email;
        _showToast(context, value['mensagem']);
        Navigator.pushNamed(context, ValidarScreen.route,
            arguments: {'usuario': usuario});
      } else {
        _showToast(context, value['mensagem']);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      'Digite o e-mail da conta que deseja redefinir a senha.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSaved: (value) {
                        this.email = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {_gerarCodigo(context)},
        label: Text('Enviar'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
