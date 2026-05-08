# RentMyStuff

Plataforma P2P de alquiler de objetos entre particulares.

## Stack Tecnológico

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Auth, Storage)

## Requisitos Previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.38+
- [Firebase CLI](https://firebase.google.com/docs/cli) (opcional, solo para desplegar reglas/índices)

## Arrancar el Proyecto (Desarrollo)

```bash
flutter pub get
flutter run
```

Para usar Firebase Emulators en local:

```bash
cd firebase && firebase emulators:start
```

| Servicio | URL |
|---|---|
| Firebase Emulator UI | http://localhost:4000 |
| Firestore | localhost:8080 |
| Auth | localhost:9099 |
| Storage | localhost:9199 |

## Estructura del Proyecto

```
lib/
├── core/
│   ├── config/          # Configuración de emuladores
│   ├── constants/       # Constantes de app y Firebase
│   ├── errors/          # Excepciones personalizadas
│   ├── layout/          # Shell y contenedores responsive
│   ├── router/          # GoRouter config
│   ├── services/        # Servicios (compute, geocoding)
│   ├── theme/           # Material Design 3 theme
│   └── widgets/         # Widgets compartidos (mapa, location picker)
├── features/
│   ├── auth/            # Autenticación (login, registro, recuperación)
│   ├── items/           # CRUD de objetos con fotos y ubicación
│   ├── reservations/    # Sistema de reservas con bloqueo de fechas
│   ├── chat/            # Chat en tiempo real
│   ├── profile/         # Perfil propio y público
│   └── ratings/         # Valoraciones entre usuarios
└── main.dart

firebase/
├── firebase.json        # Config emuladores
├── firestore.rules      # Reglas de seguridad Firestore
├── firestore.indexes.json
├── storage.rules        # Reglas de Storage
└── seed.js              # Datos de prueba
```

## Arquitectura

- **Clean Architecture** con separación por features
- **Riverpod** como gestor de estado
- **GoRouter** para navegación declarativa
- **flutter_map** para mapas interactivos con OpenFreeMap
- **Material Design 3** con tema dinámico (claro/oscuro)
