# SORA APP - Documentacion del Proyecto

Aplicacion movil Flutter para diseno y cotizacion de prendas personalizadas con talleres de confeccion en Peru.

---

## Tabla de Contenidos

1. Descripcion General
2. Tecnologias y Dependencias
3. Arquitectura del Proyecto
4. Modelos de Datos
5. Providers (Gestion de Estado)
6. Repositorios de Datos
7. Sistema de Rutas y Navegacion
8. Pantallas y Flujo de Usuario
9. Sistema de Diseno Visual
10. Flujo Completo de la App
11. Talleres Registrados
12. Como Ejecutar el Proyecto

---

## 1. Descripcion General

**SORA** es una aplicacion movil desarrollada en Flutter que permite a los usuarios:

- **Disenar prendas personalizadas** paso a paso (tipo de prenda, colores, cortes, logos, tela y detalles).
- **Explorar talleres de confeccion** del Peru con sus especialidades, calificaciones y precios.
- **Solicitar cotizaciones** comparativas de multiples talleres o directamente con uno preseleccionado.
- **Gestionar pedidos** con estados de seguimiento (cotizado / confirmado).

La app funciona completamente **offline** con datos en memoria (mock), sin backend real por el momento.

---

## 2. Tecnologias y Dependencias

| Tecnologia     | Version | Uso                                    |
|----------------|---------|----------------------------------------|
| Flutter        | >= 3.x  | Framework principal                    |
| Dart           | >= 3.x  | Lenguaje de programacion               |
| provider       | ^6.x    | Gestion de estado reactivo             |
| go_router      | ^14.x   | Navegacion declarativa con deep links  |

---

## 3. Arquitectura del Proyecto

La app sigue una arquitectura **Feature-First** con separacion clara de responsabilidades:

```
lib/
+-- main.dart                            # Punto de entrada, configuracion de Providers
+-- core/
|   +-- routes/
|   |   +-- sora_router.dart             # Configuracion global de rutas (GoRouter)
|   +-- shell/
|   |   +-- main_shell.dart              # Shell con BottomNavigationBar
|   +-- theme/
|       +-- sora_colors.dart             # Paleta de colores SORA
|       +-- sora_theme.dart              # ThemeData global de la app
+-- data/
|   +-- talleres_repository.dart         # Datos mock de talleres (singleton)
|   +-- pedidos_repository.dart          # Almacen en memoria de pedidos (singleton)
+-- models/
|   +-- diseno_personalizado.dart        # Modelo del diseno + todos sus enums
|   +-- taller.dart                      # Modelo de taller, cotizacion, pedido
+-- features/
    +-- home/
    |   +-- home_screen.dart
    +-- disenador/
    |   +-- disenador_provider.dart      # Estado del flujo de diseno
    |   +-- disenador_screen.dart        # Pantalla principal del disenador
    |   +-- diseno_listo_screen.dart     # Resumen del diseno completado
    |   +-- pasos/
    |   |   +-- paso1_prenda.dart
    |   |   +-- paso2_colores.dart
    |   |   +-- paso3_panel.dart
    |   |   +-- paso4_logos.dart
    |   |   +-- paso5_tela.dart
    |   |   +-- paso6_detalles.dart
    |   +-- widgets/
    |       +-- preview_prenda.dart      # Vista previa 2D de la prenda
    +-- cotizacion/
    |   +-- cotizacion_provider.dart
    |   +-- distribucion_tallas_screen.dart
    |   +-- cotizacion_screen.dart
    +-- talleres/
    |   +-- talleres_screen.dart
    |   +-- taller_detalle_screen.dart
    +-- pedidos/
    |   +-- pedidos_screen.dart
    +-- perfil/
        +-- perfil_screen.dart
```

### Patron utilizado: Provider + Repository

```
UI (Widgets)
    |  watch / read
    v
Provider  (estado reactivo, ChangeNotifier)
    |  llama a
    v
Repository  (datos en memoria, singleton)
    |  retorna
    v
Models  (clases Dart puras, inmutables)
```

