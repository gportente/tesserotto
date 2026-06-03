class CardLocation {
  final int? id;
  final String cardId;
  final String address;
  final double lat;
  final double lng;
  final double radius;

  const CardLocation({
    this.id,
    required this.cardId,
    required this.address,
    required this.lat,
    required this.lng,
    this.radius = 200.0,
  });

  CardLocation copyWith({
    int? id,
    String? cardId,
    String? address,
    double? lat,
    double? lng,
    double? radius,
  }) {
    return CardLocation(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'card_id': cardId,
        'address': address,
        'lat': lat,
        'lng': lng,
        'radius': radius,
      };

  factory CardLocation.fromMap(Map<String, dynamic> map) => CardLocation(
        id: map['id'] as int?,
        cardId: map['card_id'] as String,
        address: map['address'] as String,
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        radius: (map['radius'] as num?)?.toDouble() ?? 200.0,
      );
}
