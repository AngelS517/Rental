import 'package:flutter/material.dart';

class PaginaTerminos extends StatelessWidget {
  const PaginaTerminos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF0F3), // Fondo general
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(
          0xFF5A1EFF,
        ), // Color de la AppBar igual al login
        foregroundColor: Colors.white, // Color del texto de la AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0B65), // Fondo de la caja principal (azul oscuro)
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
TÉRMINOS Y CONDICIONES DE USO

1. INTRODUCCIÓN
Bienvenido(a) a nuestra aplicación de renta de vehículos. Al registrarte y utilizar nuestra plataforma, aceptas los presentes Términos y Condiciones. Este documento regula la relación entre tú como usuario (ya sea cliente o proveedor) y nosotros como plataforma intermediaria.

2. DEFINICIONES
- Plataforma: Aplicación móvil de renta de vehículos.
- Usuario: Persona registrada en la aplicación.
- Cliente: Usuario que utiliza la plataforma para buscar y rentar vehículos.
- Proveedor: Usuario que publica y ofrece sus vehículos para renta a través de la plataforma.

3. REGISTRO DE USUARIOS
- Todos los usuarios deben registrarse proporcionando información verdadera, completa y actualizada.
- El usuario debe seleccionar su tipo de cuenta al registrarse (cliente o proveedor).
- No se permite el uso de identidades falsas o múltiples cuentas sin autorización.

4. USO DE LA PLATAFORMA

4.1 Obligaciones del Cliente
- Utilizar los vehículos de manera responsable y conforme a las leyes de tránsito.
- No modificar ni dañar los vehículos.
- Devolver el vehículo en las condiciones y tiempos acordados.
- Pagar los montos acordados por el servicio.
- Notificar cualquier daño o inconveniente ocurrido durante el uso del vehículo.

4.2 Obligaciones del Proveedor
- Publicar únicamente vehículos que estén en buen estado mecánico, legal y operativo.
- Proporcionar información precisa sobre cada vehículo.
- Cumplir con las reservas aceptadas y entregar el vehículo en el lugar y hora acordados.
- Mantener los documentos del vehículo actualizados y disponibles para revisión si se solicita.

5. RESERVAS, PAGOS Y CANCELACIONES
- Las condiciones de pago y los métodos disponibles serán detallados dentro de la aplicación.
- Las reservas están sujetas a disponibilidad del vehículo.
- En caso de cancelación, se aplicarán las políticas establecidas por la plataforma y el proveedor.
- La plataforma podrá retener pagos en caso de reclamos activos hasta resolver la situación.

6. RESPONSABILIDAD Y LIMITACIÓN DE LA PLATAFORMA
- La plataforma no es propietaria de los vehículos, solo actúa como intermediaria entre clientes y proveedores.
- No somos responsables por accidentes, daños, robos o conflictos entre usuarios. Sin embargo, brindaremos asistencia en la resolución de disputas cuando sea necesario.
- Nos reservamos el derecho de suspender o cancelar cuentas que infrinjan estos términos.

7. USO DE DATOS PERSONALES
- Tu información personal será tratada conforme a nuestra Política de Privacidad.
- Los datos se utilizan únicamente para el funcionamiento y mejora del servicio, incluyendo ubicación, historial de reservas y preferencias.
- No compartimos tu información con terceros sin tu consentimiento, salvo requerimiento legal.

8. PROPIEDAD INTELECTUAL
- Todos los derechos sobre el contenido, diseño y funcionamiento de la aplicación son propiedad exclusiva de la plataforma.
- Se prohíbe la reproducción, distribución o modificación no autorizada de cualquier parte de la app.

9. MODIFICACIONES A LOS TÉRMINOS
- La plataforma se reserva el derecho de modificar estos términos en cualquier momento.
- Las modificaciones serán notificadas dentro de la aplicación. El uso continuado de la app implica aceptación de los nuevos términos.

10. CONTACTO
Para consultas, reclamos o soporte, puedes contactarnos al correo:
📧 soporte@rentalapp.com
                  ''',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Texto blanco como en los formularios
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF5A1EFF,
                  ), // Mismo color que los botones
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
