import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pechinchar_online/customizados/InputCustomizadoAnuncio.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/customizados/inputCustomizado.dart';
import 'package:pechinchar_online/customizados/inputDropdownButtonCustomizado.dart';
import 'package:pechinchar_online/external/IbgeApi.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/models/IbgeApiModel.dart';
import 'package:pechinchar_online/models/Usuario.dart';
import 'package:pechinchar_online/models/deletarPerfil.dart';


class Perfil extends StatefulWidget {
  const Perfil({Key key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {

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
        nome     = dados["nome"];
        telefone = dados["telefone"];
        cidade   = dados["cidade"];
        estado   = dados["estado"];
        endereco = dados["endereco"];
        _progressBarLinear = false;
      });
    });
  }

  List<DropdownMenuItem<String>> _listaEstados = [];
  List<DropdownMenuItem<String>> _listaCidades = [];


  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEndereco = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();

  FToast fToast;
  Usuario usuario = Usuario();
  String _estadoSelecionado;
  String _cidadeSelecionada;
  bool _progressBarLinear;
  List<Anuncio> listaAnuncios = [];

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _carregarItensDropdownEstados();
    _retornaDados();
    _retornaIdAnuncios();
    _progressBarLinear = false;
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerEndereco.dispose();
    _controllerTelefone.dispose();
    super.dispose();
  }

  Future _carregarItensDropdownCidades() async {
    _cidadeSelecionada = null;
    _listaCidades.clear();
    IbgeApi apiCidades = IbgeApi();
    List _listaCidade = [];
    _listaCidade = await apiCidades.getSearchEstado(_estadoSelecionado);

    for (int i = 0; i < _listaCidade.length; i++) {
      IbgeApiModel nome = IbgeApiModel();
      nome = _listaCidade[i];
      setState(() {
        _listaCidades
            .add(DropdownMenuItem(child: Text(nome.nome), value: nome.nome));
      });
    }
  }

