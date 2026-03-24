# RentMyStuff

Plataforma P2P de alquiler de objetos entre particulares.

## Stack Tecnológico

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Auth, Storage)
- **Infraestructura Local:** Docker Compose

## Requisitos Previos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y en ejecución
- (Opcional) Flutter SDK 3.38+ si quieres ejecutar sin Docker

## Arrancar el Proyecto (Desarrollo)

Un solo comando levanta todo el entorno:

```bash
docker compose up --build
```

| Servicio | URL |
|---|---|
| App Flutter (web) | http://localhost:3000 |
| Firebase Emulator UI | http://localhost:4000 |
| Firestore | localhost:8080 |
| Auth | localhost:9099 |
| Storage | localhost:9199 |

## Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/       # Constantes de app y Firebase
│   ├── errors/          # Excepciones personalizadas
│   ├── router/          # GoRouter config
│   └── theme/           # Material Design 3 theme
├── features/
│   ├── auth/            # Autenticación
│   ├── items/           # CRUD de objetos
│   ├── reservations/    # Sistema de reservas
│   ├── chat/            # Chat en tiempo real
│   └── profile/         # Perfil y valoraciones
└── main.dart

firebase/
├── firebase.json        # Config emuladores
├── firestore.rules      # Reglas de seguridad Firestore
├── firestore.indexes.json
├── storage.rules        # Reglas de Storage
└── seed.js              # Datos de prueba

docker/
├── firebase/Dockerfile  # Imagen emuladores Firebase
└── flutter/Dockerfile   # Imagen Flutter web dev
```

## Arquitectura

- **Clean Architecture** con separación por features
- **Riverpod** como gestor de estado
- **GoRouter** para navegación declarativa
- **Freezed** para modelos inmutables con serialización JSON
- **Material Design 3** con tema dinámico (claro/oscuro)
