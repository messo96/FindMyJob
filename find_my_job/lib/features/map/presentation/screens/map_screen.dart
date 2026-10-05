import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';
import '../../../jobs/domain/entities/job.dart';
import '../../../../shared/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    } 

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() => _isLoadingLocation = false);

    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        12,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(recentJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappa Offerte'),
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : jobsAsync.when(
              data: (jobs) {
                Set<Marker> markers = (jobs as List<dynamic>).map((dynamic jobData) {
                  final job = jobData as Job;
                  return Marker(
                    markerId: MarkerId(job.id),
                    position: LatLng(job.latitude, job.longitude),
                    infoWindow: InfoWindow(
                      title: job.title,
                      snippet: job.companyName,
                      onTap: () {
                        context.push('/candidate/jobs/${job.id}');
                      },
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                  );
                }).toSet();

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(45.4642, 9.1900), // Default Milano
                    zoom: 12,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object err, StackTrace? st) => Center(child: Text('Errore: $err')),
            ),
    );
  }
}
