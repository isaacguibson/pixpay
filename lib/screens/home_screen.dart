import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/profile_screen.dart';
import '../screens/auth_screen.dart';
import '../models/usuario.dart';
import '../models/premio.dart';
import '../service/PremioService.dart';
import '../service/UsuarioService.dart';
import '../ad_state.dart';

enum MenuItens { perfil, sair }

class MyHomePage extends StatefulWidget {
  static final String route = '/homePage';

  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PremioService premioService = PremioService();
  UsuarioService usuarioService = UsuarioService();
  Usuario usuario;
  BannerAd bannerAd;

  List<Premio> premios = [];
  bool isLoading = true;
  SharedPreferences prefs;

  _mostratMensagemResgate(String titulo, String conteudo, String subconteudo) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(conteudo),
                Text(subconteudo),
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

  Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();

    getSharedPreferences().then((value) {
      this.prefs = value;
    });
    carregarPremios();
  }

  carregarPremios() {
    this.premioService.obterTodos().then((value) {
      if (value == null) {
        Navigator.pop(context);
        Navigator.pushNamed(context, AuthScreen.route);
      }
      setState(() {
        this.premios = value;

        List<Premio> premiosAux = [];
        print(this.premios.length);
        if (this.premios.length > 0) {
          for (int index = 0; index < (this.premios.length * 2); index++) {
            print('Valor do index');
            print(index);
            if (index % 2 != 0) {
              print('Index Impar');
              Premio premio = Premio(null, null, isBanner: true);
              premiosAux.add(premio);
            } else {
              print('Index par');
              print('Valor do subindex');
              print(index ~/ 2);
              premiosAux.add(this.premios[index ~/ 2]);
            }
          }
          this.premios = premiosAux;
        }

        this.isLoading = false;
      });
    }).catchError((err) {
      setState(() {
        this.premios = [];
        this.isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status) {
      setState(() {
        this.bannerAd = BannerAd(
          adUnitId: adState.bannerAdUnitId,
          size: AdSize.banner,
          request: AdRequest(),
          listener: BannerAdListener(),
        )..load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('PixPay'),
        actions: <Widget>[
          PopupMenuButton<MenuItens>(
            onSelected: (result) {
              setState(() {
                if (result == MenuItens.perfil) {
                  Navigator.pushNamed(context, ProfileScreen.route);
                } else if (result == MenuItens.sair) {
                  if (prefs != null) {
                    prefs.remove('id');
                    prefs.remove('token');
                  }
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AuthScreen.route);
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItens>>[
              const PopupMenuItem(
                child: Text('Perfil'),
                value: MenuItens.perfil,
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                child: Text('Sair'),
                value: MenuItens.sair,
              ),
            ],
          ),
        ],
      ),
      body: this.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: (premios == null || premios.length == 0)
                  ? Text(
                      'Sem prêmios disponíveis, volte novamente mais tarde...',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Container(
                      transformAlignment: Alignment.topCenter,
                      child: ListView.builder(
                        itemBuilder: (ctx, index) {
                          return premios[index].isBanner
                              ? Container(
                                  height: 50,
                                  child: AdWidget(
                                    ad: BannerAd(
                                      adUnitId:
                                          'ca-app-pub-3940256099942544/6300978111',
                                      size: AdSize.banner,
                                      request: AdRequest(),
                                      listener: BannerAdListener(),
                                    )..load(),
                                  ),
                                )
                              : GestureDetector(
                                  child: Card(
                                    elevation: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            'R\$ ' +
                                                premios[index].valor.toString(),
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: premios[index].color,
                                              width: 5,
                                            ),
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors:
                                                    premios[index].gradient),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 50,
                                            bottom: 50,
                                          ),
                                        ),
                                        Container(
                                          child: OutlinedButton(
                                            onPressed: premios[index].ativo
                                                ? () {
                                                    Future<String> resposta =
                                                        premioService.resgatar(
                                                            UsuarioService
                                                                .usuarioLogado
                                                                .id,
                                                            premios[index].id);
                                                    resposta.then((value) {
                                                      setState(() {
                                                        if (value == null) {
                                                          premios[index].ativo =
                                                              false;
                                                          premios[index]
                                                                  .usuarioId =
                                                              UsuarioService
                                                                  .usuarioLogado
                                                                  .id;
                                                          _mostratMensagemResgate(
                                                              'Parabéns',
                                                              'Você conseguiu resgatar esse prêmio.',
                                                              'Em breve, enviaremos o valor para sua conta.');
                                                        } else {
                                                          _mostratMensagemResgate(
                                                              'Oops',
                                                              value,
                                                              '');
                                                        }
                                                      });
                                                    });
                                                  }
                                                : null,
                                            child: Text(premios[index].status),
                                            style: OutlinedButton.styleFrom(
                                              primary: Colors.black,
                                              elevation: 0,
                                              side: BorderSide(
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.all(10),
                                  ),
                                );
                        },
                        itemCount: premios.length,
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            this.isLoading = true;
          });
          
          carregarPremios();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