---

## 4. Modelos de Datos

### 4.1 DisenoPersonalizado  --  lib/models/diseno_personalizado.dart

Modelo central que almacena todas las opciones de una prenda personalizada.

| Campo               | Tipo                  | Descripcion                                      |
|---------------------|-----------------------|--------------------------------------------------|
| prenda              | TipoPrenda            | Tipo de prenda elegida                           |
| colorPrincipal      | Color                 | Color principal de la prenda                     |
| colorAccento        | Color                 | Color de acento / contraste                      |
| colorMangas         | Color                 | Color de mangas                                  |
| colorCuello         | Color                 | Color del cuello                                 |
| panel               | TipoPanel             | Corte del panel (liso, dividido, diagonal, rayas)|
| posicionesLogo      | List<PosicionLogo>    | Ubicaciones del logo                             |
| textoLogo           | String                | Texto personalizado del logo                     |
| tela                | TipoTela              | Material de confeccion                           |
| tieneCierreMetal    | bool                  | Extra: cierre metalico                           |
| tieneCierrePlastico | bool                  | Extra: cierre plastico                           |
| tieneBolsilloLateral| bool                  | Extra: bolsillo lateral                          |
| tieneBolsilloPecho  | bool                  | Extra: bolsillo en pecho                         |
| tieneBolsilloInterno| bool                  | Extra: bolsillo interno                          |
| largo               | LargoPrenda           | Largo (corto/midi/largo) para vestidos/inferiores|
| tipoEscote          | TipoEscote            | Escote (redondo, V, camisero) para vestidos      |
| tipoManga           | TipoManga             | Manga (sin mangas, corta, larga)                 |
| tipoCintura         | TipoCintura           | Cintura (elastica, clasica, tiro alto)           |
| tecnicaLogo         | TecnicaConfeccion     | Bordado o estampado                              |
| tamanoLogo          | TamanoLogo            | Pequeno / Mediano / Grande                       |
| logoPath            | String?               | Ruta del logo subido                             |
| logoBytes           | Uint8List?            | Bytes del logo                                   |

#### Enums del modelo DisenoPersonalizado

| Enum              | Valores                                                               |
|-------------------|-----------------------------------------------------------------------|
| CategoriaPrenda   | superior, inferior, vestido, uniforme                                 |
| TipoPrenda        | casaca, polo, polera, camisa, pantalon, short, falda, vestido, buzo, uniforme |
| TipoTela          | taslan, polar, algodon, lino, denim, gabardina                        |
| TipoPanel         | liso, dividido, diagonal, rayas                                       |
| LargoPrenda       | corto, midi, largo                                                    |
| TipoEscote        | redondo, enV, camisero                                                |
| TipoManga         | sinMangas, corta, larga                                               |
| TipoCintura       | elastica, clasica, tiroAlto                                           |
| PosicionLogo      | pecho, espalda, mangas                                                |
| TecnicaConfeccion | bordado, estampado                                                    |
| TamanoLogo        | pequeno, mediano, grande                                              |
| Talla             | XS, S, M, L, XL, XXL                                                 |

---

### 4.2 Taller  --  lib/models/taller.dart

| Campo              | Tipo                    | Descripcion                   |
|--------------------|-------------------------|-------------------------------|
| id                 | String                  | Identificador unico           |
| nombre             | String                  | Nombre del taller             |
| ciudad             | String                  | Ciudad donde opera            |
| calificacion       | double                  | Calificacion 1.0 - 5.0        |
| plazoDias          | int                     | Dias de entrega estimados     |
| tablaPrecios       | TablaPrecios            | Estructura de precios         |
| descripcion        | String                  | Descripcion del taller        |
| prendas            | List<TipoPrenda>        | Prendas que confecciona       |
| tecnicas           | List<TecnicaConfeccion> | Tecnicas disponibles          |
| direccion          | String                  | Direccion fisica              |
| telefono           | String                  | Telefono de contacto          |
| pedidosCompletados | int                     | Historial de pedidos          |

