import 'package:flutter/material.dart';

class Configuracoes {

  //Categorias
  static List<DropdownMenuItem<String>> getCategorias(){

    List<DropdownMenuItem<String>> itensDropCategorias = [];

    itensDropCategorias.add(
        DropdownMenuItem(child: Text(
            "Categoria", style: TextStyle(
          color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Imóveis"), value: "imoveis",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Produtos"), value: "produtos",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Móveis"), value: "moveis",)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Supermercados"), value: "supermercados",)
    );

    itensDropCategorias.add(
      DropdownMenuItem(child: Text("Restaurantes"), value: "restaurantes")
    );

    itensDropCategorias.add(
      DropdownMenuItem(child: Text("Transporte"), value: "transporte")
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Serviços"), value: "servicos")
    );

    return itensDropCategorias;

  }

  //SubCategorias Imovéis
  static List<DropdownMenuItem<String>> getSubImoveis(){

    List<DropdownMenuItem<String>> itensDropSubCategoriaImoveis = [];

    itensDropSubCategoriaImoveis.add(
        DropdownMenuItem(child: Text(
          "SubCategoria", style: TextStyle(
            color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropSubCategoriaImoveis.add(
        DropdownMenuItem(child: Text("Aluguel"), value: "aluguel",)
    );

    itensDropSubCategoriaImoveis.add(
        DropdownMenuItem(child: Text("Vendas"), value: "Vendas",)
    );

    itensDropSubCategoriaImoveis.add(
        DropdownMenuItem(child: Text("Terrenos"), value: "terrenos",)
    );

    return itensDropSubCategoriaImoveis;

  }

  //SubCategorias Produtos e Movéis
  static List<DropdownMenuItem<String>> getSubProdutos(){

    List<DropdownMenuItem<String>> itensDropSubCategoriaProdutos = [];

    itensDropSubCategoriaProdutos.add(
        DropdownMenuItem(child: Text(
          "SubCategoria", style: TextStyle(
            color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropSubCategoriaProdutos.add(
        DropdownMenuItem(child: Text("Novos"), value: "novos",)
    );

    itensDropSubCategoriaProdutos.add(
        DropdownMenuItem(child: Text("Usados"), value: "usados",)
    );

    return itensDropSubCategoriaProdutos;

  }

  //SubCategorias Supermercados
  static List<DropdownMenuItem<String>> getSubSupermercados(){

    List<DropdownMenuItem<String>> itensDropSubCategoriaSupermercados = [];

    itensDropSubCategoriaSupermercados.add(
        DropdownMenuItem(child: Text(
          "SubCategoria", style: TextStyle(
            color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropSubCategoriaSupermercados.add(
        DropdownMenuItem(child: Text("Não perecíveis"), value: "não perecíveis",)
    );

    itensDropSubCategoriaSupermercados.add(
        DropdownMenuItem(child: Text("Frios"), value: "frios",)
    );

    itensDropSubCategoriaSupermercados.add(
        DropdownMenuItem(child: Text("Higiene"), value: "higiene",)
    );

    itensDropSubCategoriaSupermercados.add(
        DropdownMenuItem(child: Text("Promoções"), value: "promocoes",)
    );

    return itensDropSubCategoriaSupermercados;

  }

  //SubCategorias Restaurantes
  static List<DropdownMenuItem<String>> getSubRestaurantes(){

    List<DropdownMenuItem<String>> itensDropSubCategoriaRestaurantes = [];

    itensDropSubCategoriaRestaurantes.add(
        DropdownMenuItem(child: Text(
          "SubCategoria", style: TextStyle(
            color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropSubCategoriaRestaurantes.add(
        DropdownMenuItem(child: Text("Comidas"), value: "comidas",)
    );

    itensDropSubCategoriaRestaurantes.add(
        DropdownMenuItem(child: Text("Bebidas"), value: "bebidas",)
    );

    itensDropSubCategoriaRestaurantes.add(
        DropdownMenuItem(child: Text("Delivery"), value: "delivery",)
    );

    itensDropSubCategoriaRestaurantes.add(
        DropdownMenuItem(child: Text("Promoções"), value: "promocoes",)
    );

    return itensDropSubCategoriaRestaurantes;

  }

  //SubCategorias Transportes
  static List<DropdownMenuItem<String>> getSubTransporte(){

    List<DropdownMenuItem<String>> itensDropSubCategoriaTransporte = [];

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text(
          "SubCategoria", style: TextStyle(
            color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text("Viagens"), value: "viagens",)
    );

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text("Uber"), value: "uber",)
    );

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text("Aluguel"), value: "aluguel",)
    );

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text("Vendas"), value: "vendas",)
    );

    return itensDropSubCategoriaTransporte;

  }
  //SubCategorias Servicos
  static List<DropdownMenuItem<String>> getSubServicos(){

    List<DropdownMenuItem<String>> itensDropSubCategoriaTransporte = [];

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text(
          "SubCategoria", style: TextStyle(
            color: Color(0x90000000)
        ),
        ), value: null,)
    );

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text("Autônomo"), value: "autonomo",)
    );

    itensDropSubCategoriaTransporte.add(
        DropdownMenuItem(child: Text("Empresa"), value: "empresa",)
    );

    return itensDropSubCategoriaTransporte;

  }
}