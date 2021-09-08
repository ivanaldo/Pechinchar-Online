import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/views/perfilAnunciante.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalhesAnuncio extends StatefulWidget {

  Anuncio anuncio;
  bool liberaPerfil;
  DetalhesAnuncio(this.anuncio, this.liberaPerfil);

  @override
  _DetalhesAnuncioState createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {

  String _linkMessage;

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  Anuncio _anuncio;
  bool _liberarPerfil;

  List<Widget> _getListaImagens(){

    List<String> listaUrlImagens = _anuncio.fotos;
    return listaUrlImagens.map((url){
      return CachedNetworkImage(
        imageUrl: url,
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
      );
    }).toList();

  }

  Future<void>_ligarTelefone(String telefone) async {

    if( await canLaunch("tel:$telefone") ){
      await launch("tel:$telefone", forceWebView: false, forceSafariVC: false);
    }else{
      print("Não pode fazer a ligação");
    }
  }

  Future<void>_abrirWhatstapp(String telefone) async {
    var whatsappUrl = "whatsapp://send?phone=+55$telefone";
    if(await canLaunch(whatsappUrl)){
      await launch(whatsappUrl, forceSafariVC: false, forceWebView: false);
    }else
      throw 'Esse número $whatsappUrl não existe no WhatsApp';
  }

  FToast fToast;
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _anuncio = widget.anuncio;
    _liberarPerfil = widget.liberaPerfil;
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


  _adicionarFavorito(){
    var id = FirebaseAuth.instance.currentUser;
    String idUsuario = id.uid;

    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance
        .collection("meus_favoritos")
        .doc(idUsuario)
        .collection("favoritos")
        .doc(_anuncio.id)
        .set(_anuncio.toMap()).then((value){

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
            Text("Adicionado como favorito com sucesso!",
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
      );

      fToast.showToast(
        child: toast,
        gravity: ToastGravity.TOP,
        toastDuration: Duration(seconds: 2),
      );
    }
    );
  }
  Future<void> _createDynamicLink(bool short) async {

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://pechinchar.page.link',
      link: Uri.parse('https://pechinchar.page.link/${_anuncio.id}/'),
      androidParameters: AndroidParameters(
        packageName: 'icm.technology.mobile.pechinchar_online',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
    });
  }

  _onShare() async {
   await _createDynamicLink(true);

      await Share.share(_linkMessage, subject: ""+ _anuncio.titulo);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Detalhes do anuncio"),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Image.asset("imagens/logo_mao.png", width: 60),
          )
        ],
        backgroundColor: Color(0xFF129E09),
      ),
      body: Stack(
        children: [
        ListView(
          children: [
          Padding(padding: EdgeInsets.only(top: 2)),
          SizedBox(
            height: 250,
            child: Carousel(
              images: _getListaImagens(),
              dotSize: 8,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              autoplay: false,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 16, right: 16, left: 16,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "R\$ ${_anuncio.preco}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                   GestureDetector(
                     onTap: () {
                       _onShare();
                        },
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Image.asset("imagens/compartilhar.png", width: 20, height: 20,),
                           Text(
                             "Compartilhar",
                             style: TextStyle(
                               fontSize: 14,
                             ),
                           )
                         ],
                       )
                   )
                  ],
                ),
              Padding(padding: EdgeInsets.only(top: 8)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${_anuncio.titulo}",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(_anuncio.data),
                      Text(_anuncio.horario)
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Text(
                "Descrição",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "${_anuncio.descricao}",
                style: TextStyle(
                    fontSize: 18
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Text(
                "Anunciante",
                style: TextStyle(
                    fontSize: 14,
                    //fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "${_anuncio.nome}",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold
                  ),
                ),
              ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "${_anuncio.endereco + ", " + _anuncio.cidade + "-" + _anuncio.estado}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         Text("Contato"),
                            Padding(
                             padding: EdgeInsets.only(bottom: 8),
                             child: Text(
                               "${_anuncio.telefone}",
                               style: TextStyle(
                                   fontSize: 18, fontWeight: FontWeight.bold
                               ),
                             ),
                           ),
                       ],
                     ),
                    ),
                    if(_liberarPerfil == true)Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilAnunciante(widget.anuncio)));
                        },
                        child: Text("Ver perfil",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff0f530f)
                          ),
                        ),
                      )
                    )
                  ],
                )
             ],
            ),
          ),
          Divider(),
          Center(
            child: Text("Fale com o anunciante"),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Container(
                    child: Text(
                      "Ligar",
                      style: TextStyle(
                          color: Color(0xff0f530f),
                          fontSize: 20
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: temaPadrao.primaryColor,
                        borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  onTap: (){
                    _ligarTelefone( _anuncio.telefone );
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    child: Text(
                      "WhatsApp",
                      style: TextStyle(
                          color: Color(0xff0f530f),
                          fontSize: 20
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: temaPadrao.primaryColor,
                        borderRadius: BorderRadius.circular(30)
                    ),
                  ),
                  onTap: (){
                    _abrirWhatstapp( _anuncio.telefone );
                  },
                ),
              )
            ],
          ),
            Padding(
            padding: EdgeInsets.only( right: 16, left: 16, bottom: 70),
            child: InputButtonCustomizado(
              text: "Adicionar aos favoritos",
              onPressed: (){
                _adicionarFavorito();
              },
            ),
          ),
         ],
        ),
          Positioned(
            bottom: 0.0,
              child: Column(
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
          )
      ],
      ),
    );
  }
}
