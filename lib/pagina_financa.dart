import 'dart:convert';

import 'package:financas_web/componentes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum aplicacaoEnum { cdb, lci }

class PaginaFinanca extends StatefulWidget {
  const PaginaFinanca({super.key});

  @override
  State<PaginaFinanca> createState() => _PaginaFinancaState();
}

class _PaginaFinancaState extends State<PaginaFinanca> {
  aplicacaoEnum? _escolha = aplicacaoEnum.cdb;

  TextEditingController cdiController = TextEditingController();
  TextEditingController cdiPorcentagemController = TextEditingController();
  TextEditingController dinheiroController = TextEditingController();
  TextEditingController irPorcentagemController = TextEditingController();
  TextEditingController mesController = TextEditingController();
  TextEditingController tipoAplicacaoController = TextEditingController();

  NumberFormat formatoTaxas = NumberFormat("0.0000");
  NumberFormat formatoDinheiro = NumberFormat("0.00");

  String taxas = '';
  double cdiMensal = 0;
  double selicMensal = 0;
  double porcentagemAnual = 0, porcentagemMensal = 0;
  double dinheiroTotal = 0;
  double lucroPorAno = 0, lucroPorMes = 0, lucroTotal = 0;
  double irAno = 0, irTotal = 0;

  SharedPreferences? _prefs;
  double cdi = 0;
  double selic = 0;
  String data = '00/00/0000';
  Map<String, String> locale = {
    'cdi': '0.0',
    'selic': '0.0',
    'data': '00/00/0000',
    'cdiController': '13.65',
    'pcCdiController': '100',
    'dinheiroController': '100',
    'mesController': '12',
  };

  void initState() {
    tipoAplicacaoController.text = 'c';
    SharedPreferences.getInstance().then((prefs) {
      setState(() => this._prefs = prefs);
      _loadDados();
      atualizaDados();
      calcularIR();
    });
  }

  void _loadDados() {
    setState(() {
      this.cdi = double.parse(this._prefs?.getString('cdi') ?? '0.0');
      this.selic = double.parse(this._prefs?.getString('selic') ?? '0.0');
      this.data = this._prefs?.getString('data') ?? '00/00/0000';
      this.cdiController.text =
          this._prefs?.getString('cdiController') ?? '0.0';
      this.cdiPorcentagemController.text =
          this._prefs?.getString('pcCdiController') ?? '100';
      this.dinheiroController.text =
          this._prefs?.getString('dinheiroController') ?? '100';
      this.mesController.text = this._prefs?.getString('mesController') ?? '12';
      locale = {
        'cdi': cdi.toString(),
        'selic': selic.toString(),
        'data': data,
        'cdiController': cdiController.text,
        'pcCdiController': cdiPorcentagemController.text,
        'dinheiroController': dinheiroController.text,
        'mesController': mesController.text,
      };
    });
  }

  Future<void> _setDados(
      String cdi,
      String selic,
      String data,
      String cdiController,
      String dinheiroController,
      String mesController,
      String pcCdiController) async {
    await this._prefs?.setString('cdi', cdi);
    await this._prefs?.setString('selic', selic);
    await this._prefs?.setString('data', data);
    await this._prefs?.setString('cdiController', cdiController);
    await this._prefs?.setString('dinheiroController', dinheiroController);
    await this._prefs?.setString('mesController', mesController);
    await this._prefs?.setString('pcCdiController', pcCdiController);
    _loadDados();
  }

  calcularIR() {
    if (tipoAplicacaoController.text == 'c') {
      if (double.parse(mesController.text) <= 6) {
        irPorcentagemController.text = '22.5';
      } else if (double.parse(mesController.text) > 6 &&
          double.parse(mesController.text) <= 12) {
        irPorcentagemController.text = '20';
      } else if (double.parse(mesController.text) > 12 &&
          double.parse(mesController.text) <= 24) {
        irPorcentagemController.text = '17.5';
      } else if (double.parse(mesController.text) > 24) {
        irPorcentagemController.text = '15';
      }
    }
  }

