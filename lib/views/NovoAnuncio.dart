import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pechinchar_online/customizados/InputCustomizadoAnuncio.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/customizados/inputDropdownButtonCustomizadoAnuncios.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/util/Configuracoes.dart';
import 'package:pechinchar_online/views/impulsionar.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  String data;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  List<File> _listaImagens = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategorias = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasImoveis = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasProdutos = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasMoveis = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasSupermercados = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasRestaurantes = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasTransporte = [];
  List<DropdownMenuItem<String>> _listaItensDropSubCategoriasServicos = [];
  final _formKey = GlobalKey<FormState>();
  Anuncio _anuncio;
  BuildContext _dialogContext;

  String _itemSelecionadoCategoria;
  String _itemSelecionadoSubCategoria;

  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerPreco = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controllerTitulo.dispose();
    _controllerPreco.dispose();
    _controllerDescricao.dispose();
    _anchoredBanner?.dispose();
  }

  FToast fToast;
  bool _progressBarLinear;
  String nome;
  String telefone;
  String cidade;
  String estado;
  String endereco;

  //retorna os dados do usuário do Firebase
  Future<dynamic> _retornaDados() async {
    _progressBarLinear = true;
    User user = FirebaseAuth.instance.currentUser;
    String id = user.uid;

    FirebaseFirestore.instance
        .collection("usuarios")
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      var dados = snapshot.data();
      setState(() {
        nome = dados["nome"];
        telefone = dados["telefone"];
        cidade = dados["cidade"];
        estado = dados["estado"];
        endereco = dados["endereco"];
        _progressBarLinear = false;
      });
    });
  }

  _selecionarImagemGaleria() async {
    final ImagePicker _picker = ImagePicker();

    final XFile imagemSelecionada =
        await _picker.pickImage(source: ImageSource.gallery);
    File imagens = File(imagemSelecionada.path);
    if (imagens != null) {
      if (_listaImagens.length < 6) {
        setState(() {
          _listaImagens.add(imagens);
        });
      } else {
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
                "Só é possível cadastrar 6 imagens!",
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
    }
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

  _validarCampos(String decisao) {
    //Recupera dados dos campos
    String titulo = _controllerTitulo.text.trim();
    String preco = _controllerPreco.text.trim();
    String descricao = _controllerDescricao.text.trim();

    if (_listaImagens.isNotEmpty) {
      if (_itemSelecionadoCategoria != null) {
        if (_itemSelecionadoSubCategoria != null) {
          if (titulo.isNotEmpty) {
            if (preco.isNotEmpty) {
              if (descricao.isNotEmpty) {
                User auth = FirebaseAuth.instance.currentUser;
                String idUsuarioLogado = auth.uid;

                DateTime hora = DateTime.now();
                String horas = DateFormat.Hms().format(hora);

                _anuncio.idUsuario = idUsuarioLogado;
                _anuncio.titulo = titulo;
                _anuncio.preco = preco;
                _anuncio.descricao = descricao;
                _anuncio.categoria = _itemSelecionadoCategoria;
                _anuncio.subCategoria = _itemSelecionadoSubCategoria;
                _anuncio.nome = nome;
                _anuncio.telefone = telefone;
                _anuncio.cidade = cidade;
                _anuncio.estado = estado;
                _anuncio.endereco = endereco;
                _anuncio.data = data;
                _anuncio.horario = horas;
                _anuncio.impulsionar = "0";
                if (decisao == "cadastrar") {
                  _salvarAnuncio(_anuncio);
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Impulsionar(
                              anuncio: _anuncio, imagens: _listaImagens)));
                }
              } else {
                Widget toast = Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
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
                        "Preencha o campo descrição!",
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
            } else {
              Widget toast = Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
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
                      "Preencha o campo preço!",
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
          } else {
            Widget toast = Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                    "Preencha o campo título!",
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
        } else {
          Widget toast = Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                  "Selecione uma subCategoria!",
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
      } else {
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
                "Selecione uma categoria!",
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
    } else {
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
              "Adicione uma foto!",
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
  }

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text("Salvando anúncio...")
              ],
            ),
          );
        });
  }

  _salvarAnuncio(Anuncio anuncio) async {
    _abrirDialog(_dialogContext);

    //Upload imagens no Storage
    await _uploadImagens(anuncio);

    //Salvar anuncio no Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_anuncios")
        .doc(idUsuarioLogado)
        .collection("anuncios")
        .doc(anuncio.id)
        .set(anuncio.toMap())
        .then((_) {
      //salvar anúncio público
      db
          .collection("anuncios")
          .doc(anuncio.categoria)
          .collection(anuncio.categoria)
          .doc(anuncio.id)
          .set(anuncio.toMap())
          .then((_) {
        Navigator.pop(_dialogContext);
        Navigator.pop(context);
      });
    });
  }

  Future _uploadImagens(Anuncio anuncio) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo =
          pastaRaiz.child("meus_anuncios").child(anuncio.id).child(nomeImagem);

      UploadTask uploadTask = arquivo.putFile(imagem);
      TaskSnapshot taskSnapshot = await uploadTask;

      String url = await taskSnapshot.ref.getDownloadURL();
      anuncio.fotos.add(url);
    }
  }

  _carregarItensDropdown() {
    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();
    _listaItensDropSubCategoriasImoveis = Configuracoes.getSubImoveis();
    _listaItensDropSubCategoriasProdutos = Configuracoes.getSubProdutos();
    _listaItensDropSubCategoriasMoveis = Configuracoes.getSubProdutos();
    _listaItensDropSubCategoriasSupermercados =
        Configuracoes.getSubSupermercados();
    _listaItensDropSubCategoriasRestaurantes =
        Configuracoes.getSubRestaurantes();
    _listaItensDropSubCategoriasTransporte = Configuracoes.getSubTransporte();
    _listaItensDropSubCategoriasServicos = Configuracoes.getSubServicos();
  }

  _carregarSubCategoria() {
    _itemSelecionadoSubCategoria = null;
    _listaItensDropSubCategorias.clear();
    switch (_itemSelecionadoCategoria) {
      case "imoveis":
        setState(() {
          for (var item in _listaItensDropSubCategoriasImoveis)
            _listaItensDropSubCategorias.add(item);
        });
        break;
      case "produtos":
        setState(() {
          for (var item in _listaItensDropSubCategoriasProdutos)
            _listaItensDropSubCategorias.add(item);
        });
        break;
      case "supermercados":
        setState(() {
          for (var item in _listaItensDropSubCategoriasSupermercados)
            _listaItensDropSubCategorias.add(item);
        });
        break;
      case "moveis":
        setState(() {
          for (var item in _listaItensDropSubCategoriasMoveis)
            _listaItensDropSubCategorias.add(item);
        });
        break;
      case "restaurantes":
        setState(() {
          for (var item in _listaItensDropSubCategoriasRestaurantes)
            _listaItensDropSubCategorias.add(item);
        });
        break;
      case "transporte":
        setState(() {
          for (var item in _listaItensDropSubCategoriasTransporte)
            _listaItensDropSubCategorias.add(item);
        });
        break;
      case "servicos":
        setState(() {
          for (var item in _listaItensDropSubCategoriasServicos)
            _listaItensDropSubCategorias.add(item);
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _anuncio = Anuncio.gerarId();
    _carregarItensDropdown();
    _retornaDados();
    _progressBarLinear = false;
    fToast = FToast();
    fToast.init(context);
    //retorna a data atual
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day);
    data = DateFormat("dd/MM/yyyy").format(date);
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
            title: Text("Novo anúncio"),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Image.asset("imagens/logo_anunciar.png", width: 60),
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
                    child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            FormField<List>(
                              initialValue: _listaImagens,
                              builder: (state) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      height: 100,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              _listaImagens.length + 1, //3
                                          itemBuilder: (context, indice) {
                                            if (indice ==
                                                _listaImagens.length) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _selecionarImagemGaleria();
                                                  },
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Color(0xFF46b044),
                                                    radius: 50,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.add_a_photo,
                                                          size: 40,
                                                          color:
                                                              Colors.grey[100],
                                                        ),
                                                        Text(
                                                          "Adicionar",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[100]),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            if (_listaImagens.length > 0) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder:
                                                            (context) => Dialog(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: <
                                                                        Widget>[
                                                                      Image.file(
                                                                          _listaImagens[
                                                                              indice]),
                                                                      TextButton(
                                                                        child:
                                                                            Text(
                                                                          "Excluir",
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _listaImagens.removeAt(indice);
                                                                            Navigator.of(context).pop();
                                                                          });
                                                                        },
                                                                      )
                                                                    ],
                                                                  ),
                                                                ));
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 50,
                                                    backgroundImage: FileImage(
                                                        _listaImagens[indice]),
                                                    child: Container(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 0.4),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            return Container();
                                          }),
                                    ),
                                    if (state.hasError)
                                      Container(
                                        child: Text(
                                          "[${state.errorText}]",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 14),
                                        ),
                                      )
                                  ],
                                );
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: _progressBarLinear
                                    ? LinearProgressIndicator(
                                        backgroundColor: Colors.green,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).accentColor),
                                      )
                                    : Center()),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child:
                                        InputDropdownButtonCustomizadoAnuncios(
                                      hint: "Categoria",
                                      items: _listaItensDropCategorias,
                                      value: _itemSelecionadoCategoria,
                                      onChanged: (valor) {
                                        setState(() {
                                          _itemSelecionadoCategoria = valor;
                                          _carregarSubCategoria();
                                        });
                                      },
                                      icon: Icon(Icons.map),
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(8)),
                                Expanded(
                                  child: Container(
                                    child:
                                        InputDropdownButtonCustomizadoAnuncios(
                                      hint: "SubCategoria",
                                      items: _listaItensDropSubCategorias,
                                      value: _itemSelecionadoSubCategoria,
                                      onChanged: (valor) {
                                        setState(() {
                                          _itemSelecionadoSubCategoria = valor;
                                        });
                                      },
                                      icon: Icon(Icons.map),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8, top: 8),
                              child: InputCustomizadoAnuncio(
                                controller: _controllerTitulo,
                                hint: "Título",
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: InputCustomizadoAnuncio(
                                controller: _controllerPreco,
                                hint: "Preço",
                                type: TextInputType.number,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  RealInputFormatter(centavos: true)
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: InputCustomizadoAnuncio(
                                controller: _controllerDescricao,
                                hint: "Descrição (200 caracteres)",
                                maxLines: null,
                                maxLength: 200,
                              ),
                            ), //color: Color(0x90000000)
                            Container(
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  labelText: 'Nome',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  "$nome",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8, top: 8),
                              child: Container(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(32, 16, 32, 16),
                                    labelText: 'Telefone',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    "$telefone",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(32, 16, 32, 16),
                                        labelText: 'Cidade',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: Text(
                                        "$cidade",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 8)),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.fromLTRB(32, 16, 32, 16),
                                        labelText: 'Estado',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: Text(
                                        "$estado",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 8)),
                            Container(
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  labelText: 'Endereço',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  "$endereco",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: InputButtonCustomizado(
                                text: "Impulsionar anúncio",
                                onPressed: () {
                                  //Configura dialog context
                                  _dialogContext = context;
                                  //salvar anuncio
                                  _validarCampos("impulsionar");
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: InputButtonCustomizado(
                                text: "Cadastrar anúncio",
                                onPressed: () {
                                  //Configura dialog context
                                  _dialogContext = context;
                                  //salvar anuncio
                                  _validarCampos("cadastrar");
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            )),
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
