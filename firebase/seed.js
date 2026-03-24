const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'rent-my-stuff-dev',
});

const db = admin.firestore();
db.settings({ host: 'localhost:8080', ssl: false });

async function seed() {
  console.log('🌱 Seeding Firestore...');

  // --- Users ---
  const users = [
    {
      id: 'user_owner_01',
      displayName: 'María García',
      email: 'maria@demo.com',
      photoUrl: '',
      bio: 'Me encanta compartir mis cosas',
      averageRating: 4.5,
      totalRentals: 12,
    },
    {
      id: 'user_renter_01',
      displayName: 'Carlos López',
      email: 'carlos@demo.com',
      photoUrl: '',
      bio: 'Siempre buscando lo que necesito',
      averageRating: 4.2,
      totalRentals: 5,
    },
  ];

  for (const user of users) {
    const { id, ...data } = user;
    await db.collection('users').doc(id).set(data);
    console.log(`  ✅ User: ${data.displayName}`);
  }

  // --- Items ---
  const items = [
    {
      id: 'item_01',
      title: 'Taladro Bosch Professional',
      description: 'Taladro percutor con maletín y brocas incluidas.',
      photos: [],
      pricePerDay: 8.0,
      category: 'herramientas',
      ownerId: 'user_owner_01',
      status: 'available',
      approximateLocation: { lat: 40.4168, lng: -3.7038 },
      exactLocation: { lat: 40.4170, lng: -3.7035 },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'item_02',
      title: 'Bicicleta de montaña',
      description: 'MTB 29 pulgadas, talla M. Perfecta para rutas.',
      photos: [],
      pricePerDay: 15.0,
      category: 'deporte',
      ownerId: 'user_owner_01',
      status: 'available',
      approximateLocation: { lat: 40.4200, lng: -3.7100 },
      exactLocation: { lat: 40.4202, lng: -3.7098 },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'item_03',
      title: 'Cámara Canon EOS R6',
      description: 'Cámara mirrorless con objetivo 24-105mm.',
      photos: [],
      pricePerDay: 25.0,
      category: 'electrónica',
      ownerId: 'user_owner_01',
      status: 'available',
      approximateLocation: { lat: 40.4150, lng: -3.7000 },
      exactLocation: { lat: 40.4152, lng: -3.6998 },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
  ];

  for (const item of items) {
    const { id, ...data } = item;
    await db.collection('items').doc(id).set(data);
    console.log(`  ✅ Item: ${data.title}`);
  }

  // --- A sample confirmed reservation ---
  const reservation = {
    itemId: 'item_01',
    renterId: 'user_renter_01',
    ownerId: 'user_owner_01',
    startDate: admin.firestore.Timestamp.fromDate(new Date('2026-04-01')),
    endDate: admin.firestore.Timestamp.fromDate(new Date('2026-04-05')),
    status: 'confirmed',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await db.collection('reservations').doc('res_01').set(reservation);
  console.log('  ✅ Reservation: res_01 (confirmed)');

  // --- A sample chat ---
  const chatId = ['user_owner_01', 'user_renter_01'].sort().join('_');
  const messages = [
    {
      senderId: 'user_renter_01',
      text: '¡Hola! ¿El taladro viene con brocas?',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      senderId: 'user_owner_01',
      text: 'Sí, incluye un set completo de brocas.',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  ];

  for (const msg of messages) {
    await db.collection('chats').doc(chatId).collection('messages').add(msg);
  }
  await db.collection('chats').doc(chatId).set({
    participants: ['user_owner_01', 'user_renter_01'],
    lastMessage: messages[messages.length - 1].text,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`  ✅ Chat: ${chatId} (2 messages)`);

  console.log('\n🎉 Seed complete!');
}

seed().catch(console.error);