### 4.3 TablaPrecios  --  Formula de calculo

```
precio_por_unidad = precioBase
                  + tela.costoExtra x multiplicadorTela
                  + costo_tecnica_logo x tamanoLogo.multiplicador  (si hay logo)
                  + extras (cierres, bolsillos)
```

| Campo               | Descripcion                                   |
|---------------------|-----------------------------------------------|
| precioBase          | Precio minimo por prenda                      |
| multiplicadorTela   | Factor aplicado al costo extra de la tela     |
| costoBordado        | Costo por tecnica de bordado                  |
| costoEstampado      | Costo por tecnica de estampado                |
| costoCierreMetal    | Adicional por cierre metalico                 |
| costoCierrePlastico | Adicional por cierre plastico                 |
| costoBolsilloLateral| Adicional por bolsillo lateral                |
| costoBolsilloPecho  | Adicional por bolsillo pecho                  |
| costoBolsilloInterno| Adicional por bolsillo interno                |

### 4.4 Cotizacion

| Campo          | Tipo   | Descripcion                             |
|----------------|--------|-----------------------------------------|
| taller         | Taller | Taller cotizante                        |
| precioPorUnidad| double | Costo calculado por prenda              |
| totalUnidades  | int    | Cantidad total de prendas               |
| total          | double | precioPorUnidad x totalUnidades         |

### 4.5 Pedido

| Campo        | Tipo                  | Descripcion                         |
|--------------|-----------------------|-------------------------------------|
| id           | String                | ID unico (timestamp en ms)          |
| diseno       | DisenoPersonalizado   | Diseno de la prenda                 |
| items        | List<PedidoItem>      | Distribucion de tallas y cantidades |
| cotizacion   | Cotizacion            | Cotizacion con el taller elegido    |
| estado       | EstadoPedido          | cotizado o confirmado               |
| fechaCreacion| DateTime              | Fecha del pedido                    |

#### EstadoPedido

| Estado    | Cuando se asigna                                                          |
|-----------|---------------------------------------------------------------------------|
| cotizado  | Pedido generado con taller preseleccionado desde la pantalla de tallas    |
| confirmado| Pedido confirmado por el usuario desde la pantalla comparativa de talleres|

---

## 5. Providers (Gestion de Estado)

### 5.1 DisenadorProvider  --  lib/features/disenador/disenador_provider.dart

Gestiona el flujo de 6 pasos del disenador y el taller preseleccionado.

| Propiedad / Metodo              | Descripcion                                          |
|---------------------------------|------------------------------------------------------|
| diseno                          | Diseno actual en construccion                        |
| pasoActual                      | Paso activo (0 - 5)                                  |
| tallerPreseleccionado           | Taller elegido desde la pantalla de talleres         |
| tieneTallerPreseleccionado      | true si hay un taller guardado                       |
| avanzarPaso()                   | Avanza al siguiente paso                             |
| retrocederPaso()                | Regresa al paso anterior                             |
| irAPaso(int)                    | Salta a un paso especifico                           |
| actualizarDiseno(nuevo)         | Actualiza el diseno con nuevas opciones              |
| preseleccionarTaller(taller)    | Guarda el taller elegido y adapta la prenda          |
| limpiarTallerPreseleccionado()  | Elimina el taller preseleccionado                    |
| reiniciar()                     | Restablece el diseno y vuelve al paso 0              |

### 5.2 CotizacionProvider  --  lib/features/cotizacion/cotizacion_provider.dart

Gestiona la distribucion de tallas y las cotizaciones calculadas.