  atualizaDados() {
    cdiMensal = double.parse(formatoTaxas.format(cdi / 12));
    selicMensal = double.parse(formatoTaxas.format(selic / 12));
  }

  buscarCDI() async {
    String url =
        'https://api.hgbrasil.com/finance?format=json-cors&key=bbac6e47';
    Response resposta = await get(Uri.parse(url));
    Map financa = json.decode(resposta.body);

    taxas = '${financa['results']['taxes']}';
    taxas = Componentes().removeJsonAndArray(taxas);
    var dataSp = taxas.split(',');

    Map<String, String> mapData = {};
    for (var element in dataSp) {
      mapData[element.split(':')[0].trim()] = element.split(':')[1].trim();
    }

    Map taxasJson = mapData;

    setState(() {
      data = '${taxasJson['date']}';
      String ano = data.substring(0, 4);
      String mes = data.substring(5, 7);
      String dia = data.substring(8, 10);
      data = '$dia/$mes/$ano';
      cdi = double.parse(taxasJson['cdi_daily']);
      selic = double.parse(taxasJson['selic']);

      cdiController.text = cdi.toString();
    });
    this._setDados(
        cdi.toString(),
        selic.toString(),
        data,
        cdiController.text,
        dinheiroController.text,
        mesController.text,
        cdiPorcentagemController.text);
    calcular();
    atualizaDados();
  }

  calcular() {
    this._setDados(
        cdi.toString(),
        selic.toString(),
        data,
        cdiController.text,
        dinheiroController.text,
        mesController.text,
        cdiPorcentagemController.text);
    calcularIR();
    setState(() {
      double dinheiro = double.parse(dinheiroController.text);
      double porcentagem = double.parse(cdiPorcentagemController.text);
      double cdi = double.parse(cdiController.text);
      double irporcentagem = double.parse(irPorcentagemController.text);
      porcentagemAnual = porcentagem * cdi / 100;
      porcentagemMensal = porcentagemAnual / 12;
      irAno = ((dinheiro * porcentagemAnual / 100) * irporcentagem) / 100;
      irTotal = (irAno / 12) * double.parse(mesController.text);
      lucroPorAno = (dinheiro * porcentagemAnual / 100) - irAno;
      lucroPorMes = lucroPorAno / 12;
      lucroTotal = lucroPorMes * double.parse(mesController.text);
      dinheiroTotal =
          dinheiro + (lucroPorMes * double.parse(mesController.text));
    });
  }

