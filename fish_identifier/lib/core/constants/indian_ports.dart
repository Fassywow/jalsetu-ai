import 'package:google_maps_flutter/google_maps_flutter.dart';

class PortLocation {
  final String name;
  final String state;
  final LatLng coordinates;

  const PortLocation({
    required this.name,
    required this.state,
    required this.coordinates,
  });
}

class IndianPorts {
  static const List<PortLocation> ports = [
    // Major Ports
    PortLocation(
        name: "Kandla Port (Deendayal)",
        state: "Gujarat",
        coordinates: LatLng(23.0035, 70.2247)),
    PortLocation(
        name: "Mumbai Port",
        state: "Maharashtra",
        coordinates: LatLng(18.9536, 72.8543)),
    PortLocation(
        name: "JNPT (Nhava Sheva)",
        state: "Maharashtra",
        coordinates: LatLng(18.9499, 72.9514)),
    PortLocation(
        name: "Mormugao Port",
        state: "Goa",
        coordinates: LatLng(15.4132, 73.7997)),
    PortLocation(
        name: "New Mangalore Port",
        state: "Karnataka",
        coordinates: LatLng(12.9360, 74.8190)),
    PortLocation(
        name: "Cochin Port",
        state: "Kerala",
        coordinates: LatLng(9.9656, 76.2617)),
    PortLocation(
        name: "V.O. Chidambaranar Port (Tuticorin)",
        state: "Tamil Nadu",
        coordinates: LatLng(8.7633, 78.1834)),
    PortLocation(
        name: "Chennai Port",
        state: "Tamil Nadu",
        coordinates: LatLng(13.0945, 80.3025)),
    PortLocation(
        name: "Kamarajar Port (Ennore)",
        state: "Tamil Nadu",
        coordinates: LatLng(13.2625, 80.3442)),
    PortLocation(
        name: "Visakhapatnam Port",
        state: "Andhra Pradesh",
        coordinates: LatLng(17.6905, 83.2949)),
    PortLocation(
        name: "Paradip Port",
        state: "Odisha",
        coordinates: LatLng(20.2667, 86.6756)),
    PortLocation(
        name: "Kolkata Port (Syama Prasad Mookerjee)",
        state: "West Bengal",
        coordinates: LatLng(22.5487, 88.3182)),
    PortLocation(
        name: "Haldia Dock Complex",
        state: "West Bengal",
        coordinates: LatLng(22.0225, 88.0655)),

    // Minor / Intermediate Ports (Selected)
    PortLocation(
        name: "Mundra Port",
        state: "Gujarat",
        coordinates: LatLng(22.8375, 69.7125)),
    PortLocation(
        name: "Pipavav Port",
        state: "Gujarat",
        coordinates: LatLng(20.9167, 71.5000)),
    PortLocation(
        name: "Dahej Port",
        state: "Gujarat",
        coordinates: LatLng(21.7000, 72.5833)),
    PortLocation(
        name: "Hazira Port",
        state: "Gujarat",
        coordinates: LatLng(21.0833, 72.6333)),
    PortLocation(
        name: "Dhamra Port",
        state: "Odisha",
        coordinates: LatLng(20.8167, 86.9667)),
    PortLocation(
        name: "Krishnapatnam Port",
        state: "Andhra Pradesh",
        coordinates: LatLng(14.2500, 80.1333)),
    PortLocation(
        name: "Gangavaram Port",
        state: "Andhra Pradesh",
        coordinates: LatLng(17.6167, 83.2333)),
    PortLocation(
        name: "Kakinada Port",
        state: "Andhra Pradesh",
        coordinates: LatLng(16.9667, 82.2833)),
    PortLocation(
        name: "Karaikal Port",
        state: "Puducherry",
        coordinates: LatLng(10.8333, 79.8500)),
    PortLocation(
        name: "Kattupalli Port",
        state: "Tamil Nadu",
        coordinates: LatLng(13.3167, 80.3500)),
  ];
}
