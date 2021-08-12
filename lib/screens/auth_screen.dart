import 'package:dnro/screens/validar_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home_screen.dart';
import '../service/UsuarioService.dart';
import '../models/usuario.dart';
import '../forms/login_form.dart';

class AuthScreen extends StatefulWidget {
  static final String route = '/sing-in';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  UsuarioService usuarioService = UsuarioService();
  Usuario usuario = Usuario();
  bool isLoading = true;
  SharedPreferences prefs;

  final GlobalKey<FormState> _formKey = GlobalKey();

  _login() {
    setState(() {
      this.isLoading = true;
    });

    _formKey.currentState.save();
    usuarioService.doLogin(usuario).then((value) {
      setState(() {
        this.isLoading = false;
      });
      if (value != null) {
        if (prefs != null) {
          prefs.setInt('id', value.id);
          prefs.setString('token', value.token);
        }

        if (value.primeiroLogin) {
          Navigator.pushNamed(context, ValidarScreen.route,
              arguments: {'usuario': this.usuario});
          return;
        } else {
          Navigator.pop(context);
          Navigator.pushNamed(context, MyHomePage.route);
          return;
        }
      } else {
        _mostratMensagemLogin();
        return;
      }
    });
  }

  _mostratMensagemLogin() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Não foi possível realizar o login, por favor, tente novamente.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print('AQUI0');
    getSharedPreferences().then((value) {
      prefs = value;
      usuarioService.resetarUsuarioLogado(prefs).then((usr) {
        setState(() {
          this.isLoading = false;
        });

        if (usr.id == null) {
          this.usuario = new Usuario();
        } else {
          this.usuario = usr;
          prefs.setInt('id', usr.id);
          prefs.setString('token', usr.token);

          Navigator.pop(context);
          Navigator.pushNamed(context, MyHomePage.route);
        }
      }).catchError((err) {
        this.usuario = new Usuario();
        setState(() {
          this.isLoading = false;
        });
      });
    }).catchError((err) {
      prefs = null;
      setState(() {
        this.isLoading = false;
      });
    });
  }

  Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    final List<Widget> formWidgets = LoginForm.formWidgets(context, usuario);

    return Scaffold(
      body: this.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: <Widget>[
                  const SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    expandedHeight: 100.0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text('Login'),
                      titlePadding: EdgeInsets.all(10),
                    ),
                  ),
                  SliverFixedExtentList(
                    itemExtent: 100,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(15),
                          child: formWidgets[index],
                        );
                      },
                      childCount: formWidgets.length,
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _login,
        label: Text('Entrar'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
