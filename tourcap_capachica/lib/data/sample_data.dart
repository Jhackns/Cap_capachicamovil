import '../models/entrepreneur.dart';

final List<Entrepreneur> sampleEntrepreneurs = [
  // Hospedaje
  Entrepreneur(
    id: 1,
    name: 'Hospedaje Familiar Los Pinos',
    description: 'Acogedora casa familiar con vista al lago Titicaca. Ofrecemos habitaciones cómodas con desayuno incluido.',
    imageUrl: 'assets/images/hospedaje1.jpg',
    location: 'Llachón, Capachica',
    contactInfo: '+51 987654321',
    tipoServicio: 'Hospedaje',
    email: 'hospedajelospinos@example.com',
    horarioAtencion: 'Check-in: 13:00 - Check-out: 12:00',
    precioRango: '80-120 Soles/noche',
    categoria: 'Hospedaje',
    estado: true,
  ),
  Entrepreneur(
    id: 2,
    name: 'Cabañas del Lago',
    description: 'Cabañas rústicas con vista privilegiada al Lago Titicaca. Incluye desayuno típico.',
    imageUrl: 'assets/images/hospedaje2.jpg',
    location: 'Ccapachica, Capachica',
    contactInfo: '+51 987654322',
    tipoServicio: 'Hospedaje',
    email: 'cabanasdellago@example.com',
    horarioAtencion: '24 horas',
    precioRango: '100-150 Soles/noche',
    categoria: 'Hospedaje',
    estado: true,
  ),

  // Gastronomía
  Entrepreneur(
    id: 3,
    name: 'Restaurante Sabores del Lago',
    description: 'Deliciosa comida típica de la región preparada con ingredientes locales y frescos.',
    imageUrl: 'assets/images/restaurante1.jpg',
    location: 'Plaza de Armas, Capachica',
    contactInfo: '+51 987654323',
    tipoServicio: 'Restaurante',
    email: 'saboresdellago@example.com',
    horarioAtencion: '08:00 - 21:00',
    precioRango: '15-40 Soles por plato',
    categoria: 'Gastronomía',
    estado: true,
  ),
  Entrepreneur(
    id: 4,
    name: 'Cafetería Vista Hermosa',
    description: 'Disfruta de un delicioso café con vista al Lago Titicaca. También ofrecemos postres típicos.',
    imageUrl: 'assets/images/restaurante2.jpg',
    location: 'Mirador de Capachica',
    contactInfo: '+51 987654324',
    tipoServicio: 'Cafetería',
    email: 'vistahermosa@example.com',
    horarioAtencion: '07:00 - 20:00',
    precioRango: '5-25 Soles',
    categoria: 'Gastronomía',
    estado: true,
  ),

  // Turismo
  Entrepreneur(
    id: 5,
    name: 'Aventuras Capachica',
    description: 'Tours guiados por los lugares más hermosos de Capachica. Incluye transporte y guía turístico.',
    imageUrl: 'assets/images/turismo1.jpg',
    location: 'Oficina de Turismo, Capachica',
    contactInfo: '+51 987654325',
    tipoServicio: 'Agencia de Turismo',
    email: 'aventurascapachica@example.com',
    horarioAtencion: '06:00 - 18:00',
    precioRango: '50-150 Soles por persona',
    categoria: 'Turismo',
    estado: true,
  ),
  Entrepreneur(
    id: 6,
    name: 'Paseos en Bote Llachón',
    description: 'Disfruta de un paseo en bote por el Lago Titicaca y visita las islas cercanas.',
    imageUrl: 'assets/images/turismo2.jpg',
    location: 'Muelle de Llachón',
    contactInfo: '+51 987654326',
    tipoServicio: 'Paseos Náuticos',
    email: 'paseosllachon@example.com',
    horarioAtencion: '07:00 - 17:00',
    precioRango: '30-80 Soles por persona',
    categoria: 'Turismo',
    estado: true,
  ),

  // Artesanía
  Entrepreneur(
    id: 7,
    name: 'Artesanías Capachica',
    description: 'Productos artesanales hechos a mano por artesanos locales. Incluye textiles, cerámica y más.',
    imageUrl: 'assets/images/artesania1.jpg',
    location: 'Mercado Artesanal, Capachica',
    contactInfo: '+51 987654327',
    tipoServicio: 'Tienda de Artesanías',
    email: 'artesaniascapachica@example.com',
    horarioAtencion: '09:00 - 18:00',
    precioRango: '10-200 Soles',
    categoria: 'Artesanía',
    estado: true,
  ),
  Entrepreneur(
    id: 8,
    name: 'Tejidos Andinos',
    description: 'Hermosos tejidos hechos a mano con lana de alpaca. Productos únicos y de alta calidad.',
    imageUrl: 'assets/images/artesania2.jpg',
    location: 'Taller de Tejidos, Ccapachica',
    contactInfo: '+51 987654328',
    tipoServicio: 'Taller de Tejidos',
    email: 'tejidosandinos@example.com',
    horarioAtencion: '08:00 - 17:00',
    precioRango: '30-500 Soles',
    categoria: 'Artesanía',
    estado: true,
  ),
];

List<Entrepreneur> getEntrepreneursByCategory(String category) {
  return sampleEntrepreneurs.where((e) => e.categoria == category).toList();
}

Entrepreneur? getEntrepreneurById(int id) {
  try {
    return sampleEntrepreneurs.firstWhere((e) => e.id == id);
  } catch (e) {
    return null;
  }
}
