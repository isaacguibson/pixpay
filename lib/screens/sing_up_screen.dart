import '../screens/validar_screen.dart';
import '../service/UsuarioService.dart';
import '../models/usuario.dart';
import 'package:flutter/material.dart';

class SingUp extends StatefulWidget {
  static final String route = '/sing-up';

  @override
  _SingUpState createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  
  Usuario usuario = new Usuario();
  String dropDownValue;
  String senhaRepetida;
  bool isLoading = false;

  void _showToast(BuildContext context, final String mensagem) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  bool _validar(BuildContext context, Usuario usuario) {
    if (usuario.email == null || usuario.email == '') {
      _showToast(context, 'O e-mail deve ser informado');
      return false;
    }
    if (usuario.senha == null || usuario.senha == '') {
      _showToast(context, 'A senha deve ser informada');
      return false;
    } else {
      if (usuario.senha != senhaRepetida) {
        _showToast(context, 'As senhas devem ser iguais');
        return false;
      }
    }
    if (usuario.tipoPix == null || usuario.tipoPix == 0) {
      _showToast(context, 'O tipo de PIX deve ser informado');
      return false;
    }
    if (usuario.pix == null || usuario.pix == '') {
      _showToast(context, 'Sua chave PIX deve ser informada');
      return false;
    }

    return true;
  }

  _submit(BuildContext context) {
    setState(() {
      this.isLoading = true;
    });
    UsuarioService usuarioService = UsuarioService();
    _formKey.currentState.save();
    usuario.tipoPix = usuarioService.tipoPixInteger(dropDownValue);

    if (_validar(context, usuario)) {
      Future<String> resposta = usuarioService.criar(usuario);
      resposta.then((value) {
        setState(() {
          this.isLoading = false;
        });
        if (value == null) {
            Navigator.pushNamed(context, ValidarScreen.route,
                arguments: {'usuario': usuario});
        }
        else {
          _showToast(context, value);
        }
      });
    } else {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry appBarTextPadding = EdgeInsets.all(10);

    List<Widget> formWidgets = [
      TextFormField(
        decoration: InputDecoration(
          labelText: 'E-Mail',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          usuario.email = value;
        },
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Senha',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        obscureText: true,
        onSaved: (value) {
          usuario.senha = value;
        },
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Repita a senha',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        obscureText: true,
        onSaved: (value) {
          senhaRepetida = value;
        },
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
        onChanged: (newValue) {
          setState(() {
            dropDownValue = newValue;
          });
        },
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Código Pix',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onSaved: (value) {
          usuario.pix = value;
        },
      ),
    ];

    return Scaffold(
      body: this.isLoading ? Center(child: CircularProgressIndicator(),) : Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 100.0,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext ctx, BoxConstraints constraints) {
                  return FlexibleSpaceBar(
                    title: Text('Criar conta'),
                    titlePadding: constraints.biggest.height < 100
                        ? EdgeInsetsDirectional.only(start: 50, bottom: 16)
                        : appBarTextPadding,
                  );
                },
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
        onPressed: () {
          _submit(context);
        },
        label: Text('Cadastrar',),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
