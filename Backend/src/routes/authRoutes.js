/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

// src/routes/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Quando der um POST em /cadastro, executa a função cadastrar do controller
router.post('/cadastro', authController.cadastrar);

module.exports = router;