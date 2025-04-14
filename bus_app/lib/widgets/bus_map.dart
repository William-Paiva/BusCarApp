import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class BusMapWidget extends StatefulWidget {
  const BusMapWidget({super.key});

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget> {
  final TextEditingController _controller = TextEditingController();
  final MapController _mapController = MapController();
  List<Marker> _busMarkers = [];
  Timer? _updateTimer;

  static const String apiToken = "df171373c89f0846d7295e8290604d3ede50af06e8f331cfd5ca9e77f531bf79"; // coloque sua chave aqui

  Future<void> _autenticar() async {
    final url = Uri.parse(
        "https://api.olhovivo.sptrans.com.br/v2/Login/Autenticar?token=$apiToken");
    final response = await http.post(url);
    print("Autenticado: ${response.body}");
  }

  Future<int?> _buscarCodigoLinha(String numero) async {
    final url = Uri.parse(
        "https://api.olhovivo.sptrans.com.br/v2/Linha/Buscar?termosBusca=$numero");
    final response = await http.get(url);
    final data = json.decode(response.body);
    if (data.isNotEmpty) {
      return data[0]["cl"]; // código da linha
    }
    return null;
  }

  Future<void> _buscarVeiculos(int codigoLinha) async {
    final url = Uri.parse(
        "https://api.olhovivo.sptrans.com.br/v2/Posicao?codigoLinha=$codigoLinha");
    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data["vs"] != null) {
      final List<Marker> markers = (data["vs"] as List).map((bus) {
        final lat = bus["py"];
        final lon = bus["px"];
        return Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(lat, lon),
          builder: (ctx) => const Icon(
            Icons.directions_bus,
            color: Colors.blue,
            size: 36,
          ),
        );
      }).toList();

      setState(() {
        _busMarkers = markers;
      });

      if (markers.isNotEmpty) {
        _mapController.move(markers[0].point, 13.0);
      }
    }
  }

  void _buscarOnibus() async {
    final numero = _controller.text.trim();
    if (numero.isEmpty) return;

    await _autenticar();
    final codigo = await _buscarCodigoLinha(numero);
    if (codigo != null) {
      await _buscarVeiculos(codigo);

      _updateTimer?.cancel();
      _updateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _buscarVeiculos(codigo);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Linha não encontrada")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Digite o número do ônibus (ex: 701A)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _buscarOnibus,
              ),
            ),
            onSubmitted: (_) => _buscarOnibus(),
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(-23.5505, -46.6333),
              zoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _busMarkers),
            ],
          ),
        ),
      ],
    );
  }
}
