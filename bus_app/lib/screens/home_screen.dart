import 'package:flutter/material.dart';
import '../api/bus_map_widget.dart';
import '../database/db_helper.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchedLine = '';
  List<Map<String, dynamic>> _savedBuses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedBuses();
  }

  void _loadSavedBuses() async {
    final buses = await DBHelper.getSavedBuses();
    setState(() {
      _savedBuses = buses;
    });
  }

  void _saveBus(String line) async {
    if (line.isNotEmpty) {
      await DBHelper.saveBus(line);
      _loadSavedBuses();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ônibus salvo!")));
    }
  }

  void _deleteBus(int id) async {
    await DBHelper.deleteBus(id);
    _loadSavedBuses();
  }

  void _editBus(int id, String oldLine) async {
    final controller = TextEditingController(text: oldLine);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Editar Ônibus"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Nova linha"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.updateBus(id, controller.text);
              _loadSavedBuses();
              Navigator.pop(context);
            },
            child: Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários de Ônibus', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Digite a linha do ônibus',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchedLine = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _saveBus(_searchController.text);
                  },
                  child: const Icon(Icons.save),
                ),
              ],
            ),
          ),

          // Mapa com veículos da linha pesquisada
          if (_searchedLine.isNotEmpty)
            BusMapWidget(
              token: "df171373c89f0846d7295e8290604d3ede50af06e8f331cfd5ca9e77f531bf79", // Seu token aqui
              selectedLine: _searchedLine, searchedBusLine: '',
            ),

          // Lista de ônibus salvos
          Expanded(
            child: ListView.builder(
              itemCount: _savedBuses.length,
              itemBuilder: (context, index) {
                final bus = _savedBuses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('Linha: ${bus['name']}'),
                    onTap: () {
                      setState(() {
                        _searchedLine = bus['name']; 
                        _searchController.text = bus['name'];
                      });
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editBus(bus['id'], bus['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBus(bus['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
