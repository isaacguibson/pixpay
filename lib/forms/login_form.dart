import 'package:dnro/screens/email_screen.dart';
import 'package:flutter/material.dart';
import '../screens/sing_up_screen.dart';
import '../models/usuario.dart';

class LoginForm {

  static List<Widget> formWidgets(BuildContext context, Usuario usuario) {
    return [
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
      Row(
        children: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, SingUp.route);
            },
            child: Text(
              'Criar nova conta',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, EmailScreen.route);
            },
            child: Text(
              'Esqueci minha senha',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    ];
  }

}