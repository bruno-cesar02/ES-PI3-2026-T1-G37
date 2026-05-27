/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { onCall } from "firebase-functions/https";
import { recordExchange } from "../repositories/buySellToken";
import { requireAuthenticatedUser } from "../../users/shared/auth";


export const createExchangeRequest = onCall(async (req) => {

  const user = requireAuthenticatedUser(req);

  const startupId: string = req.data?.startupId;
  const tokenOwnerId: string = user.uid;
  const quantity: number = req.data?.quantity;
  const purchasePriceCents: number = req.data?.purchasePriceCents;
  
  if (!startupId || !tokenOwnerId || !quantity || quantity <= 0 || (purchasePriceCents && purchasePriceCents <= 0)) {
    throw new Error("Parâmetros insuficientes para registro de troca de tokens.");
  }

  try {
    await recordExchange(startupId, tokenOwnerId, quantity, purchasePriceCents ? purchasePriceCents : undefined);
    return { success: true };
  } catch (error) {
    throw new Error("Erro ao registrar troca de tokens: " + (error instanceof Error ? error.message : String(error)));
  }
});