import 'package:flutter_modular/flutter_modular.dart';
import 'package:pechinchar_online/views/Cadastro.dart';
import 'package:pechinchar_online/views/Home.dart';
import 'package:pechinchar_online/views/Login.dart';
import 'package:pechinchar_online/views/Splash.dart';
import 'package:pechinchar_online/views/meusAnuncios.dart';


class HomeModule extends Module{

  @override
  List<ModularRoute> get routes => [
    ChildRoute("/", child: (_, args) => Splash()),
    ChildRoute("/Login", child: (_, args) => Login()),
    ChildRoute("/Cadastro", child: (_, args) => Cadastro()),
    ChildRoute("/Home", child: (_, args) => Home()),
    ChildRoute("/MeusAnuncios", child: (_, args) => MeusAnuncios()),
  ];
}