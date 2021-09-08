import 'package:flutter_modular/flutter_modular.dart';

import 'HomeModule.dart';

class AppModule extends Module{
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
  ModuleRoute("/", module: HomeModule())
  ];
}