import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pechinchar_online/customizados/inputButtonCustomizados.dart';
import 'package:pechinchar_online/customizados/inputCustomizado.dart';


class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

   FToast fToast;
   bool _progressBarLinear;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    _progressBarLinear = false;
    fToast.init(context);
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerSenha.dispose();
    super.dispose();
  }

  _validarCampos() {
    //Recupera dados dos campos
    String email = _controllerEmail.text.trim();
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        setState(() {
          _progressBarLinear = true;
        });
        _logarUsuario(email, senha);

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
                "Preencha a sua senha de acesso, ela tem que ter mais de seis caracteres!",
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
              "Preencha o seu email de acesso!",
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

  _logarUsuario(String email, String senha) {

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(email: email, password: senha).then((firebaseUser) {
      setState(() {
        _progressBarLinear = false;
      });
      Navigator.pushReplacementNamed(context, "/Home");

    }).catchError((error) {
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
            Text(
              "Algum problema com seus dados ou com sua internet!",
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
    return Scaffold(
      body: Stack(
        children: [
          _builderDrawerBack(),
          Container(
            child: GestureDetector(
              onTap: (){
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
                          child: Image.asset("imagens/logo_mao.png", width: 200, height: 200),
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
                            padding: EdgeInsets.only(top: 2.0, right: 16, left: 16),
                            child: InputCustomizado(
                              controller: _controllerEmail,
                              hint: "Email",
                              obscure: false,
                              icon: Icon(Icons.person),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8, right: 16, left: 16),
                            child: InputCustomizado(
                              controller: _controllerSenha,
                              hint: "Senha",
                              obscure: true,
                              icon: Icon(Icons.lock),
                            )
                        ),
                        Center(
                            child: Container(
                              padding: EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Não tem conta!",
                                  style: TextStyle(fontSize: 16),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pushReplacementNamed(context, "/Cadastro");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text("Cadastre-se",
                                        style: TextStyle(fontSize: 16, color: Color(
                                            0xff067206)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8, right: 16, left: 16),
                            child:  InputButtonCustomizado(
                              text: "Logar",
                              onPressed: (){
                                _validarCampos();
                              },
                            )
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