| Propiedad / Metodo                      | Descripcion                                         |
|-----------------------------------------|-----------------------------------------------------|
| distribucion                            | DistribucionTallas con cantidades por talla         |
| cotizaciones                            | Lista ordenada segun el criterio activo             |
| orden                                   | Criterio de ordenamiento actual                     |
| actualizarCantidad(talla, cantidad)     | Modifica la cantidad de una talla especifica        |
| calcularCotizaciones(diseno)            | Genera cotizaciones de todos los talleres disponibles|
| cotizarConTallerEspecifico(taller, dis) | Genera cotizacion solo con un taller concreto       |
| cambiarOrden(criterio)                  | Cambia el criterio de orden                         |
| reiniciar()                             | Limpia distribucion y cotizaciones                  |

#### OrdenCotizacion

| Valor        | Descripcion                           |
|--------------|---------------------------------------|
| precio       | Ordena por precio total (menor a mayor)|
| plazo        | Ordena por dias de entrega (menor a mayor)|
| calificacion | Ordena por calificacion (mayor a menor)|

---

## 6. Repositorios de Datos

### 6.1 TalleresRepository  --  lib/data/talleres_repository.dart

Singleton con la lista de 6 talleres mockeados. No persiste entre sesiones.

```dart
final talleres = TalleresRepository.instance.talleres;
```

### 6.2 PedidosRepository  --  lib/data/pedidos_repository.dart

Singleton que almacena los pedidos en memoria durante la sesion.
Extiende ChangeNotifier para actualizar la UI reactivamente.

```dart
PedidosRepository.instance.agregarPedido(pedido);
PedidosRepository.instance.confirmarPedido(pedidoId);
PedidosRepository.instance.pedidos; // lista de pedidos
```

---

## 7. Sistema de Rutas y Navegacion

Configuracion en: lib/core/routes/sora_router.dart

### Rutas dentro del Shell (con BottomNavigationBar)

| Ruta        | Pantalla       |
|-------------|----------------|
| /           | HomeScreen     |
| /disenador  | DisenadorScreen|
| /talleres   | TalleresScreen |
| /pedidos    | PedidosScreen  |
| /perfil     | PerfilScreen   |

### Rutas fuera del Shell (pantalla completa, sin barra)

| Ruta                  | Pantalla                  | Metodo de navegacion |
|-----------------------|---------------------------|----------------------|
| /diseno-listo         | DisenoListoScreen         | context.push()       |
| /distribucion-tallas  | DistribucionTallasScreen  | context.push()       |
| /cotizacion           | CotizacionScreen          | context.push()       |

Regla de navegacion:
- context.push()  --> apila la pantalla, permite volver con la flecha de atras.
- context.go()    --> reemplaza el stack completo (usado al finalizar un pedido).

---

## 8. Pantallas y Flujo de Usuario

### HomeScreen  /
Pantalla de bienvenida con accesos rapidos al disenador, talleres y pedidos.
Muestra el conteo de pedidos activos.

### DisenadorScreen  /disenador
Wizard de 6 pasos para disenar una prenda:

| Paso | Archivo            | Descripcion                                                        |
|------|--------------------|--------------------------------------------------------------------|
| 1    | paso1_prenda.dart  | Seleccionar tipo de prenda                                         |
| 2    | paso2_colores.dart | Elegir 4 colores (principal, acento, mangas, cuello)               |
| 3    | paso3_panel.dart   | Seleccionar corte/panel, largo, escote, mangas o cintura           |
| 4    | paso4_logos.dart   | Agregar logo: imagen, texto, tecnica, tamano y posicion            |
| 5    | paso5_tela.dart    | Elegir material de confeccion                                      |
| 6    | paso6_detalles.dart| Opciones adicionales: cierres y bolsillos                          |

- Vista previa 2D de la prenda en los pasos 2-5 (PreviewPrenda widget).
- Chip de taller preseleccionado visible en toda la pantalla.
- Boton "Ver mi diseno" al finalizar el paso 6 navega a DisenoListoScreen.

