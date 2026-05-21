/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 


import { onCall } from "firebase-functions/https";
import { listStartupExchanges } from "../repositories/startupRepository";


export const listStartupExchangesHandler = onCall(async (req) => {

  const user = req.auth?.uid;

  if (!user) {
    throw new Error("Usuário não autenticado.");
  }

  const startupId: string = req.data.startupId;
  
  if (!startupId) {
    throw new Error("O ID da startup é obrigatório.");
  }
  return await listStartupExchanges(startupId);
});
