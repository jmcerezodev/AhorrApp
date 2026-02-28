class Singleton {
  // La instancia estática privada
  static final Singleton _instance = Singleton._internal();

  // Constructor privado
  Singleton._internal();

  // Factory constructor que devuelve la instancia única
  factory Singleton() {
    return _instance;
  }

  // Puedes añadir aquí cualquier variable o método que desees compartir
  double globalTotalMoney = 0;
  Map<String,dynamic> currentDate = {'month' : '','year'  : '',};
}