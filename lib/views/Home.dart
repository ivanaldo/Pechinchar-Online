import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/models/debouncer.dart';
import 'package:pechinchar_online/views/Perfil.dart';
import 'package:pechinchar_online/views/detalhesAnuncio.dart';
import 'package:pechinchar_online/views/favoritos.dart';
import 'package:pechinchar_online/views/meusAnuncios.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  bool _progresBarLinear;
  TabController _tabController;
  bool searchState = false;
  bool retornoMensagem = true;
  int favoritos = 0;
  int valorControllerTab = 0;
  String valor;
  List<Anuncio> lista = [];
  final _debouncer = Debouncer(milliseconds: 800);


  @override
  void initState() {
    super.initState();
    retornarQuantidadeFavoritos();
    _progresBarLinear = true;
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          valorControllerTab = _tabController.index;
          searchState = false;
          lista.clear();
          searchAnuncio();
        });
      }
    });
    searchAnuncio();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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

  //retorna o id da compra
  Future<dynamic> retornarQuantidadeFavoritos() async {
    User user = FirebaseAuth.instance.currentUser;
    String id = user.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_favoritos")
        .doc(id)
        .collection("favoritos")
        .snapshots()
        .listen((event) {
      favoritos = 0;
      for (DocumentSnapshot dados in event.docs) {
        if (dados.exists) {
          setState(() {
            favoritos++;
          });
        }
      }
    });
  }

  Future<dynamic> searchAnuncio({String search}) async {
    _progresBarLinear = true;
    setState(() {
      retornoMensagem = true;
    });

    switch (valorControllerTab) {
      case 0:
        setState(() {
          valor = "imoveis";
        });
        break;
      case 1:
        setState(() {
          valor = "produtos";
        });
        break;
      case 2:
        setState(() {
          valor = "moveis";
        });
        break;
      case 3:
        setState(() {
          valor = "supermercados";
        });
        break;
      case 4:
        setState(() {
          valor = "restaurantes";
        });
        break;
      case 5:
        setState(() {
          valor = "transporte";
        });
        break;
      case 6:
        setState(() {
          valor = "servicos";
        });
        break;
    }

    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db
        .collection("anuncios")
        .doc(valor)
        .collection(valor)
        .orderBy("impulsionar", descending: true)
        .orderBy("data", descending: true)
        .orderBy("horario", descending: true)
        .get();
    for (DocumentSnapshot dados in querySnapshot.docs) {
      Anuncio anuncio = Anuncio();
      if (dados.exists) {
        setState(() {
          anuncio.titulo = dados["titulo"];
          anuncio.idUsuario = dados["idUsuario"];
          anuncio.id = dados["id"];
          anuncio.descricao = dados["descricao"];
          anuncio.preco = dados["preco"];
          anuncio.nome = dados["nome"];
          anuncio.categoria = dados["categoria"];
          anuncio.subCategoria = dados["subCategoria"];
          anuncio.estado = dados["estado"];
          anuncio.telefone = dados["telefone"];
          anuncio.cidade = dados["cidade"];
          anuncio.endereco = dados["endereco"];
          anuncio.impulsionar = dados["impulsionar"];
          anuncio.fotos = List<String>.from(dados["fotos"]);
          anuncio.data = dados["data"];
          anuncio.horario = dados["horario"];
          if (search == null || search.isEmpty) {
            setState(() {
              lista.add(anuncio);
              _progresBarLinear = false;
            });
          } else if (
          anuncio.titulo.toLowerCase().contains(search) ||
              anuncio.estado.toLowerCase().contains(search)) {
            setState(() {
              lista.add(anuncio);
              _progresBarLinear = false;
            });
          }
        });
      }
    }
    if (lista.length == 0) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        setState(() {
          retornoMensagem = false;
          _progresBarLinear = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
        appBar: AppBar(
          title: !searchState
              ? Text("")
              : TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search ...",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  onChanged: (text) {
                    _debouncer.run(() {
                      String texto = text.toLowerCase();
                      searchAnuncio(search: texto);
                    });
                  },
                ),
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: !searchState
                  ? IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          searchState = !searchState;
                        });
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          searchState = !searchState;
                        });
                      },
                    ),
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        child: Image.asset(
                          "imagens/icone_coracao_branco.png",
                          height: 30,
                          width: 30,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: Favoritos(),
                                type: PageTransitionType.bottomToTop));
                      },
                    ),
                    if (favoritos != 0)
                      Container(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text("" + favoritos.toString()),
                          )
                      )
                  ],
                )
            )
          ],
          backgroundColor: Color(0xFF129E09),
        ),
        drawer: Drawer(
            child: Stack(
             children: [
             ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 32, bottom: 16),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF46b044), Color(0xff9cd981)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)),
                  child: Image.asset(
                    "imagens/logo_mao.png",
                    width: 150,
                    height: 150,
                  ),
                ),
                Divider(
                  color: Colors.grey[600],
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: Colors.black,
                  ),
                  title: Text("Perfil"),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: Perfil(),
                            type: PageTransitionType.leftToRight));
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "imagens/logo_anunciar.png",
                    width: 30,
                    height: 30,
                  ),
                  title: Text("Anunciar Produtos"),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: MeusAnuncios(),
                            type: PageTransitionType.bottomToTop));
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    "imagens/icone_coracao.png",
                    height: 30,
                    width: 30,
                  ),
                  title: Text("Favoritos"),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: Favoritos(),
                            type: PageTransitionType.bottomToTop));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: Colors.black),
                  title: Text("Sair"),
                  onTap: () {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    auth.signOut();
                    Navigator.pushReplacementNamed(context, "/Login");
                  },
                )
              ],
            ),
          ],
        )),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: Text(
                "Anúncios principais",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF46b044),
                    const Color(0xff9cd981),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF46b044),
                    const Color(0xff9cd981),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                indicatorWeight: 4,
                labelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                controller: _tabController,
                indicatorColor: Colors.black,
                tabs: <Widget>[
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_imoveis.png",
                      width: 30,
                      height: 30,
                    ),
                    text: "Imóveis",
                  ),
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_produtos.png",
                      width: 30,
                      height: 30,
                    ),
                    text: "Produtos",
                  ),
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_moveis.png",
                      width: 30,
                      height: 30,
                    ),
                    text: "Móveis",
                  ),
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_supermercados.png",
                      width: 30,
                      height: 30,
                    ),
                    text: "Supermercados",
                  ),
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_restaurante.png",
                      width: 40,
                      height: 30,
                    ),
                    text: "Restaurantes",
                  ),
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_transporte.png",
                      width: 30,
                      height: 30,
                    ),
                    text: "Transpotes",
                  ),
                  Tab(
                    icon: Image.asset(
                      "imagens/logo_servicos.png",
                      width: 30,
                      height: 30,
                    ),
                    text: "Serviços",
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    child: Column(
                      children: <Widget>[
                        if (lista.length != 0)
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: lista.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetalhesAnuncio(
                                                      lista[index], true)));
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(
                                          top: 4, bottom: 4, right: 8, left: 8),
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: 120,
                                              height: 120,
                                              child: CachedNetworkImage(
                                                imageUrl: lista[index].fotos[0],
                                                imageBuilder: (context, imageProvider) => Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) => Transform.scale(
                                                  scale: 0.3,
                                                  child: CircularProgressIndicator(
                                                    color: Color(0xff0f530f),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          lista[index].titulo,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "R\$ ${lista[index].preco} ",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 16)),
                                                        Text(
                                                          lista[index].data,
                                                        ),
                                                        Text(lista[index]
                                                            .horario),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        if (retornoMensagem == false && lista.length == 0)
                          Container(
                            padding: EdgeInsets.all(25),
                            child: Text(
                              "Nenhum anúncio! :( ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                      child: Column(
                        children: [
                         Container(
                          padding: EdgeInsets.only(top: 8),
                          child: _progresBarLinear
                              ? CircularProgressIndicator(
                                  color: Color(0xff0f530f),
                                )
                              : Center(),
                      ),
                    ],
                   )
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
        ));
  }
}