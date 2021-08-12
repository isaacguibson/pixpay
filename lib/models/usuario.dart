
class Usuario {

  int id;
  String email;
  String senha;
  int tipoPix;
  String pix;
  String token;
  bool primeiroLogin;
  String codigoValidacao;

  Usuario();

  factory Usuario.fromJson(Map<String, dynamic> json) {

    Usuario usuario = Usuario();
    if(json['id'] != null) {
      usuario.id = json['id'];
    }
    if(json['email'] != null) {
      usuario.email = json['email'];
    }
    if(json['senha'] != null) {
      usuario.senha = json['senha'];
    }
    if(json['tipoPix'] != null) {
      usuario.tipoPix = json['tipoPix'];
    }
    if(json['pix'] != null) {
      usuario.pix = json['pix'];
    }
    if(json['token'] != null) {
      usuario.token = json['token'];
    }
    
    if(json['primeiroLogin'] != null) {
      if(json['primeiroLogin'] is int) {
        if(json['primeiroLogin'] > 0) {
          usuario.primeiroLogin = true;
        } else {
          usuario.primeiroLogin = false;
        }  
      } else if (json['primeiroLogin'] is bool) {
        if(json['primeiroLogin']) {
          usuario.primeiroLogin = true;
        } else {
          usuario.primeiroLogin = false;
        }
      }
    }
    if(json['codigoValidacao'] != null) {
      usuario.codigoValidacao = json['codigoValidacao'];
    }
    return usuario;
  }

}