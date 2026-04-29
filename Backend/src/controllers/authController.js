/* Bruno César Gonçalves Lima Mota
   RA: 24795502 */

const { admin, db } = require('../config/firebase');

const cadastrar = async (req, res) => {
  let userRecord; // Declaramos aqui para que o 'catch' possa acessá-lo

  try {
    const { nome, email, cpf, celular, senha } = req.body;

    if (!email || !senha || !nome) {
      return res.status(400).json({ mensagem: 'Faltam dados obrigatórios.' });
    }

    // 1. Tenta criar o usuário no Firebase Authentication
    userRecord = await admin.auth().createUser({
      email: email,
      password: senha,
      displayName: nome,
    });

    // 2. Tenta salvar no Firestore
    // Simulamos que se chegar aqui, o Auth funcionou. Se o Firestore falhar, 
    // entraremos no bloco 'catch' abaixo.
    await db.collection('users').doc(userRecord.uid).set({
      nome: nome,
      email: email,
      cpf: cpf,
      celular: celular,
      criadoEm: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`Usuário cadastrado com sucesso: ${nome}`);
    
    return res.status(201).json({ 
      mensagem: 'Usuário cadastrado com sucesso!', 
      uid: userRecord.uid 
    });

  } catch (error) {
    // ── LÓGICA DE ROLLBACK ──────────────────────────────────────────
    // Se o userRecord foi preenchido, significa que o usuário foi criado no Auth,
    // mas o erro aconteceu DEPOIS (provavelmente no Firestore).
    // Só fazemos o rollback se o erro NÃO for "e-mail já existe".
    if (userRecord && error.code !== 'auth/email-already-exists') {
      console.log(`Falha no Firestore. Removendo usuário ${userRecord.uid} do Auth para limpeza...`);
      await admin.auth().deleteUser(userRecord.uid);
    }
    // ────────────────────────────────────────────────────────────────

    console.error('Erro no processo de cadastro:', error.message);
    
    if (error.code === 'auth/email-already-exists') {
      return res.status(400).json({ mensagem: 'Este e-mail já está em uso.' });
    }
    if (error.code === 'auth/weak-password') {
      return res.status(400).json({ mensagem: 'A senha deve ter pelo menos 6 caracteres.' });
    }

    return res.status(500).json({ mensagem: 'Erro interno no servidor ao cadastrar.' });
  }
};

module.exports = { cadastrar };