// Nome: Otávio Augusto Antunes Marquez
// RA: 24025832

const express = require('express');
const app = express();
const routes = require('./routes');
const path = require('path');
//const {middleware} = require('./src/middlewares/middleware');
const cors = require('cors');

const session = require('express-session'); 

const sessionOptions = session({
  secret: 'senhasuperseguradomanokarpos',
  //store: new fsstore(fsstoreOptions),
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 1000 * 60 * 60 * 24 * 7,
    httpOnly: true
  }
});

app.use(sessionOptions);

// ── AJUSTES PARA O FLUTTER FUNCIONAR ──────────────────────
app.use(cors()); // Libera o acesso para o aplicativo Flutter
app.use(express.json()); // Permite que o Node leia o body em JSON
// ──────────────────────────────────────────────────────────
const authRoutes = require('./src/routes/authRoutes');
app.use('/auth', authRoutes)

app.use(express.urlencoded({ extended: true }));

//descomentar  app.use(middleware);
app.use(routes);

app.listen(3300, () => {
  console.log('Servidor do MesclaInvest rodando na porta: 127.0.0.1:3300');
});