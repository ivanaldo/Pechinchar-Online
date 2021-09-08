import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pechinchar_online/models/Anuncio.dart';
import 'package:pechinchar_online/views/detalhesFavorito.dart';


class ItemFavorito extends StatelessWidget {

  Anuncio anuncio;
  VoidCallback onTapItem;
  VoidCallback onPressedRemover;

  ItemFavorito({
    @required this.anuncio,
    this.onTapItem,
    this.onPressedRemover
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetalhesFavorito(anuncio)));
      },
      child: Card(
        margin: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 8),
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 120,
                      child: CachedNetworkImage(
                        imageUrl: anuncio.fotos[0],
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
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
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              anuncio.titulo,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text("R\$ ${anuncio.preco} ",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 16)),
                            Text(anuncio.data,),
                            Text(anuncio.horario),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.red,
                              //padding: EdgeInsets.all(8),
                            ),
                            onPressed: this.onPressedRemover,
                            child: Icon(Icons.delete, color: Colors.red,),
                          ),
                        ],
                      )
                    )
                    //botao remover
                  ],
                ),
              ],
            )
        ),
      ),
    );
  }
}