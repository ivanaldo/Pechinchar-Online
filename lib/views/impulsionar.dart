import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:url_launcher/url_launcher.dart';

class Impulsionar extends StatefulWidget {
  Anuncio anuncio;
  List<File> imagens;

  Impulsionar({this.anuncio, this.imagens});
  @override
  State<StatefulWidget> createState() => ImpulsionarState();
}

class ImpulsionarState extends State<Impulsionar> {

  BuildContext _dialogContext;
  String valor;

  @override
  void initState() {
    super.initState();
    setState(() {
      double valorPagar = ((double.parse(
          widget.anuncio.preco.replaceAll(".", "").replaceAll(',', '.')) /
          100) * 10);
      String valorCasaDecimal = valorPagar.toStringAsFixed(2);
      valor = valorCasaDecimal.toString().replaceAll('.', ',');
    });
  }

  _abrirDialog(BuildContext context){

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Salvando anúncio...")
              ],),
          );
        }
    );

  }

  Future _uploadImagens(Anuncio anuncio) async {

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for( var imagem in widget.imagens ){

      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus_anuncios")
          .child( anuncio.id )
          .child( nomeImagem );

      UploadTask uploadTask = arquivo.putFile(imagem);
      TaskSnapshot taskSnapshot = await uploadTask;

      String url = await taskSnapshot.ref.getDownloadURL();
      anuncio.fotos.add(url);

    }
  }

  Future<void>_abrirWhatstapp() async {
    var whatsappUrl = "whatsapp://send?phone=+5573981275007";
    if(await canLaunch(whatsappUrl)){
      await launch(whatsappUrl, forceSafariVC: false, forceWebView: false);
    }else
      throw 'Esse número $whatsappUrl não existe no WhatsApp';
  }

  impulsionarAnuncio (Anuncio anuncio) async{

    _abrirDialog( _dialogContext );

    //Upload imagens no Storage
    await _uploadImagens(anuncio);

    //recuperar o id do usuario logado
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser;
    String idUsuarioLogado = usuarioLogado.uid;

    //acrescentar valor 1 para impulsionar o anúncio
    anuncio.impulsionar = "1";

    if(widget.imagens != null) {
      //Salvar anuncio no Firestore meus anuncios
      FirebaseFirestore dbSalvar = FirebaseFirestore.instance;
      dbSalvar.collection("meus_anuncios")
          .doc(idUsuarioLogado)
          .collection("anuncios")
          .doc(anuncio.id)
          .set(anuncio.toMap()).then((_) {
        //salvar anúncio público
        dbSalvar.collection("anuncios")
            .doc(anuncio.categoria)
            .collection(anuncio.categoria)
            .doc(anuncio.id)
            .set(anuncio.toMap()).then((_) {
          Navigator.pop(_dialogContext);
          Navigator.pop(context);
        });
      });
    }else {
      //atualizar anuncio no Firestore meus anuncios
      FirebaseFirestore dbAtualizar = FirebaseFirestore.instance;
      dbAtualizar.collection("meus_anuncios")
          .doc(idUsuarioLogado)
          .collection("anuncios")
          .doc(anuncio.id)
          .set(anuncio.toMap()).then((_) {
        //atualizar anúncio público
        dbAtualizar.collection("anuncios")
            .doc(anuncio.categoria)
            .collection(anuncio.categoria)
            .doc(anuncio.id)
            .set(anuncio.toMap()).then((_) {
          Navigator.pop(_dialogContext);
          Navigator.pop(context);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Impulsionar anúncio"),
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
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if(widget.imagens != null)
                      Card(
                        margin: EdgeInsets.only(
                            top: 4, bottom: 4, right: 8, left: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Image.file(widget.imagens[0])
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
                                            widget.anuncio.titulo,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                          Text(
                                            "R\$ ${widget.anuncio.preco} ",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                              EdgeInsets.only(
                                                  top: 16)),
                                          Text(
                                            widget.anuncio.data,
                                          ),
                                          Text(widget.anuncio.horario),
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
                    if(widget.imagens == null)
                      Card(
                        margin: EdgeInsets.only(
                            top: 4, bottom: 4, right: 8, left: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Image.network(
                                  widget.anuncio.fotos[0],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent
                                      loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    return Center(
                                      child:
                                      CircularProgressIndicator(
                                        value: loadingProgress
                                            .expectedTotalBytes !=
                                            null
                                            ? loadingProgress
                                            .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  },
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
                                            widget.anuncio.titulo,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                          Text(
                                            "R\$ ${widget.anuncio.preco} ",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                              EdgeInsets.only(
                                                  top: 16)),
                                          Text(
                                            widget.anuncio.data,
                                          ),
                                          Text(widget.anuncio.horario),
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
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text("Coloque seu anúncio no topo",
                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 16, left: 16),
                      child: Text("Seu anúncio ficará em evidência no topo da lista por 30 dias em ordem, pela data "
                            "e horário de todos os anúncios que estão em evidências, depois dessa ordem"
                            " estarão os anúncios comuns"),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8, right: 16, left: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(right: 8),
                              child: Text("Valor para destacar seu anúncio",
                                style: TextStyle(fontSize: 18),
                              )
                          ),
                          ),
                          Container(
                              child: Text("R\$ "+ valor ,
                                style: TextStyle(fontSize: 18),
                              )
                          ),
                        ],
                      )
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.only(right: 16, left: 16, bottom: 8),
                      child: Text("Pague com o Pix 73981275007", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(right: 16, left: 16),
                      child: Text("Envie o comprovante para confirmar o pagamento, após confirmação seu anúncio irá para o topo da lista"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: InputButtonCustomizado(
                        text: "Enviar comprovante",
                        onPressed: () {
                          _abrirWhatstapp();
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
    );
  }
}