import 'package:flutter/material.dart';
import '../models/location.dart'; // Chỉ import từ model

class SelectLocationScreen extends StatefulWidget {
  final LocationResult? selected;
  final Function(LocationResult)? onSelected;

  const SelectLocationScreen({Key? key, this.selected, this.onSelected})
      : super(key: key);

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LocationResult? _selectedLocation;

  // Danh sách địa điểm giả lập
  final List<LocationResult> _locations = [
    LocationResult(name: 'Hà Nội', latitude: 21.0285, longitude: 105.8542),
    LocationResult(name: 'Hồ Chí Minh', latitude: 10.7626, longitude: 106.6602),
    LocationResult(name: 'Đà Nẵng', latitude: 16.0544, longitude: 108.2022),
    LocationResult(name: 'Huế', latitude: 16.4637, longitude: 107.5909),
    LocationResult(name: 'Nha Trang', latitude: 12.2388, longitude: 109.1967),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selected;
  }

  void _selectLocation(LocationResult location) {
    setState(() => _selectedLocation = location);
    if (widget.onSelected != null) widget.onSelected!(location);
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final location = _locations[index];
          final isSelected = _selectedLocation?.name == location.name;
          return ListTile(
            title: Text(location.name,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              'Lat: ${location.latitude}, Lng: ${location.longitude}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () => _selectLocation(location),
          );
        },
      ),
    );
  }
}