//carrega todos os estados do brasil
  _carregarItensDropdownEstados() {
    for(var estado in Estados.listaEstadosSigla) {
      _listaEstados.add(DropdownMenuItem(child: Text(estado), value: estado,));
    }
  }

  _validarCampos() {

    //Recupera dados dos campos
    String nome = _controllerNome.text.trim();
    String endereco = _controllerEndereco.text.trim();
    String telefone = _controllerTelefone.text;

    if (nome.isNotEmpty) {
      if (telefone.isNotEmpty) {
        if (_estadoSelecionado != null) {
          if (_cidadeSelecionada != null) {
            if (endereco.isNotEmpty) {
              setState(() {
                _progressBarLinear = true;
              });
                  usuario.nome = nome;
                  usuario.telefone = telefone;
                  usuario.cidade = _cidadeSelecionada;
                  usuario.estado = _estadoSelecionado;
                  usuario.endereco = endereco;
                  _atualizarPerfil(usuario);
            }else {
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
                      "Informe o seu endereço!",
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
                    "Informe a sua cidade!",
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
                  "Informe o seu estado!",
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
                "Informe o seu telefone!",
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
              "Informe o seu nome!",
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

  Future<dynamic> _retornaIdAnuncios() async {
    User user = FirebaseAuth.instance.currentUser;
    String id = user.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
   QuerySnapshot querySnapshot = await db
        .collection("meus_anuncios")
        .doc( id )
        .collection("anuncios")
        .get();
    for(DocumentSnapshot dados in querySnapshot.docs){
      Anuncio anuncios = Anuncio();
      if(dados.exists){
        setState(() {
          anuncios.titulo       = dados["titulo"];
          anuncios.idUsuario    = dados["idUsuario"];
          anuncios.id           = dados["id"];
          anuncios.descricao    = dados["descricao"];
          anuncios.preco        = dados["preco"];
          anuncios.nome         = dados["nome"];
          anuncios.categoria    = dados["categoria"];
          anuncios.subCategoria = dados["subCategoria"];
          anuncios.estado       = dados["estado"];
          anuncios.telefone     = dados["telefone"];
          anuncios.cidade       = dados["cidade"];
          anuncios.impulsionar  = dados["impulsionar"];
          anuncios.endereco     = dados["endereco"];
          anuncios.fotos        = List<String>.from(dados["fotos"]);
          anuncios.data         = dados["data"];
          anuncios.horario      = dados["horario"];

          listaAnuncios.add(anuncios);
        });
      }
    }
  }

  _atualizarAnuncio() async {

    //Salvar anuncio no Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser;
    String idUsuarioLogado = usuarioLogado.uid;

    for(int i = 0; i < listaAnuncios.length; i++) {
      listaAnuncios[i].nome     = nome;
      listaAnuncios[i].telefone = telefone;
      listaAnuncios[i].cidade   = cidade;
      listaAnuncios[i].estado   = estado;
      listaAnuncios[i].endereco = endereco;

      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("meus_anuncios")
          .doc(idUsuarioLogado)
          .collection("anuncios")
          .doc(listaAnuncios[i].id)
          .set(listaAnuncios[i].toMap()).then((_) {
        //salvar anúncio público
        db.collection("anuncios")
            .doc(listaAnuncios[i].categoria)
            .collection(listaAnuncios[i].categoria)
            .doc(listaAnuncios[i].id)
            .set(listaAnuncios[i].toMap()).then((_) {

        });
      });
    }
  }

  _atualizarPerfil(Usuario usuario) async{
    User user = FirebaseAuth.instance.currentUser;
    String id = user.uid;

    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.collection("usuarios").doc(id).set(
        {
          "nome"     : usuario.nome,
          "telefone" : usuario.telefone,
          "cidade"   : usuario.cidade,
          "estado"   : usuario.estado,
          "endereco" : usuario.endereco

        }).then((value){
          setState(() {
            _atualizarAnuncio();
            _progressBarLinear = false;
          });
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
            Text("Atualizado com sucesso!",
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
      );

      fToast.showToast(
        child: toast,
        gravity: ToastGravity.TOP,
        toastDuration: Duration(seconds: 2),
      );
    }).catchError((erro){
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
            Text("Erro ao atualizar",
                style: TextStyle(color: Colors.white, fontSize: 20)),
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

  //metodo que chama a classe deleta conta
  _alertaDeletarConta() {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Sim", style: TextStyle(color: Colors.blue),),
      onPressed: () {
        setState(() {

          DeletarPerfil deletar = DeletarPerfil();
          deletar.deletarFirebaseFirestore();
          Navigator.of(context).pop();
          Navigator.pushNamed(context, "/Login");

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
      content: Text("Tem certeza que deseja apagar essa conta e todos os seus dados?"),
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

  @override
  Widget build(BuildContext context) {
      _controllerNome.text = nome;
      _controllerTelefone.text = telefone;
      _controllerEndereco.text = endereco;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Perfil"),
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
          Container(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: _progressBarLinear ? LinearProgressIndicator(
                            backgroundColor: Colors.green,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).accentColor
                            ),
                          ):Center(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8, left: 8),
                          child: InputCustomizado(
                            hint: "Nome",
                            obscure: false,
                            icon: Icon(Icons.person),
                            controller: _controllerNome,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                          child: InputCustomizadoAnuncio(
                            controller: _controllerTelefone,
                            hint: "Telefone",
                            type: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TelefoneInputFormatter()
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                                child: InputDropdownButtonCustomizado(
                                  value: _cidadeSelecionada,
                                  hint: "Cidade",
                                  items: _listaCidades,
                                  icon: Icon(Icons.where_to_vote),
                                  onChanged: (valor){
                                    setState(() {
                                      _cidadeSelecionada = valor;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  padding: EdgeInsets.only(top: 8, right: 8),
                                  child: InputDropdownButtonCustomizado(
                                    value: _estadoSelecionado,
                                    hint: "Estado",
                                    items: _listaEstados,
                                    icon: Icon(Icons.vpn_lock_rounded),
                                    onChanged: (valor){
                                      setState(() {
                                        _estadoSelecionado = valor;
                                        _carregarItensDropdownCidades();
                                      });
                                    },
                                  )
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, right: 8, left: 8),
                          child: InputCustomizado(
                            hint: "Endereço",
                            obscure: false,
                            icon: Icon(Icons.map),
                            controller: _controllerEndereco,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 16.0, right: 8, left: 8),
                          child: InputButtonCustomizado(
                            text: "Atualizar perfil",
                            onPressed: (){
                              _validarCampos();
                            },
                          ),
                        ), 
                        Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
                          child: ElevatedButton(
                            child: Text("Deletar conta", style: TextStyle(fontSize: 20),),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange,
                              padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)
                              )
                            ),
                            onPressed: (){
                              _alertaDeletarConta();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
