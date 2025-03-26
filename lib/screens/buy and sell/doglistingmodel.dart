import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class DogListing {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String gender;
  final String location;
  final double price;
  final String description;
  final String imageBase64; // New base64 image storage
  final String ownerId;
  final String ownerName;
  final DateTime datePosted;
  final String vaccinationCertificateBase64;

  DogListing({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.location,
    required this.price,
    required this.description,
    required this.imageBase64,
    required this.ownerId,
    required this.ownerName,
    required this.datePosted,
    required this.vaccinationCertificateBase64,
  });

  // Compatibility getter for old imageUrl references
  String get imageUrl {
    return imageBase64.isNotEmpty 
      ? 'data:image/jpeg;base64,$imageBase64' 
      : '';
  }

  factory DogListing.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    // Handle both old and new data formats
    return DogListing(
      id: documentId,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      location: data['location'] ?? '',
      vaccinationCertificateBase64: 
        data['vaccinationCertificateBase64'] ?? 
        data['vaccinationCertificate'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageBase64: 
        data['imageBase64'] ?? 
        data['imageUrl'] ?? '', // Backward compatibility
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      datePosted: (data['datePosted'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'gender': gender,
      'location': location,
      'price': price,
      'description': description,
      'imageBase64': imageBase64,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'datePosted': datePosted,
      'vaccinationCertificateBase64': vaccinationCertificateBase64,
    };
  }
}