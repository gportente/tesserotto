class FidelityCard {
  final String id;
  final String name;
  final String description;
  final String? barcode;
  final String? barcodeType;
  final int? colorValue;
  final int openCount;
  final DateTime createdAt;

  FidelityCard({
    required this.id,
    required this.name,
    required this.description,
    this.barcode,
    this.barcodeType,
    this.colorValue,
    this.openCount = 0,
    required this.createdAt,
  });

  FidelityCard copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    String? barcodeType,
    int? colorValue,
    int? openCount,
    DateTime? createdAt,
  }) {
    return FidelityCard(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      colorValue: colorValue ?? this.colorValue,
      openCount: openCount ?? this.openCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'barcode': barcode,
        'barcodeType': barcodeType,
        'colorValue': colorValue,
        'openCount': openCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FidelityCard.fromJson(Map<String, dynamic> json) => FidelityCard(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        barcode: json['barcode'] as String?,
        barcodeType: json['barcodeType'] as String?,
        colorValue: json['colorValue'] as int?,
        openCount: json['openCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      );
} 