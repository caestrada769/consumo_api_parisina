import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmpleadoTortasScreen extends StatefulWidget {
  const EmpleadoTortasScreen({super.key});

  @override
  State<EmpleadoTortasScreen> createState() => _EmpleadoTortasScreenState();
}

class _EmpleadoTortasScreenState extends State<EmpleadoTortasScreen> {
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
                TextField(
                  decoration: const InputDecoration(labelText: 'Producto'),
                  onChanged: (value) {
                    editedData['producto'] = value;
                  },
                  controller:
                      TextEditingController(text: productionData['producto']),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Área'),
                  onChanged: (value) {
                    editedData['area'] = value;
                  },
                  controller:
                      TextEditingController(text: productionData['area']),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  onChanged: (value) {
                    editedData['cantidad'] = int.parse(value);
                  },
                  controller: TextEditingController(
                      text: productionData['cantidad'].toString()),
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
              child: const Text('Guardar'),
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
        final List<dynamic> productosArea = json.decode(response.body);
        productions = productosArea
            .where((production) => production['area'] == "Panaderia")
            .toList();
      });
    } else {
      throw Exception('Error al cargar la lista de producción');
    }
  }

  Future<void> deleteproductions(String productionId) async {
    final response = await http.delete(
      Uri.parse(
          'https://api-parisina-flutter.onrender.com/api/production/$productionId'),
    );
    if (response.statusCode == 204) {
      fetchProductions();
    } else {
      throw Exception('Error al eliminar la producción');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: productions.length,
            itemBuilder: (context, index) {
              final production = productions[index];
              return ListTile(
                title: Text(production['producto']),
                subtitle: Text(production['cantidad'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        editProduction(production);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
