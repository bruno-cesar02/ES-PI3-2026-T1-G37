/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { HttpsError, onCall } from "firebase-functions/https";
import { acceptExchange } from "../repositories/buySellToken";
import { requireAuthenticatedUser } from "../../users/shared/auth";

export const acceptExchangeRequest = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);


  if (!user.uid) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado.");
  }

  const exchangeId: string = req.data.exchangeId;
  const startupId: string = req.data.startupId;

  if (!exchangeId) {
    throw new HttpsError("invalid-argument", "O ID da troca é obrigatório.");
  }
  
  try {
    await acceptExchange(exchangeId, startupId, user.uid);
    return { success: true };
  }
  catch (error) {
    throw new HttpsError("internal", "Erro ao aceitar a troca de tokens: " + (error instanceof Error ? error.message : String(error)));
  }
});