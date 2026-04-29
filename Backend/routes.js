// Nome: Otávio Augusto Antunes Marquez
// RA: 24025832


const express = require('express');
const router = express.Router();


//Adicionar as rotas aqui

// Importa as rotas específicas
const authRoutes = require('./src/routes/authRoutes');
// Todas as rotas que vierem de authRoutes terão o prefixo /auth
router.use('/auth', authRoutes);

/*
router.get('/', (req, res) => {
  res.send('Bem-vindo à API');
});
*/

module.exports = router;