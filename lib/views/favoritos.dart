import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pechinchar_online/adaptadores/ItemFavorito.dart';
import 'package:pechinchar_online/models/Anuncio.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({Key key}) : super(key: key);

  @override
  _FavoritosState createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  FToast fToast;
  final _controler = StreamController<QuerySnapshot>.broadcast();

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    User user = FirebaseAuth.instance.currentUser;
    String idUsuario = user.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_favoritos")
        .doc(idUsuario)
        .collection("favoritos")
        .snapshots();

    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  //metodo que chama a classe deleta conta
  _alertaDeletar(Anuncio anuncio) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Sim", style: TextStyle(color: Colors.blue),),
      onPressed: () {
        setState(() {
          _removerPedido(anuncio);
          Navigator.of(context).pop();

        });
      },
    );

    Widget continueButton = TextButton(
      child: Text("Não", style: TextStyle(color: Colors.blue)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Atenção"),
      content: Text("Tem certeza que deseja retirar esse anúncio de favorito?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _removerPedido(Anuncio anuncio) async {
    User user = FirebaseAuth.instance.currentUser;
    String idUsuario = user.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_favoritos")
        .doc( idUsuario )
        .collection("favoritos")
        .doc( anuncio.id )
        .delete().then((_){

      Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.black45,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12.0,
            ),
            Text(
              "Pedido removido do carrinho!",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      );
      fToast.showToast(
        child: toast,
        gravity: ToastGravity.TOP,
        toastDuration: Duration(seconds: 2),
      );
    });

  }

  mensagem() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black45,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.0,
          ),
          Text(
            "Função ainda será habilitada!",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
    fToast = FToast();
    fToast.init(context);
  }
  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
  }

  //responsavel por exibir o banner de anúncios
  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize size =
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: Platform.isAndroid
      //ca-app-pub-4141006277093451/3137185376 meu banner original
          ? 'ca-app-pub-4141006277093451/3137185376'
          : 'ca-app-pub-4141006277093451/3137185376',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    var carregandoDados = Center(
      child: Column(
        children: <Widget>[
          CircularProgressIndicator(
            color: Color(0xff0f530f),
          ),
          Text("Carregando anúncios"),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Meus Favoritos"),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Image.asset("imagens/icone_coracao_branco.png", height: 30, width: 30,)
          )
        ],
        backgroundColor: Color(0xFF129E09),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  child: Column(
                    children: <Widget>[
                      StreamBuilder(
                        stream: _controler.stream,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return carregandoDados;
                              break;
                            case ConnectionState.active:
                            case ConnectionState.done:
                              QuerySnapshot querySnapshot = snapshot.data;

                              if (querySnapshot.docs.length == 0) {
                                return Container(
                                  padding: EdgeInsets.all(25),
                                  child: Text(
                                    "Nada no favoritos! :( ",
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              return Expanded(
                                child: ListView.builder(
                                    itemCount: querySnapshot.docs.length,
                                    itemBuilder: (_, indice) {
                                      List<DocumentSnapshot> anuncios =
                                      querySnapshot.docs.toList();
                                      DocumentSnapshot documentSnapshot =
                                      anuncios[indice];
                                      Anuncio anuncio = Anuncio.fromDocumentSnapshot(
                                          documentSnapshot);

                                      return ItemFavorito(
                                        anuncio: anuncio,
                                        onTapItem: () {
                                          mensagem();
                                        },
                                        onPressedRemover: (){
                                          _alertaDeletar(anuncio);
                                        },
                                      );
                                    }),
                              );
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Column(
            children: [
              if (_anchoredBanner != null)
                Container(
                  color: Colors.white,
                  width: _anchoredBanner.size.width.toDouble(),
                  height: _anchoredBanner.size.height.toDouble(),
                  child: AdWidget(ad: _anchoredBanner),
                ),
            ],
          )
        ],
      )
    );
  }
}
