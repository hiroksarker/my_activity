class GalleryPhoto {
  final int? id;
  final int tripId;
  final String filePath;
  final String source; // e.g., 'expense', 'journal', 'document'

  GalleryPhoto({
    this.id,
    required this.tripId,
    required this.filePath,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'filePath': filePath,
        'source': source,
      };

  factory GalleryPhoto.fromMap(Map<String, dynamic> map) => GalleryPhoto(
        id: map['id'],
        tripId: map['tripId'],
        filePath: map['filePath'],
        source: map['source'],
      );
}
