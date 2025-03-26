import 'dart:io';
import 'dart:convert';
import 'package:borktok/screens/buy%20and%20sell/doglistingmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DogListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Static list of dogs for sale (updated to use base64)
  static List<DogListing> staticDogListings = [
    DogListing(
      id: '1',
      name: 'Max',
      vaccinationCertificateBase64: '',
      breed: 'Golden Retriever',
      age: 3,
      gender: 'Male',
      location: 'New York, NY',
      price: 1500.00,
      description:
          'Friendly and energetic Golden Retriever. Great with children and loves to play fetch. Fully vaccinated and trained.',
      imageBase64: '', // You would put base64 encoded image here
      ownerId: 'owner1',
      ownerName: 'John Doe',
      datePosted: DateTime.now().subtract(Duration(days: 5)), 
    ),
  ];

  Future<List<DogListing>> getAllDogListings() async {
    try {
      final querySnapshot = await _firestore
          .collection('dog_listings')
          .orderBy('datePosted', descending: true)
          .get();

      List<DogListing> firestoreListings = querySnapshot.docs
          .map((doc) => DogListing.fromFirestore(doc.data(), doc.id))
          .toList();

      List<DogListing> combinedListings = [
        ...staticDogListings,
        ...firestoreListings
      ];

      final uniqueListings = <DogListing>[];
      final seen = <String>{};

      for (var listing in combinedListings) {
        final key = '${listing.name}_${listing.datePosted}';
        if (!seen.contains(key)) {
          uniqueListings.add(listing);
          seen.add(key);
        }
      }

      uniqueListings.sort((a, b) => b.datePosted.compareTo(a.datePosted));

      return uniqueListings;
    } catch (e) {
      print('Error fetching dog listings: $e');
      return staticDogListings;
    }
  }

  Future<void> addDogListing(
    DogListing dogListing,
    File imageFile, {
    File? vaccinationCertificate,
  }) async {
    try {
      // Validate image file
      if (imageFile == null) {
        throw Exception('No image file provided');
      }

      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileSize = imageFile.lengthSync();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Optional: Convert vaccination certificate to base64
      String? vaccinationCertBase64;
      if (vaccinationCertificate != null) {
        final certBytes = await vaccinationCertificate.readAsBytes();
        vaccinationCertBase64 = base64Encode(certBytes);
      }

      // Create final listing with base64 images
      final finalListing = DogListing(
        id: '', // Firestore will generate the ID
        name: dogListing.name,
        breed: dogListing.breed,
        age: dogListing.age,
        gender: dogListing.gender,
        location: dogListing.location,
        price: dogListing.price,
        description: dogListing.description,
        imageBase64: imageBase64,
        ownerId: dogListing.ownerId,
        ownerName: dogListing.ownerName,
        datePosted: DateTime.now(),
        vaccinationCertificateBase64: vaccinationCertBase64 ?? '', 
      );

      // Add to Firestore
      await _firestore.collection('dog_listings').add(finalListing.toFirestore());

      print('Dog listing added successfully');
    } catch (e) {
      print('Error adding dog listing: $e');
      rethrow;
    }
  }
}