/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { HttpsError, onCall } from "firebase-functions/https";
import { deleteExchangeRecord } from "../repositories/buySellToken";
import { requireAuthenticatedUser } from "../../users/shared/auth";


export const deleteExchangeRequest = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);

  if (!user) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado.");
  }

  const exchangeId: string = req.data.exchangeId;
  const startupId: string = req.data.startupId;

  if (!exchangeId || !startupId) {
    throw new HttpsError("invalid-argument", "O ID da troca e o ID da startup são obrigatórios.");
  }

  try{
    await deleteExchangeRecord(exchangeId, startupId);
    return { success: true };
  }
  catch (error) {
    throw new HttpsError("internal", "Erro ao deletar a troca de tokens: " + (error instanceof Error ? error.message : String(error)));
  }
});