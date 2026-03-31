class MessierObject {
  final String id;
  final String name;
  final String type;
  final String distance;
  final String constellationLatin;
  final double magnitude;
  final double raHours;
  final double decDegrees;

  const MessierObject({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.constellationLatin,
    required this.magnitude,
    required this.raHours,
    required this.decDegrees,
  });

  MessierObject copyWith({
    String? name,
    String? type,
  }) {
    return MessierObject(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      distance: distance,
      constellationLatin: constellationLatin,
      magnitude: magnitude,
      raHours: raHours,
      decDegrees: decDegrees,
    );
  }
}
