import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pechinchar_online/customizados/InputCustomizadoAnuncio.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/customizados/inputCustomizado.dart';
import 'package:pechinchar_online/customizados/inputDropdownButtonCustomizado.dart';
import 'package:pechinchar_online/external/IbgeApi.dart';
import 'package:pechinchar_online/models/IbgeApiModel.dart';
import 'package:pechinchar_online/models/Usuario.dart';


class Cadastro extends StatefulWidget {
  const Cadastro({Key key}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  List<DropdownMenuItem<String>> _listaEstados = [];
  List<DropdownMenuItem<String>> _listaCidades = [];

  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerEndereco = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerConfirmarSenha = TextEditingController();

  FToast fToast;
  Usuario usuario = Usuario();
  String _estadoSelecionado;
  String _cidadeSelecionada;
  bool _progressBarLinear;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _progressBarLinear = false;
    _carregarItensDropdownEstados();
  }

  @override
  void dispose() {
    _controllerNome.dispose();
    _controllerEmail.dispose();
    _controllerTelefone.dispose();
    _controllerEndereco.dispose();
    _controllerSenha.dispose();
    _controllerConfirmarSenha.dispose();
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
    String email = _controllerEmail.text.trim();
    String telefone = _controllerTelefone.text;
    String endereco = _controllerEndereco.text.trim();
    String senha = _controllerSenha.text;
    String confirmarSenha = _controllerConfirmarSenha.text;

    if (nome.isNotEmpty) {
      if (telefone.isNotEmpty) {
        if (_estadoSelecionado != null) {
          if (_cidadeSelecionada != null) {
            if (endereco.isNotEmpty) {
              if (email.isNotEmpty && email.contains("@")) {
                if (senha.isNotEmpty && senha.length > 6) {
                  if (confirmarSenha.isNotEmpty &&
                      confirmarSenha.length > 6 &&
                      confirmarSenha == senha) {
                    setState(() {
                      _progressBarLinear = true;
                    });
                    usuario.nome = nome;
                    usuario.telefone = telefone;
                    usuario.cidade = _cidadeSelecionada;
                    usuario.estado = _estadoSelecionado;
                    usuario.endereco = endereco;

                    _cadastrarUsuario(email, senha, usuario);
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
                            "Senhas não são iguais, por favor corrija as senhas!",
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
                          "Informe a sua senha de acesso, ela tem que ter mais de seis caracteres!",
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
                        "Informe o seu e-mail!",
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
          }else {
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

  _cadastrarUsuario(String email, String senha, Usuario usuario) {

    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.createUserWithEmailAndPassword(email: email, password: senha).then((firebaseUser) {

      var id = FirebaseAuth.instance.currentUser;
      String idUsuario = id.uid;

      final firestoreInstance = FirebaseFirestore.instance;
      firestoreInstance.collection("usuarios").doc(idUsuario).set(
          {
            "nome"     : usuario.nome,
            "telefone" : usuario.telefone,
            "cidade"   : usuario.cidade,
            "estado"   : usuario.estado,
            "endereco" : usuario.endereco

          }).then((value){
            setState(() {
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
              Text("Cadastrado com sucesso!",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        );

        fToast.showToast(
          child: toast,
          gravity: ToastGravity.TOP,
          toastDuration: Duration(seconds: 2),
        );

        Navigator.pushReplacementNamed(context, "/Login");

      });
    }).catchError((erro) {
      setState(() {
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
            Text("Erro com sua internet ou email já foi cadastrado!",
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

  @override
  Widget build(BuildContext context) {
    //aplica degradê na tela
    Widget _builderDrawerBack() => Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color(0xFF46b044),
                Color(0xff9cd981)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight
          )
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, "/Login");
        return false;
      },
        child: Scaffold(
            body: Stack(
              children: [
                _builderDrawerBack(),
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
                              Container(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Image.asset("imagens/logo_mao.png", width: 200.0, height: 200.0),
                              ),
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
                                padding: EdgeInsets.only(top: 8, right: 8, left: 8),
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
                                      padding: EdgeInsets.only(top: 8, right: 16, left: 8),
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
                                        ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                                child: InputCustomizado(
                                  hint: "Endereço",
                                  obscure: false,
                                  icon: Icon(Icons.map),
                                  controller: _controllerEndereco,

                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0, right: 8, left: 8),
                                child: InputCustomizado(
                                  hint: "E-mail",
                                  obscure: false,
                                  icon: Icon(Icons.attach_email_outlined),
                                  controller: _controllerEmail,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                        padding:
                                        EdgeInsets.only(top: 8, left: 8, right: 2),
                                        child: InputCustomizado(
                                          hint: "Senha",
                                          obscure: true,
                                          icon: Icon(Icons.lock),
                                          controller: _controllerSenha,
                                        ),
                                      )),
                                  Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8, right: 8, left: 2),
                                        child: InputCustomizado(
                                          hint: "Senha",
                                          obscure: true,
                                          icon: Icon(Icons.lock),
                                          controller: _controllerConfirmarSenha,
                                        ),
                                      )),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 16.0, bottom: 16.0, right: 16, left: 16),
                                child: InputButtonCustomizado(
                                  text: "Cadastrar",
                                  onPressed: (){
                                    _validarCampos();
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
        ),
    );
  }
}
