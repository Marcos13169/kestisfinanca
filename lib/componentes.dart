import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Componentes {
  Color cor = Color.fromARGB(255, 63, 72, 204);
  fonte(tamf, [cor, negrito]) {
    var n;
    if (negrito != null) {
      n = FontWeight.bold;
    }
    return GoogleFonts.roboto(
      color: cor,
      fontSize: tamf,
      fontWeight: n,
    );
  }

  criaAppBar(titulo, double tam, cor, [funcao, icone, corFundo]) {
    if (icone != null) {
      return AppBar(
        title: criaTexto(titulo, tam, cor),
        centerTitle: true,
        actions: <Widget>[IconButton(onPressed: funcao, icon: icone)],
        backgroundColor: corFundo,
      );
    } else {
      return AppBar(
        title: criaTexto(titulo, tam, cor),
        centerTitle: true,
        backgroundColor: corFundo,
      );
    }
  }

  criaTema() {
    return ThemeData(
        brightness: Brightness.light,
        primaryColor: cor,
        appBarTheme: AppBarTheme(backgroundColor: cor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: cor, // background (button) color
            foregroundColor: Colors.white, // foreground (text) color
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: cor, // background (button) color
            foregroundColor: Colors.white, // foreground (text) color
          ),
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ));
  }

  criaItemList(cor, titulo, [subtitulo, trailing]) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: cor),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: Text(trailing),
    );
  }

  criaItemListCard(corTexto, corCard, titulo, [subtitulo, trailing]) {
    return Card(
        //color: (indice % 2 == 0) ? Colors.black : Colors.black12,
        elevation: 0,
        margin: const EdgeInsets.all(10),
        color: corCard,
        child: ListTile(
          textColor: corTexto,
          title: Text(titulo),
          subtitle: Text(subtitulo),
          trailing: Text(trailing),
        ));
  }

  criaItemListIcon(cor, titulo, icon, [subtitulo, trailing]) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: cor,
          child: Expanded(
              child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ))),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: Text(trailing),
    );
  }

  criaItemListIconCard(cor, titulo, icon, corCard, [subtitulo, trailing]) {
    return Card(
        //color: (indice % 2 == 0) ? Colors.black : Colors.black12,
        elevation: 6,
        margin: const EdgeInsets.all(8),
        color: corCard,
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: cor,
              child: Expanded(
                  child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ))),
          title: Text(titulo),
          subtitle: Text(subtitulo),
          trailing: Text(trailing),
        ));
  }

  removeJsonAndArray(String text) {
    if (text.startsWith('[') || text.startsWith('{')) {
      text = text.substring(1, text.length - 1);
      if (text.startsWith('[') || text.startsWith('{')) {
        text = removeJsonAndArray(text);
      }
    }
    return text;
  }

  criaIcone(icone, cor, double tam) {
    return Icon(
      icone,
      color: cor,
      size: tam,
    );
  }

  criaIconeLogin(cor, icone, corIcone, double tamIcone, double padding) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          width: 190.0,
          height: 190.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cor,
          ),
          child: criaIcone(icone, corIcone, tamIcone),
        ));
  }

  criaTexto(String conteudo, double tam, cor, [negrito]) {
    if (negrito != null) {
      return Text(
        conteudo,
        style: fonte(tam, cor, negrito),
      );
    } else {
      return Text(
        conteudo,
        style: fonte(tam, cor),
      );
    }
  }

  criaTextField(titulo, senha, tipoTeclado, controlador, msgValidacao) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: TextFormField(
        controller: controlador,
        keyboardType: tipoTeclado,
        obscureText: senha,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
        ),
        textAlign: TextAlign.left,
        validator: (value) {
          if (value!.isEmpty) {
            return msgValidacao;
          }
        },
      ),
    );
  }

  criaTextFieldSemValidacao(
      titulo, senha, tipoTeclado, controlador, double tamf) {
    return TextFormField(
      autofocus: false,
      controller: controlador,
      keyboardType: tipoTeclado,
      obscureText: senha,
      decoration: InputDecoration(
        labelText: titulo,
        //border: const OutlineInputBorder(),
      ),
      textAlign: TextAlign.right,
      style: fonte(tamf),
    );
  }

  criaTextFieldMenosCoisas(titulo, tipoTeclado, controlador) {
    return TextFormField(
      autofocus: false,
      controller: controlador,
      keyboardType: tipoTeclado,
      decoration: InputDecoration(
        labelText: titulo,
        border: const OutlineInputBorder(),
      ),
    );
  }

  criaBotaoSemTam(funcao, rotulo) {
    return ElevatedButton(
        onPressed: () {
          funcao;
        },
        child: rotulo);
  }

  criaBotao(rotulo, funcao, double altura, double largura, double tam) {
    return SizedBox(
      height: altura,
      width: largura,
      child: ElevatedButton(
        onPressed: funcao,
        child: criaTexto(rotulo, tam, Colors.white),
      ),
    );
  }

  criaTextBotaoPadding(
      rotulo, funcao, double altura, double largura, double tam) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: SizedBox(
          height: altura,
          width: largura,
          child: TextButton(
            onPressed: () => funcao,
            child: criaTexto(rotulo, tam, Colors.white),
          ),
        ));
  }

  criaBotaoIcone(rotulo, funcao, double altura, double largura, icon, corIcon) {
    return SizedBox(
      height: altura,
      width: largura,
      child: ElevatedButton(
          onPressed: funcao,
          child: Column(
            children: [
              criaIcone(icon, corIcon, altura - 23),
              criaTexto(rotulo, 10, Colors.white),
            ],
          )),
    );
  }

  criaBotaoForm(
      controladorFormulario, rotulo, funcao, double altura, double largura) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: altura,
        width: largura,
        child: ElevatedButton(
          onPressed: () {
            if (controladorFormulario.currentState.validate()) {
              funcao();
            }
          },
          child: criaTexto(rotulo, 20, Colors.white),
        ),
      ),
    );
  }
}
