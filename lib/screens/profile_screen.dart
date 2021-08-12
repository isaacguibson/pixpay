import '../models/usuario.dart';
import '../service/UsuarioService.dart';
import '../screens/home_screen.dart';
import '../screens/auth_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static final String route = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UsuarioService usuarioService = UsuarioService();
  Usuario usuario = Usuario();
  String dropDownValue;
  bool isLoading = true;

  _salvar(BuildContext context) {
    _formKey.currentState.save();
    int codTipoPix = this.usuarioService.tipoPixInteger(dropDownValue);
    this.usuario.tipoPix = codTipoPix;

    if (usuario.id == null) {
      _showToast(context, 'Não foi possível salvar');
      return;
    } else if (usuario.email == null || usuario.email == '') {
      _showToast(context, 'Não foi possível salvar');
      return;
    } else if (usuario.pix == null || usuario.pix == '') {
      _showToast(context, 'O pix não pode ser vazio');
      return;
    } else if (usuario.tipoPix == null) {
      _showToast(context, 'O tipo do pix não pode ser vazio');
      return;
    }

    this.usuarioService.salvar(this.usuario).then((value) {
      if (UsuarioService.usuarioLogado.token == null) {
        Navigator.pop(context);
        Navigator.pushNamed(context, AuthScreen.route);
        return;
      }
      _showToast(context, 'Salvo com sucesso');
      Navigator.pushNamed(context, MyHomePage.route);
    }).catchError((onError) {
      _showToast(context, 'Não foi possível salvar');
      return;
    });
  }

  void _showToast(BuildContext context, final String mensagem) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void initState() {
    super.initState();
    UsuarioService usuarioService = new UsuarioService();
    usuarioService
        .buscarUsuarioPorId(UsuarioService.usuarioLogado.id)
        .then((value) {
      setState(() {
        this.isLoading = false;
      });
      if (value != null) {
        this.usuario = value;
      } else {
        _showToast(context, 'Oops, algo de errado não está certo.');
        Navigator.pop(context);
        Navigator.pushNamed(context, AuthScreen.route);
        return;
      }
      dropDownValue = usuarioService.tipoPixString(this.usuario.tipoPix);
    }).catchError((error) {
      setState(() {
        this.isLoading = false;
      });
      this.usuario = UsuarioService.usuarioLogado;
    });
  }

  _deletarConta(context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext incontext) {
        return AlertDialog(
          title: Text('Atenção'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você está prestes a deletar sua conta.'),
                Text('Essa ação não pode ser desfeita.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continuar'),
              onPressed: () {
                Navigator.of(incontext).pop();

                setState(() {
                  this.isLoading = true;
                });

                usuarioService.deletar(this.usuario.id).then((deleteRes) {
                  setState(() {
                    this.isLoading = false;
                  });
                  if(deleteRes) {
                    Navigator.of(incontext).pop();
                    _showToast(context, 'Conta removida com sucesso');
                    Navigator.popUntil(context, ModalRoute.withName(AuthScreen.route));
                    Navigator.pushNamed(context, AuthScreen.route);
                  } else {
                     Navigator.of(incontext).pop();
                    _showToast(context, 'Não foi possível remover a conta');
                  }
                }).catchError((err) {
                  setState(() {
                    this.isLoading = false;
                    Navigator.of(incontext).pop();
                   _showToast(context, 'Não foi possível remover a conta');
                  });
                });
              },
            ),
            TextButton(
              child: Text('Canclear'),
              onPressed: () {
                Navigator.of(incontext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formWidgets = [
      TextFormField(
        initialValue: UsuarioService.usuarioLogado.email,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'E-Mail',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DropdownButton<String>(
        hint: Text(
          'Selecione um tipo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: dropDownValue,
        underline: Container(
          height: 2,
          color: Colors.black,
        ),
        items: <String>['CPF', 'Telefone', 'E-mail']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            dropDownValue = value;
          });
        },
      ),
      TextFormField(
        initialValue: this.usuario.pix,
        decoration: InputDecoration(
          labelText: 'Código Pix',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onSaved: (value) {
          this.usuario.pix = value;
        },
      ),
    ];

    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Colors.redAccent,
      primary: Colors.redAccent,
      minimumSize: Size(150, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: this.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          formWidgets[0],
                          SizedBox(height: 20),
                          formWidgets[1],
                          SizedBox(height: 20),
                          formWidgets[2],
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: () {_deletarConta(context);},
                    child: Text('Deletar conta', style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),),
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _salvar(context),
        label: Text('Salvar'),
        icon: Icon(Icons.save),
      ),
    );
  }
}
