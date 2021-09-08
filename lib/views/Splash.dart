import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/views/Home.dart';
import 'package:pechinchar_online/views/Login.dart';

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with WidgetsBindingObserver{
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration(seconds: 3)).then((value) {
      User usuarioLogado = FirebaseAuth.instance.currentUser;

      if(usuarioLogado != null){
        Navigator.pushReplacementNamed(context, "/Home");
      }else {
        Navigator.pushReplacementNamed(context, "/Login");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 1000),
            () {
          _dynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("imagens/logo.jpeg",
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
    );
  }
}
class DynamicLinkService {

  Future<void> retrieveDynamicLink(BuildContext context) async {
    User usuarioLogado = FirebaseAuth.instance.currentUser;

    try {
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData dynamicLink) async {
            final Uri deepLink = dynamicLink?.link;

            if (deepLink != null) {
              if(usuarioLogado != null){
                  Navigator.pushNamed(context, deepLink.path);
              }else{
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
              }
            }
          },
          onError: (OnLinkErrorException e) async {
            print('onLinkError');
            print(e.message);
          }
      );

      final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;

      if (deepLink != null) {
        if(usuarioLogado != null){
            Navigator.pushNamed(context, deepLink.path);
        }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}