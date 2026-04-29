/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

// src/config/firebase.js
const admin = require('firebase-admin');

// Volta duas pastas (../..) para achar o arquivo na raiz
const serviceAccount = require('../../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Exportamos o admin (para auth) e o db (para o firestore)
module.exports = { admin, db };