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
  const startupName: string = req.data?.startupName;
  const tokenOwnerId: string = user.uid;
  const quantity: number = req.data?.quantity;
  const averagePurchasePriceCents: number = req.data?.averagePurchasePriceCents;
  const currentPriceCents: number = req.data?.currentPriceCents;
  
  if (!startupId || !startupName || !tokenOwnerId || !quantity || quantity <= 0 || !averagePurchasePriceCents || averagePurchasePriceCents <= 0 || !currentPriceCents || currentPriceCents <= 0) {
    throw new Error("Parâmetros insuficientes para registro de troca de tokens.");
  }

  try {
    await recordExchange(startupId, startupName, tokenOwnerId, quantity, averagePurchasePriceCents, currentPriceCents);
    return { success: true };
  } catch (error) {
    throw new Error("Erro ao registrar troca de tokens: " + (error instanceof Error ? error.message : String(error)));
  }
});