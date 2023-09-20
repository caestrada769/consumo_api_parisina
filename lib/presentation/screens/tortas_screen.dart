import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TortasScreen extends StatefulWidget {
  const TortasScreen({super.key});

  @override
  State<TortasScreen> createState() => _TortasScreenState();
}

class _TortasScreenState extends State<TortasScreen> {
  List<dynamic> productions = [];
  String editedEstado = '';

  @override
  void initState() {
    super.initState();
    fetchProductions();
  }

  Future<void> editProduction(Map<String, dynamic> productionData) async {
    Map<String, dynamic> editedData = {...productionData};
    editedEstado = productionData['estado'];

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Producción'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Producto: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['producto']}', // Texto a mostrar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Área: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['area']}', // Texto a mostrar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Cantidad: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['cantidad']}', // Texto a mostrar
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: editedEstado.isNotEmpty
                      ? editedEstado
                      : productionData['estado'],
                  items: <String>['En espera', 'En preparación', 'Terminado']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      editedEstado = newValue!;
                    });
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.put(
                  //put porque es para editar
                  Uri.parse(
                      'https://api-parisina-flutter.onrender.com/api/production/${productionData['_id']}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'producto': editedData['producto'],
                    'area': editedData['area'],
                    'cantidad': editedData['cantidad'],
                    'estado': editedEstado,
                  }),
                );

                if (response.statusCode == 200) {
                  fetchProductions();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                } else {
                  // Manejar errores de actualización
                  throw Exception('Error al actualizar la producción');
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchProductions() async {
    final response = await http.get(
        Uri.parse('https://api-parisina-flutter.onrender.com/api/production'));
    if (response.statusCode == 200) {
      setState(() {
        final List<dynamic> productionArea = json.decode(response.body);
        productions = productionArea
            .where((production) =>
                production['area'] == "Panaderia" &&
                production['estado'] != 'Terminado')
            .toList();

        // Agrega una declaración print para verificar las producciones
        print("Productions: $productions");
      });
    } else {
      throw Exception('Error al cargar la lista de producción');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orden de Producción'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              if (productions.isNotEmpty) // Agrega esta condición
                Expanded(
                  child: ListView.builder(
                      itemCount: productions.length,
                      itemBuilder: (context, index) {
                        final production = productions[index];
                        return Container(
                            decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Color.fromRGBO(188, 148, 60, 10)
                                    : Color.fromRGBO(238, 228, 207, 10),
                                borderRadius: BorderRadius.circular(3)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    editProduction(production);
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          production['producto'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    production['cantidad'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ));
                      }),
                )
              else
                const Text('No hay ordenes de producción disponibles'),
            ],
          ),
        ),
      ),
    );
  }
}
