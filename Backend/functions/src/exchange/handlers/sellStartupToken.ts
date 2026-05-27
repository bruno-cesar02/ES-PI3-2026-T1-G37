/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

/*

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import { TokenTransactionDocument } from "../types";
import { 
  sellTokens 
} from "../repositories/buySellToken";

export const sellStartupToken = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);

  const transactionData: TokenTransactionDocument = {
    userId: user.uid,
    startupId: req.data.startupId,
    startupName: req.data.startupName,
    currentTokenPriceCents: req.data.currentTokenPriceCents,
    tokenAmount: req.data.tokenAmount,
    totalPriceCents: req.data.totalPriceCents,
  }

  try {
    await sellTokens(
      transactionData.userId,
      transactionData.startupId,
      transactionData.tokenAmount,
      transactionData.startupName,
      transactionData.currentTokenPriceCents
    );
    return { success: true };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Erro ao processar venda de tokens.", error instanceof Error ? error.message : String(error));
  }

});*/