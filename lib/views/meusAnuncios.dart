import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pechinchar_online/adaptadores/ItemMeusAnuncios.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/views/NovoAnuncio.dart';
import 'package:pechinchar_online/views/impulsionar.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({Key key}) : super(key: key);

  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  _recuperaDadosUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado.uid;

  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {

    await _recuperaDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc( _idUsuarioLogado )
        .collection("anuncios")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

   _removerAnuncio(Anuncio anuncio) async {

    for(var foto in anuncio.fotos){
      try {
        Reference ref = FirebaseStorage.instance.refFromURL(foto);
        await ref.delete();
      } catch (e) {
      }
    }

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
        .doc( _idUsuarioLogado )
        .collection("anuncios")
        .doc( anuncio.id )
        .delete().then((_){

      db.collection("anuncios")
          .doc(anuncio.categoria)
          .collection(anuncio.categoria)
          .doc(anuncio.id)
          .delete();

    });

  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
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
      child: Column(children: <Widget>[
        Text("Carregando anúncios"),
        CircularProgressIndicator()
      ],),
    );
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Meus Anúncios"),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Image.asset("imagens/logo_mao.png", width: 60),
          )
        ],
        backgroundColor: Color(0xFF129E09),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text("Anúnciar"),
        onPressed: (){
          Navigator.push(context, PageTransition(child: NovoAnuncio(), type: PageTransitionType.bottomToTop));
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Stack(
                children: [
                  StreamBuilder(
                    stream: _controller.stream,
                    builder: (context, snapshot){

                      switch( snapshot.connectionState ){
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return carregandoDados;
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:

                        //Exibe mensagem de erro
                          if(snapshot.hasError)
                            return Text("Erro ao carregar os dados!");

                          QuerySnapshot querySnapshot = snapshot.data;

                          return ListView.builder(
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (_, indice){

                                List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                                DocumentSnapshot documentSnapshot = anuncios[indice];
                                Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                                return ItemMeusAnuncios(
                                  anuncio: anuncio,
                                  onTapItem: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                        Impulsionar(anuncio: anuncio)));
                                  },
                                  onPressedRemover: (){
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                          return AlertDialog(
                                            title: Text("Atenção"),
                                            content: Text("Deseja realmente excluir o anúncio?"),
                                            actions: <Widget>[

                                              TextButton(
                                                child: Text(
                                                  "Cancelar",
                                                  style: TextStyle(
                                                      color: Colors.grey
                                                  ),
                                                ),
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                              ),

                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  primary: Colors.red,
                                                ),
                                                child: Text(
                                                  "Excluir",
                                                  style: TextStyle(
                                                      color: Colors.red
                                                  ),
                                                ),
                                                onPressed: (){
                                                  _removerAnuncio( anuncio );
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  },
                                );
                              }
                          );
                      }
                      return Container();
                    },
                  ),
                ],
              )
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
          ),
        ],
      )
    );
  }
}
