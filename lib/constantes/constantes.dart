class Constantes {

  static const String IP = 'localhost:3000';
  static const String PORT = ''; // 3000
  //AUTH e PROFILE
  static const String ENDPOINT_SINGUP = 'http://'+IP+'/auth/signup';
  static const String ENDPOINT_SINGIN = 'http://'+IP+'/auth/signin';
  static const String ENDPOINT_VALIDAR = 'http://'+IP+'/auth/validarCodigo';
  static const String ENDPOINT_VERIFICAR_TOKEN = 'http://'+IP+'/auth/verificarToken/';
  static const String ENDPOINT_REENVIAR_EMAIL = 'http://'+IP+'/auth/sendemail';
  static const String ENDPOINT_DELETAR = 'http://'+IP+'/profile/deletar/';
  static const String ENDPOINT_GERAR_COD_VALIDACAO = 'http://'+IP+'/profile/gerarCodValidacao';
  static const String ENDPOINT_REDEFINIR_SENHA = 'http://'+IP+'/profile/redefinirSenha';
  static const String ENDPOINT_OBTER_POR_ID = 'http://'+IP+'/profile/';
  static const String ENDPOINT_ALTERAR = 'http://'+IP+'/profile/';
  //PREMIOS
  static const String ENDPOINT_PREMIOS = 'http://'+IP+'/premios';
  static const String ENDPOINT_RESGATE = 'http://'+IP+'/premios/resgatar';
}