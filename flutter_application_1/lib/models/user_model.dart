class UserModel {
  final String? nombre;
  final String? correo;
  final int? edad;
  final String? sexo;
  final double? estatura;
  final double? peso;
  final String? objetivo;
  final String? token; // Para almacenar el token de autenticación

  UserModel({
    this.nombre,
    this.correo,
    this.edad,
    this.sexo,
    this.estatura,
    this.peso,
    this.objetivo,
    this.token,
  });

  // Crear un UserModel desde un Map (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nombre: json['nombre']?.toString(),
      correo: json['correo']?.toString(),
      edad: json['edad'] is int 
          ? json['edad'] 
          : json['edad'] is String 
              ? int.tryParse(json['edad']) 
              : json['edad'] is double 
                  ? json['edad'].toInt() 
                  : null,
      sexo: json['sexo']?.toString(),
      estatura: json['estatura'] is double 
          ? json['estatura'] 
          : json['estatura'] is int 
              ? json['estatura'].toDouble() 
              : json['estatura'] is String 
                  ? double.tryParse(json['estatura']) 
                  : null,
      peso: json['peso'] is double 
          ? json['peso'] 
          : json['peso'] is int 
              ? json['peso'].toDouble() 
              : json['peso'] is String 
                  ? double.tryParse(json['peso']) 
                  : null,
      objetivo: json['objetivo']?.toString(),
      token: json['token']?.toString(),
    );
  }

  // Convertir UserModel a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'edad': edad,
      'sexo': sexo,
      'estatura': estatura,
      'peso': peso,
      'objetivo': objetivo,
      'token': token,
    };
  }

  // Crear una copia de UserModel con algunos campos cambiados
  UserModel copyWith({
    String? nombre,
    String? correo,
    int? edad,
    String? sexo,
    double? estatura,
    double? peso,
    String? objetivo,
    String? token,
  }) {
    return UserModel(
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      edad: edad ?? this.edad,
      sexo: sexo ?? this.sexo,
      estatura: estatura ?? this.estatura,
      peso: peso ?? this.peso,
      objetivo: objetivo ?? this.objetivo,
      token: token ?? this.token,
    );
  }
}