  criaInputIR() {
    bool ativado = true;
    if (tipoAplicacaoController.text == 'c') {
      ativado = true;
      if (irPorcentagemController.text != '') {
        calcularIR();
      }
    } else if (tipoAplicacaoController.text == 'l') {
      ativado = false;
      irPorcentagemController.text = '0';
    }
    return Expanded(
        child: Padding(
      padding: EdgeInsets.all(5),
      child: TextFormField(
        enabled: ativado,
        autofocus: false,
        controller: irPorcentagemController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'IR%',
          border: const OutlineInputBorder(),
        ),
      ),
    ));
  }

  criaRadioTipoAplicacao() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('CDB'),
            leading: Radio<aplicacaoEnum>(
                value: aplicacaoEnum.cdb,
                groupValue: _escolha,
                onChanged: (aplicacaoEnum? value) {
                  setState(() {
                    _escolha = value;
                    tipoAplicacaoController.text = 'c';
                  });
                }),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('LCI'),
            leading: Radio<aplicacaoEnum>(
                value: aplicacaoEnum.lci,
                groupValue: _escolha,
                onChanged: (aplicacaoEnum? value) {
                  setState(() {
                    _escolha = value;
                    tipoAplicacaoController.text = 'l';
                  });
                }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Componentes().criaAppBar(
          '', 30, Colors.white, buscarCDI, const Icon(Icons.refresh_outlined)),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Componentes().criaItemListIcon(
                Colors.blueAccent,
                'CDI: $cdi',
                Icons.monetization_on_rounded,
                'CDI/Mês: $cdiMensal',
                'Data: $data'),
            Componentes().criaItemListIcon(
                Colors.orange,
                'SELIC: $selic',
                Icons.monetization_on_rounded,
                'SELIC/Mês: $selicMensal',
                'Data: $data'),
            const Divider(),
            Center(child: criaRadioTipoAplicacao()),
            const Divider(),
            Row(children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(5),
                child: Componentes().criaTextFieldMenosCoisas(
                    'CDI', TextInputType.number, cdiController),
              )),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(5),
                child: Componentes().criaTextFieldMenosCoisas(
                    'CDI%', TextInputType.number, cdiPorcentagemController),
              )),
              criaInputIR(),
            ]),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Componentes().criaTextFieldMenosCoisas(
                      'Dinheiro', TextInputType.number, dinheiroController),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Componentes().criaTextFieldMenosCoisas(
                      'Meses', TextInputType.number, mesController),
                )),
              ],
            ),
            const Divider(height: 25),
            botaoCalcular(),
            //Text(cdiString),
            //Text(selicString),
          ],
        ),
      ),
    );
  }

  botaoCalcular() {
    return SizedBox(
      height: 75,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: TextButton(
          onPressed: () {
            showModalBottomSheet(
                context: context, builder: (context) => telaInformacoes());
            calcular();
          },
          child: Componentes().criaTexto('Calcular', 16, Colors.white),
        ),
      ),
    );
  }

  telaInformacoes() {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Container(
        height: 318,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
              child: Container(
                decoration: const BoxDecoration(
                  color: //Color.fromARGB(38, 63, 72, 204),
                      Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(children: [
                  ListTile(
                    title: Componentes().criaTexto(
                        'Porcentagem CDI/Ano: $porcentagemAnual%',
                        15,
                        Colors.black),
                    subtitle: Componentes().criaTexto(
                        'Porcentagem CDI/Mês: $porcentagemMensal%',
                        13,
                        Color.fromARGB(255, 77, 77, 77)),
                  ),
                  ListTile(
                    title: Componentes().criaTexto(
                        'IR Total: R\$${formatoDinheiro.format(irTotal)}',
                        15,
                        Colors.red),
                    subtitle: Componentes().criaTexto(
                        'IR/Ano: R\$${formatoDinheiro.format(irAno)}',
                        13,
                        Color.fromARGB(190, 244, 67, 54)),
                    trailing: Componentes().criaTexto(
                        'IR%: ${irPorcentagemController.text}%',
                        14,
                        Colors.red),
                  ),
                  ListTile(
                    title: Componentes().criaTexto(
                        'Lucro Total: R\$${formatoDinheiro.format(lucroTotal)}',
                        15,
                        Color.fromARGB(255, 15, 190, 50)),
                    subtitle: Componentes().criaTexto(
                        'Lucro/Ano: R\$${formatoDinheiro.format(lucroPorAno)}',
                        13,
                        Color.fromARGB(190, 15, 190, 50)),
                    trailing: Componentes().criaTexto(
                        'Lucro/Mês: R\$${formatoDinheiro.format(lucroPorMes)}',
                        14,
                        Color.fromARGB(255, 15, 190, 50)),
                  ),
                ]),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                child: Expanded(
                    child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(85, 63, 72, 204),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ListTile(
                    textColor: Colors.black,
                    title: Componentes().criaTexto(
                        'Dinheiro Total: R\$${formatoDinheiro.format(dinheiroTotal)}',
                        15,
                        Colors.black),
                    subtitle: Componentes().criaTexto(
                        'Dinheiro Inicial: R\$${dinheiroController.text}',
                        13,
                        Color.fromARGB(255, 77, 77, 77)),
                  ),
                ))),
          ],
        ),
      ),
    );
  }
}