### DisenoListoScreen  /diseno-listo
Resumen del diseno completado:
- Muestra vista previa, tabla de opciones elegidas y colores.
- Indica el taller preseleccionado si existe.
- "Solicitar cotizacion" / "Cotizar con [Taller]" --> navega a DistribucionTallasScreen.
- "Editar diseno" --> vuelve al disenador y reinicia.

### DistribucionTallasScreen  /distribucion-tallas
El usuario define cuantas prendas necesita por talla (XS - XXL).

Logica del boton "Solicitar cotizacion":
- CON taller preseleccionado --> cotiza con ese taller, guarda pedido como "cotizado", va a /pedidos.
- SIN taller preseleccionado --> calcula cotizaciones de todos los talleres, va a CotizacionScreen.

### CotizacionScreen  /cotizacion
Lista comparativa de talleres. Solo aparece si NO hay taller preseleccionado.
- Ordenar por Precio / Plazo / Calificacion.
- Taller mas barato marcado como "Mejor precio".
- "Elegir este taller" --> dialogo de confirmacion --> pedido "confirmado" --> /pedidos.

### TalleresScreen  /talleres
Catalogo completo de talleres con filtros por tipo de prenda y tecnica.
Cada tarjeta abre el detalle del taller.

### TallerDetalleScreen
Detalle de un taller: descripcion, direccion, telefono, estadisticas, tecnicas y prendas.
- "Cotizar con este taller" --> guarda el taller en DisenadorProvider, redirige al disenador.

### PedidosScreen  /pedidos
Historial de pedidos de la sesion: estado, taller, total y fecha.

---

## 9. Sistema de Diseno Visual

### Paleta de colores  lib/core/theme/sora_colors.dart

| Token        | Color         | Hex       | Uso                              |
|--------------|---------------|-----------|----------------------------------|
| background   | Crema         | #F0E8DC   | Fondo general de pantallas       |
| surface      | Blanco roto   | #FAF6F1   | Fondo de tarjetas                |
| cardBorder   | Beige         | #E2D5C8   | Bordes de tarjetas               |
| onBackground | Marron oscuro | #2B1C14   | Texto principal                  |
| primary      | Terracota     | #B04F36   | Botones, acentos, activos        |
| secondary    | Marron        | #7A3E27   | Acentos secundarios              |
| tertiary     | Terracota cl. | #D4845A   | Detalles terciarios              |
| disabled     | Beige apagado | #CFC0B0   | Elementos deshabilitados         |
| error        | Rojo          | #BA1A1A   | Mensajes de error                |

### Principios de diseno

