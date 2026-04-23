// Nome: Otávio Augusto Antunes Marquez
// RA: 24025832

const express = require('express');
const app = express();
const routes = require('./routes');
const path = require('path');
const {middleware} = require('./src/middlewares/middleware');


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

app.use(express.urlencoded({ extended: true }));

app.use(middleware);
app.use(routes);

app.listen(3300, () => {
  console.log('Servidor rodando na porta:  127.0.0.1:3300');
});