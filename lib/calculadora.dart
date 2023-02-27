import 'package:financas_web/componentes.dart';
import 'package:flutter/services.dart';
import 'package:function_tree/function_tree.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  double num1 = 0;
  String equacao = 'Seus Cálculos';
  String calculos = '';
  String calculosKey = '';
  List listCalculos = [];
  TextEditingController txtnumController = TextEditingController();
  double tamBotao = 0;
  NumberFormat formatter = NumberFormat(".0");
  SharedPreferences? _prefs;

  void _loadCalculos() {
    setState(() {
      this.calculos = this._prefs?.getString(calculosKey) ?? '';
    });
  }

  Future<void> _setCalculos(String calculos) async {
    await this._prefs?.setString(calculosKey, calculos);
    _loadCalculos();
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => this._prefs = prefs);
      _loadCalculos();
    });
  }

  @override
  Widget build(BuildContext context) {
    num(n) {
      setState(() {
        txtnumController.text += n;
      });
    }

    igual() {
      try {
        String conta = txtnumController.text;
        conta = conta.replaceAll('x', '*');
        conta = conta.replaceAll('÷', '/');
        conta = conta.replaceAll(',', '.');

        if (conta.isNotEmpty) {
          for (int i = 0; i < txtnumController.text.length; i++) {
            String a = txtnumController.text.substring(i, i + 1);
            String b = txtnumController.text.substring(
                txtnumController.text.length - 1, txtnumController.text.length);
            if (a == '+' || a == '-' || a == 'x' || a == '÷') {
              if (b != '+' || b != '-' || b != 'x' || b != '÷') {
                equacao = txtnumController.text;
                final expressionsExample = [conta];
                for (final expression in expressionsExample) {
                  String numero = ("${expression.interpret()}");
                  int casas;

                  setState(() {
                    if (double.parse(numero) % 2 == 1.0 ||
                        double.parse(numero) % 2 == 0.0) {
                      numero = formatter.format(double.parse(numero));
                      casas = numero.length;
                      String a = numero.substring(0, 1);
                      if (a == '-') {
                        txtnumController.text = expression
                            .interpret()
                            .toStringAsPrecision(casas - 3);
                      } else if (numero == '.0') {
                        txtnumController.text = numero.replaceAll('.', '');
                      } else {
                        txtnumController.text =
                            double.parse(numero).toStringAsPrecision(casas - 2);
                      }
                    } else {
                      txtnumController.text = numero;
                    }
                    _setCalculos(
                        calculos += '$equacao = ${txtnumController.text},');
                  });
                }
              }
            }
          }
        }
        //if (calculos.isEmpty && equacao != 'Seus Cálculos') {
        //  calculos += '$equacao = ${txtnumController.text}\n';
        //} else {
        //  calculos += '$equacao = ${txtnumController.text}\n';
        //}
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Componentes().criaTexto('Erro:', 20, Colors.red),
                content: Componentes().criaTexto(
                    'Não foi possível executar esse cálculo.',
                    20,
                    Colors.black),
                actions: <Widget>[
                  TextButton(
                    child: Componentes().criaTexto('Limpar', 15, Colors.blue),
                    onPressed: () {
                      txtnumController.text = '';
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Componentes().criaTexto('Fechar', 15, Colors.blue),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          },
        );
      }
    }

    apagar() {
      if (txtnumController.text.isNotEmpty) {
        txtnumController.text = txtnumController.text
            .substring(0, txtnumController.text.length - 1);
      }
    }

    naorepitiroperadores(n) {
      if (txtnumController.text.isNotEmpty) {
        String a = txtnumController.text.substring(
            txtnumController.text.length - 1, txtnumController.text.length);
        if (a != '÷' &&
            a != 'x' &&
            a != '-' &&
            a != '+' &&
            a != '.' &&
            a != '(' &&
            a != ')') {
          num(n);
        }
      }
    }

    limparLista(contextModal) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Componentes()
                  .criaTexto('Você deseja limpar tudo?', 20, Colors.black),
              actions: <Widget>[
                TextButton(
                  child: Componentes().criaTexto('Sim', 15, Colors.blue),
                  onPressed: () {
                    _setCalculos('');
                    Navigator.of(context).pop();
                    Navigator.of(contextModal).pop();
                  },
                ),
                TextButton(
                  child: Componentes().criaTexto('Nâo', 15, Colors.blue),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        },
      );
    }

    modalBottom() {
      listCalculos = calculos.split(',');
      listCalculos.remove('');
      return showModalBottomSheet(
        context: context,
        builder: (BuildContext contextModal) {
          return SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () => limparLista(contextModal),
                        child: Text('Limpar lista')),
                  ),
                ),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listCalculos.length,
                    itemBuilder: (context, index) {
                      if (listCalculos[0] != 'vazio') {
                        return ListTile(
                            title: Text(listCalculos[index]),
                            trailing: FittedBox(
                              fit: BoxFit.fill,
                              child: IconButton(
                                  hoverColor:
                                      Color.fromARGB(255, 142, 255, 145),
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Colors.green),
                                  onPressed: () {
                                    String conta = listCalculos[index];
                                    conta = conta.substring(
                                        0, conta.indexOf(' = '));

                                    txtnumController.text = conta;
                                  }),
                            ));
                      } else {
                        return ListTile(
                          title: Text(listCalculos[index]),
                        );
                      }
                    })
              ],
            ),
          );
        },
      );
    }

    reiniciar() {
      Navigator.pushReplacementNamed(context, '/calculadora');
    }

    botao(var n, [corTextoBotao, corBotao]) {
      if (corBotao == null) {
        corBotao = Colors.white;
      }
      if (corTextoBotao == null) {
        corTextoBotao = Colors.black;
      }

      return Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.all(1),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.095,
                child: ElevatedButton(
                    style: ButtonStyle(
                      animationDuration: Duration(milliseconds: 5),
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => corBotao),
                      foregroundColor: MaterialStateProperty.resolveWith(
                          (states) => corTextoBotao),
                    ),
                    onPressed: () {
                      setState(() {
                        if (n == '=') {
                          igual();
                        } else if (n == 'C') {
                          txtnumController.text = '';
                        } else if (n == '<-') {
                          apagar();
                        } else if (n == '÷' ||
                            n == 'x' ||
                            n == '+' ||
                            n == '.') {
                          naorepitiroperadores(n);
                        } else {
                          num(n);
                        }
                      });
                    },
                    child: Componentes().criaTexto(n, 20, corTextoBotao)),
              )));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Componentes().criaTextFieldSemValidacao(
                    '', false, TextInputType.number, txtnumController, 30)),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.095,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        animationDuration: Duration(milliseconds: 5),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (calculos != '') {
                          modalBottom();
                        } else {
                          final snackBar = SnackBar(
                            content: const Text('A lista está vazia'),
                            action: SnackBarAction(
                              label: 'Ok',
                              onPressed: () {
                                //Navigator.of(context).pop();
                              },
                            ),
                          );

                          // Find the ScaffoldMessenger in the widget tree
                          // and use it to show a SnackBar.
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Componentes().criaTexto(equacao, 20, Colors.black),
                    ),
                  ),
                ),
                botao('<-', Colors.red),
              ],
            ),
            Row(
              children: [
                botao('C', Colors.red),
                botao('(', Colors.green),
                botao(')', Colors.green),
                botao('÷', Colors.green),
              ],
            ),
            Row(
              children: [
                botao('7'),
                botao('8'),
                botao('9'),
                botao('x', Colors.green),
              ],
            ),
            Row(
              children: [
                botao('4'),
                botao('5'),
                botao('6'),
                botao('-', Colors.green),
              ],
            ),
            Row(
              children: [
                botao('1'),
                botao('2'),
                botao('3'),
                botao('+', Colors.green),
              ],
            ),
            Row(
              children: [
                botao('.'),
                botao('0'),
                botao('=', Colors.white, Colors.green)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
