class Ratings {
  String? rating;
  String? pickUp;
  String? destination;

  Ratings({
    this.rating,
    this.pickUp,
    this.destination
  });

  factory Ratings.fromMap(Map<dynamic, dynamic> map) {
    return Ratings(
      rating: map['rating'],
      pickUp: map['pickUp'],
      destination: map['destination'],
    );
  }
}