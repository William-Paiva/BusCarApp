import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusMapWidget extends StatefulWidget {
  final String token;
  final String selectedLine;

  const BusMapWidget({super.key, required this.token, required this.selectedLine, required String searchedBusLine});

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget> {
  final String apiUrl = 'http://api.olhovivo.sptrans.com.br/v2.1';
  final MapController _mapController = MapController();

  LatLng _center = LatLng(-23.55052, -46.633308); 
  List<Marker> _busMarkers = [];
  int? _linhaId;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _authenticate();
    await _fetchLinhaId();
    if (_linhaId != null) {
      await _fetchVehicles(_linhaId!);
    }
  }

  Future<void> _authenticate() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/Login/Autenticar?token=df171373c89f0846d7295e8290604d3ede50af06e8f331cfd5ca9e77f531bf79'),
      );

      if (response.statusCode != 200) {
        print('Erro ao autenticar na API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro de autenticação: $e');
    }
  }

  Future<void> _fetchLinhaId() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/Linha/Buscar?termosBusca=${widget.selectedLine}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _linhaId = data[0]['cl'];
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar ID da linha: $e');
    }
  }

  Future<void> _fetchVehicles(int idLinha) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/Posicao'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final linhas = data['l'] as List;

        final linha = linhas.firstWhere((l) => l['cl'] == idLinha, orElse: () => null);

        if (linha != null && linha['vs'] != null) {
          final vehicles = linha['vs'] as List;

          List<Marker> markers = vehicles.map((v) {
            return Marker(
              width: 40,
              height: 40,
              point: LatLng(v['py'], v['px']),
              builder: (ctx) => const Icon(Icons.directions_bus, color: Colors.blue, size: 30),
            );
          }).toList();

          setState(() {
            _busMarkers = markers;
            if (vehicles.isNotEmpty) {
              _center = LatLng(vehicles[0]['py'], vehicles[0]['px']);
              _mapController.move(_center, 13);
            }
          });
        } else {
          setState(() {
            _busMarkers = [];
          });
        }
      }
    } catch (e) {
      print('Erro ao buscar veículos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(center: _center, zoom: 13),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: _busMarkers),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: () {
              if (_linhaId != null) {
                _fetchVehicles(_linhaId!);
              }
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
