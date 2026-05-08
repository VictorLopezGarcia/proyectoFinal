const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require(path.resolve(
  __dirname,
  '..',
  'rentmystuff-9456d-firebase-adminsdk-fbsvc-1c808afa91.json',
));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'rentmystuff-9456d',
});

const db = admin.firestore();
const ts = admin.firestore.FieldValue.serverTimestamp;
const Timestamp = admin.firestore.Timestamp;

// Picsum photo helper — deterministic seed per item
const photo = (seed, w = 400, h = 300) => `https://picsum.photos/seed/${seed}/${w}/${h}`;

async function seed() {
  console.log('🌱 Seeding Firestore...\n');

  // ─── USERS ────────────────────────────────────────────────────────────────
  const users = [
    { id: 'u1', displayName: 'María García',    email: 'maria@demo.com',   bio: 'Apasionada del bricolaje y los viajes. Comparto mis cosas con mucho cariño.',          averageRating: 4.8, totalRentals: 22 },
    { id: 'u2', displayName: 'Carlos López',    email: 'carlos@demo.com',  bio: 'Fotógrafo aficionado. Siempre buscando equipos para el próximo proyecto.',             averageRating: 4.3, totalRentals: 9  },
    { id: 'u3', displayName: 'Ana Martínez',    email: 'ana@demo.com',     bio: 'Deportista y aventurera. Me encanta explorar la naturaleza.',                           averageRating: 4.6, totalRentals: 14 },
    { id: 'u4', displayName: 'Pedro Sánchez',   email: 'pedro@demo.com',   bio: 'Músico y técnico de sonido. Tengo equipo de calidad para alquilar.',                   averageRating: 4.9, totalRentals: 31 },
    { id: 'u5', displayName: 'Laura Fernández', email: 'laura@demo.com',   bio: 'Decoradora de interiores. Tengo mil cosas de hogar que no uso.',                       averageRating: 4.1, totalRentals: 7  },
    { id: 'u6', displayName: 'Javier Torres',   email: 'javier@demo.com',  bio: 'Mecánico y aficionado al motor. Herramientas profesionales disponibles.',              averageRating: 4.7, totalRentals: 18 },
    { id: 'u7', displayName: 'Sofía Ruiz',      email: 'sofia@demo.com',   bio: 'Chef casera. Tengo utensilios de cocina que uso poco y puedo compartir.',              averageRating: 4.4, totalRentals: 11 },
    { id: 'u8', displayName: 'Miguel Díaz',     email: 'miguel@demo.com',  bio: 'Viajero empedernido. Tengo equipo de camping de primera calidad.',                     averageRating: 4.2, totalRentals: 6  },
  ];

  for (const u of users) {
    const { id, ...data } = u;
    await db.collection('users').doc(id).set({ ...data, photoUrl: '' });
    console.log(`  👤 User: ${data.displayName}`);
  }

  // ─── ITEMS ────────────────────────────────────────────────────────────────
  const items = [
    // Herramientas
    { id: 'item_01', title: 'Taladro Bosch Professional 18V',      desc: 'Taladro percutor inalámbrico con maletín y set de 40 brocas incluidas. Ideal para reformas.',    price: 8,   cat: 'herramientas', owner: 'u6', seed: 'bosch-drill'    },
    { id: 'item_02', title: 'Sierra de calar Makita',               desc: 'Sierra de calar pendular con 5 velocidades y guía láser. Incluye hojas para madera y metal.',     price: 10,  cat: 'herramientas', owner: 'u6', seed: 'makita-saw'     },
    { id: 'item_03', title: 'Andamio de aluminio 3 metros',         desc: 'Andamio ligero y estable para trabajos en altura. Capacidad 200 kg.',                             price: 20,  cat: 'herramientas', owner: 'u1', seed: 'scaffold'        },
    { id: 'item_04', title: 'Compresor de aire 50L',                desc: 'Compresor silencioso 8 bar, 50 litros. Ideal para pintar, inflar y limpiar.',                     price: 12,  cat: 'herramientas', owner: 'u6', seed: 'compressor'      },
    // Deporte
    { id: 'item_05', title: 'Bicicleta de montaña Trek 29"',        desc: 'MTB 29 pulgadas talla M, suspensión delantera, frenos hidráulicos. Perfecta para rutas.',         price: 18,  cat: 'deporte',      owner: 'u3', seed: 'mtb-bike'       },
    { id: 'item_06', title: 'Tabla de surf 7\'2 Malibu',            desc: 'Tabla longboard ideal para principiantes e intermedios. Incluye leash y funda.',                  price: 22,  cat: 'deporte',      owner: 'u3', seed: 'surfboard'      },
    { id: 'item_07', title: 'Kit de esquí completo talla 42',        desc: 'Esquís Head 170cm, botas Salomon talla 42, bastones y casco incluidos.',                          price: 35,  cat: 'deporte',      owner: 'u8', seed: 'ski-kit'         },
    { id: 'item_08', title: 'Kayak doble con remos',                desc: 'Kayak hinchable de alta resistencia para 2 personas. Incluye remos y bomba.',                     price: 28,  cat: 'deporte',      owner: 'u8', seed: 'kayak'           },
    // Fotografía
    { id: 'item_09', title: 'Canon EOS R6 + objetivo 24-105mm',     desc: 'Cámara mirrorless full frame con objetivo L series. Perfecta para eventos y paisajes.',           price: 55,  cat: 'fotografía',   owner: 'u2', seed: 'canon-r6'       },
    { id: 'item_10', title: 'DJI Mavic 3 Pro drone',                desc: 'Drone con cámara Hasselblad 4/3", 43min de vuelo, obstáculos. Incluye 3 baterías.',               price: 70,  cat: 'fotografía',   owner: 'u2', seed: 'dji-drone'       },
    { id: 'item_11', title: 'Kit iluminación estudio 3 focos',      desc: 'Kit softbox 80x80 + stripbox + paraguas. Ideal para retratos y producto.',                        price: 25,  cat: 'fotografía',   owner: 'u2', seed: 'studio-lights'  },
    { id: 'item_12', title: 'GoPro Hero 12 Black',                  desc: 'Cámara de acción 5.3K, estabilización HyperSmooth 6.0. Incluye carcasa submarina y accesorios.',  price: 18,  cat: 'fotografía',   owner: 'u2', seed: 'gopro'           },
    // Electrónica
    { id: 'item_13', title: 'Proyector Epson 4K 3500 lúmenes',      desc: 'Proyector laser con pantalla 100" incluida. Ideal para presentaciones y cine en casa.',           price: 40,  cat: 'electrónica',  owner: 'u1', seed: 'projector'      },
    { id: 'item_14', title: 'PlayStation 5 con 10 juegos',          desc: 'PS5 edición disco con 10 juegos AAA incluidos. Disponible para fines de semana.',                  price: 20,  cat: 'electrónica',  owner: 'u5', seed: 'ps5'             },
    { id: 'item_15', title: 'Ordenador portátil MacBook Pro M3',    desc: 'MacBook Pro 14" M3, 16GB RAM, 512GB SSD. Para proyectos de diseño o edición de vídeo.',            price: 50,  cat: 'electrónica',  owner: 'u2', seed: 'macbook'         },
    // Música
    { id: 'item_16', title: 'Guitarra eléctrica Fender Stratocaster', desc: 'Fender Strat American Standard sunburst. Incluye amplificador Fender Blues Jr.',              price: 30,  cat: 'música',       owner: 'u4', seed: 'fender-strat'    },
    { id: 'item_17', title: 'Teclado Roland FP-90X con soporte',    desc: 'Piano digital 88 teclas pesadas, 700 sonidos. Incluye soporte en X y pedal de sustain.',          price: 25,  cat: 'música',       owner: 'u4', seed: 'roland-piano'   },
    { id: 'item_18', title: 'Sistema de PA JBL PRX835W',            desc: 'Sistema de PA activo 2000W, subwoofer incluido. Perfecto para eventos hasta 400 personas.',       price: 80,  cat: 'música',       owner: 'u4', seed: 'jbl-pa'          },
    { id: 'item_19', title: 'Batería acústica Pearl Export',        desc: 'Batería completa de 5 piezas con platillos Zildjian. Lista para tocar.',                          price: 35,  cat: 'música',       owner: 'u4', seed: 'drum-kit'        },
    // Hogar
    { id: 'item_20', title: 'Aspiradora Dyson V15 Detect',          desc: 'Aspiradora inalámbrica con sensor de polvo láser. 60min de autonomía.',                           price: 12,  cat: 'hogar',        owner: 'u5', seed: 'dyson-v15'       },
    { id: 'item_21', title: 'Máquina de coser Singer Profesional',  desc: 'Singer Heavy Duty 4452 con 32 puntadas. Ideal para costura básica y telas gruesas.',              price: 10,  cat: 'hogar',        owner: 'u5', seed: 'sewing-machine'  },
    { id: 'item_22', title: 'Escalera telescópica 6.2m',            desc: 'Escalera de aluminio extensible con plataforma antideslizante. Hasta 150kg.',                     price: 15,  cat: 'hogar',        owner: 'u1', seed: 'ladder'          },
    // Cocina
    { id: 'item_23', title: 'KitchenAid Artisan 4.8L con accesorios', desc: 'Robot de cocina con batidor, gancho y paleta. Incluye picadora y exprimidor.',               price: 14,  cat: 'cocina',       owner: 'u7', seed: 'kitchenaid'      },
    { id: 'item_24', title: 'Thermomix TM6',                        desc: 'Robot de cocina multifunción guiado. Con recetario digital Cookidoo incluido.',                   price: 18,  cat: 'cocina',       owner: 'u7', seed: 'thermomix'       },
    { id: 'item_25', title: 'Máquina de pasta fresca eléctrica',    desc: 'Philips Pasta Maker Plus con 8 moldes incluidos. Lista en 15 minutos.',                           price: 8,   cat: 'cocina',       owner: 'u7', seed: 'pasta-maker'     },
    // Jardín
    { id: 'item_26', title: 'Cortacésped Honda HRG416',             desc: 'Cortacésped autopropulsado con depósito 50L. Ancho de corte 41cm.',                               price: 20,  cat: 'jardín',       owner: 'u1', seed: 'lawnmower'       },
    { id: 'item_27', title: 'Motosierra Stihl MS 251',              desc: 'Motosierra de 45cm de espada. Ideal para talar árboles medianos y grandes.',                      price: 22,  cat: 'jardín',       owner: 'u6', seed: 'chainsaw'        },
    // Viaje
    { id: 'item_28', title: 'Tienda de campaña Coleman 4 personas', desc: 'Tienda impermeable 3000mm, instalación 60s. Incluye bolsa de transporte y clavos.',               price: 15,  cat: 'viaje',        owner: 'u8', seed: 'tent'             },
    { id: 'item_29', title: 'Mochila trekking Osprey 65L',          desc: 'Mochila técnica con marco interno ajustable, funda lluvia y compartimento hidratación.',          price: 8,   cat: 'viaje',        owner: 'u8', seed: 'osprey-pack'     },
    { id: 'item_30', title: 'Portaequipaje de techo con barras',    desc: 'Sistema de barras universales Thule + caja de 420L. Compatible con todos los coches.',            price: 18,  cat: 'vehículos',    owner: 'u3', seed: 'thule-box'       },
    // Moda / Infantil
    { id: 'item_31', title: 'Traje de neopreno 5mm talla M',        desc: 'Traje de surf/buceo de 5mm con capucha. Agua fría hasta 10°C.',                                  price: 12,  cat: 'moda',         owner: 'u3', seed: 'wetsuit'         },
    { id: 'item_32', title: 'Silla de paseo Bugaboo Fox 3',         desc: 'Silla de paseo todoterreno plegable en 1 movimiento. Incluye capazo y saco de pies.',             price: 10,  cat: 'infantil',     owner: 'u5', seed: 'bugaboo'         },
  ];

  for (let i = 0; i < items.length; i++) {
    const { id, title, desc, price, cat, owner, seed: s } = items[i];
    await db.collection('items').doc(id).set({
      title,
      description: desc,
      photos: [photo(s, 800, 600)],
      pricePerDay: price,
      category: cat,
      ownerId: owner,
      status: 'available',
      createdAt: ts(),
    });
    console.log(`  📦 Item: ${title}`);
  }

  // ─── RATINGS ──────────────────────────────────────────────────────────────
  const ratings = [
    { id: 'rat_01', toUserId: 'u6', fromUserId: 'u2', reservationId: 'res_01', score: 5, comment: 'El taladro llegó perfecto y Carlos fue muy puntual. ¡100% recomendable!' },
    { id: 'rat_02', toUserId: 'u1', fromUserId: 'u3', reservationId: 'res_02', score: 5, comment: 'La escalera estaba en perfecto estado. Muy amable y flexible con los horarios.' },
    { id: 'rat_03', toUserId: 'u3', fromUserId: 'u1', reservationId: 'res_03', score: 4, comment: 'La bici en buen estado, aunque llegó con poca presión en las ruedas.' },
    { id: 'rat_04', toUserId: 'u4', fromUserId: 'u5', reservationId: 'res_04', score: 5, comment: 'El equipo de sonido impresionante. Pedro fue de gran ayuda en la instalación.' },
    { id: 'rat_05', toUserId: 'u2', fromUserId: 'u6', reservationId: 'res_05', score: 4, comment: 'Buena cámara, bien explicada. Devolví con algún arañazo menor que ya estaba.' },
    { id: 'rat_06', toUserId: 'u7', fromUserId: 'u8', reservationId: 'res_06', score: 5, comment: 'La Thermomix perfecta y Sofía super atenta. Volveré a alquilar seguro.' },
    { id: 'rat_07', toUserId: 'u6', fromUserId: 'u3', reservationId: 'res_07', score: 5, comment: 'Herramientas de calidad profesional. Javier resolvió todas mis dudas.' },
    { id: 'rat_08', toUserId: 'u1', fromUserId: 'u2', reservationId: 'res_08', score: 5, comment: 'María es una crack. El proyector funcionó a la perfección para la presentación.' },
  ];

  for (const r of ratings) {
    const { id, ...data } = r;
    await db.collection('ratings').doc(id).set({ ...data, createdAt: ts() });
    console.log(`  ⭐ Rating: ${data.fromUserId} → ${data.toUserId} (${data.score}/5)`);
  }

  // ─── RESERVATIONS ─────────────────────────────────────────────────────────
  const reservations = [
    { id: 'res_01', itemId: 'item_01', renterId: 'u2', ownerId: 'u6', status: 'completed', start: '2026-03-10', end: '2026-03-14', totalPrice: 32 },
    { id: 'res_02', itemId: 'item_22', renterId: 'u3', ownerId: 'u1', status: 'completed', start: '2026-03-20', end: '2026-03-22', totalPrice: 30 },
    { id: 'res_03', itemId: 'item_05', renterId: 'u1', ownerId: 'u3', status: 'completed', start: '2026-04-01', end: '2026-04-03', totalPrice: 36 },
    { id: 'res_04', itemId: 'item_18', renterId: 'u5', ownerId: 'u4', status: 'completed', start: '2026-04-05', end: '2026-04-06', totalPrice: 80 },
    { id: 'res_05', itemId: 'item_09', renterId: 'u6', ownerId: 'u2', status: 'completed', start: '2026-04-10', end: '2026-04-12', totalPrice: 110 },
    { id: 'res_06', itemId: 'item_24', renterId: 'u8', ownerId: 'u7', status: 'completed', start: '2026-04-15', end: '2026-04-17', totalPrice: 36 },
    { id: 'res_07', itemId: 'item_02', renterId: 'u3', ownerId: 'u6', status: 'completed', start: '2026-04-18', end: '2026-04-20', totalPrice: 20 },
    { id: 'res_08', itemId: 'item_13', renterId: 'u2', ownerId: 'u1', status: 'completed', start: '2026-04-22', end: '2026-04-23', totalPrice: 40 },
    { id: 'res_09', itemId: 'item_10', renterId: 'u1', ownerId: 'u2', status: 'confirmed', start: '2026-05-10', end: '2026-05-12', totalPrice: 140 },
    { id: 'res_10', itemId: 'item_07', renterId: 'u5', ownerId: 'u8', status: 'pending',   start: '2026-05-20', end: '2026-05-25', totalPrice: 175 },
  ];

  for (const r of reservations) {
    const { id, start, end, ...data } = r;
    await db.collection('reservations').doc(id).set({
      ...data,
      startDate: Timestamp.fromDate(new Date(start)),
      endDate: Timestamp.fromDate(new Date(end)),
      createdAt: ts(),
    });
    console.log(`  📅 Reservation: ${id} (${data.status})`);
  }

  // ─── CHATS ────────────────────────────────────────────────────────────────
  const chats = [
    {
      users: ['u2', 'u6'],
      messages: [
        { from: 'u2', text: '¡Hola Javier! ¿El taladro viene con brocas de madera?' },
        { from: 'u6', text: 'Hola Carlos. Sí, incluye un set de 20 brocas de madera, metal y piedra.' },
        { from: 'u2', text: 'Perfecto, lo reservo para la semana que viene.' },
        { from: 'u6', text: '¡Genial! Si necesitas ayuda con el montaje dime.' },
      ],
    },
    {
      users: ['u3', 'u4'],
      messages: [
        { from: 'u3', text: 'Hola Pedro, necesito el sistema de PA para un evento el 15 de mayo.' },
        { from: 'u4', text: 'Hola Ana, claro que sí. ¿Cuántas personas serán aproximadamente?' },
        { from: 'u3', text: 'Unos 150 en exterior.' },
        { from: 'u4', text: 'Perfecto para el PRX. Te explico la conexión sin problema.' },
      ],
    },
    {
      users: ['u1', 'u2'],
      messages: [
        { from: 'u1', text: 'Buenos días Carlos, el proyector está disponible para esas fechas.' },
        { from: 'u2', text: 'Genial María, ¿incluye la pantalla?' },
        { from: 'u1', text: 'Sí, pantalla de 100 pulgadas enrollable incluida.' },
        { from: 'u2', text: 'Perfecto, confirmo la reserva.' },
      ],
    },
    {
      users: ['u7', 'u8'],
      messages: [
        { from: 'u8', text: 'Sofía, ¿está disponible la Thermomix este fin de semana?' },
        { from: 'u7', text: 'Sí Miguel, este sábado está libre. ¿Te viene bien a las 10?' },
        { from: 'u8', text: 'Perfecto. Muchas gracias!' },
      ],
    },
  ];

  for (const chat of chats) {
    const participants = chat.users.sort();
    const chatId = participants.join('_');
    const lastMsg = chat.messages[chat.messages.length - 1];

    await db.collection('chats').doc(chatId).set({
      participants,
      lastMessage: lastMsg.text,
      updatedAt: ts(),
    });

    for (const msg of chat.messages) {
      await db.collection('chats').doc(chatId).collection('messages').add({
        senderId: msg.from,
        text: msg.text,
        timestamp: ts(),
      });
    }
    console.log(`  💬 Chat: ${chatId} (${chat.messages.length} messages)`);
  }

  console.log('\n✅ Seed completo! Datos de prueba listos.\n');
  console.log('Usuarios de prueba:');
  users.forEach(u => console.log(`  • ${u.displayName} <${u.email}>`));
  console.log('\nNota: Los usuarios de seed NO tienen contraseña en Firebase Auth.');
  console.log('Regístrate en la app y usa esos UIDs como referencia, o crea usuarios reales.\n');
}

seed().catch(console.error);