- Estetica calida y artesanal, coherente con el mundo textil.
- Tarjetas con esquinas suaves (borderRadius 12-16).
- Animaciones: AnimatedContainer, AnimatedSwitcher, FadeTransition, SlideTransition.
- Botones principales: FilledButton con color terracota (#B04F36).
- Tipografia con pesos w600 - w900 para jerarquia visual clara.

---

## 10. Flujo Completo de la App

```
App Start
    |
    v
HomeScreen (/)
    |-- Ir al Disenador -----------------------------.
    |-- Ver Talleres --------------------------------.|
    |-- Ver Pedidos --------------------------------.||
    |                                               |||
    |               TalleresScreen (/talleres) -----'||
    |                    |                           ||
    |               TallerDetalleScreen              ||
    |                    |                           ||
    |       "Cotizar con este taller"                ||
    |            preseleccionarTaller()              ||
    |                    |                           ||
    |                    v                           ||
    |       DisenadorScreen (/disenador) <-----------''
    |           Paso 1 -> 2 -> 3 -> 4 -> 5 -> 6
    |                    |
    |           "Ver mi diseno"   context.push()
    |                    v
    |       DisenoListoScreen (/diseno-listo)
    |                    |
    |       "Solicitar cotizacion"   context.push()
    |                    v
    |    DistribucionTallasScreen (/distribucion-tallas)
    |                    |
    |        .-----------+-----------.
    |        | taller preseleccionado|
    |        | SI                    | NO
    |        v                       v
    | Cotizar con ese taller   CotizacionScreen
    | pedido: cotizado         Comparar talleres
    |        |                 pedido: confirmado
    |        '-----------.----------'
    |                    | context.go()
    |                    v
    '----------> PedidosScreen (/pedidos) <---------'
```

---

## 11. Talleres Registrados

La app incluye 6 talleres precargados en TalleresRepository:

| # | Nombre                    | Ciudad   | Calificacion | Plazo   | Precio Base |
|---|---------------------------|----------|--------------|---------|-------------|
| 1 | Confecciones Lima Norte   | Lima     | 4.8          | 12 dias | S/.45       |
| 2 | Textiles Arequipa SAC     | Arequipa | 4.5          | 18 dias | S/.38       |
| 3 | Moda y Estilo Trujillo    | Trujillo | 4.7          | 14 dias | S/.42       |
| 4 | KustumWear Cusco          | Cusco    | 4.6          | 20 dias | S/.40       |
| 5 | Creaciones y Moda Gamarra | Lima     | 4.9          | 10 dias | S/.36       |
| 6 | Taller Textil del Sur     | Tacna    | 4.4          | 16 dias | S/.37       |

### Prendas y tecnicas por taller

| Taller                    | Prendas                                  | Bordado | Estampado |
|---------------------------|------------------------------------------|---------|-----------|
| Confecciones Lima Norte   | Casaca, Polo, Polera, Buzo, Unif., Camisa| Si      | Si        |
| Textiles Arequipa SAC     | Polo, Vestido, Falda, Camisa, Short      | No      | Si        |
| Moda y Estilo Trujillo    | Vestido, Falda, Pantalon, Short, Camisa  | Si      | Si        |
| KustumWear Cusco          | Casaca, Polera, Buzo, Uniforme           | Si      | No        |
| Creaciones y Moda Gamarra | Polo, Camisa, Pantalon, Short, Vest.,Falda| Si     | Si        |
| Taller Textil del Sur     | Pantalon, Short, Uniforme, Casaca, Buzo  | No      | Si        |

---

## 12. Como Ejecutar el Proyecto

### Requisitos previos

- Flutter SDK (version 3.x o superior)
- Dart SDK (incluido con Flutter)
- Android Studio o VS Code con extension Flutter
- Dispositivo Android/iOS o emulador activo

### Pasos

```bash
# 1. Ir al directorio del proyecto
cd c:\Flutter-proyectos\sora_app

# 2. Obtener dependencias
flutter pub get

# 3. Verificar analisis estatico
flutter analyze

# 4. Ejecutar la app en modo debug
flutter run

# 5. Opcional: listar dispositivos y elegir uno
flutter devices
flutter run -d <id_del_dispositivo>
```

### Resultado esperado de flutter analyze

```
1 issue found.
(warning: import no usado en taller_detalle_screen.dart -- no critico)
```

---

## Archivos Clave - Referencia Rapida

| Proposito                    | Archivo                                                     |
|------------------------------|-------------------------------------------------------------|
| Punto de entrada             | lib/main.dart                                               |
| Rutas                        | lib/core/routes/sora_router.dart                            |
| Colores del tema             | lib/core/theme/sora_colors.dart                             |
| Modelo de diseno             | lib/models/diseno_personalizado.dart                        |
| Modelo de taller y pedido    | lib/models/taller.dart                                      |
| Datos de talleres (mock)     | lib/data/talleres_repository.dart                           |
| Datos de pedidos (memoria)   | lib/data/pedidos_repository.dart                            |
| Estado del disenador         | lib/features/disenador/disenador_provider.dart              |
| Estado de cotizacion         | lib/features/cotizacion/cotizacion_provider.dart            |
| Pantalla del disenador       | lib/features/disenador/disenador_screen.dart                |
| Pantalla de cotizacion       | lib/features/cotizacion/cotizacion_screen.dart              |

---

Documentacion generada para SORA App -- Flutter / Dart / Provider / GoRouter
