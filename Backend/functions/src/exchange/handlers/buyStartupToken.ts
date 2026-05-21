/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import {
  buyTokens
} from "../repositories/buySellToken";
import { TokenTransactionDocument } from "../types";

export const buyStartupToken = onCall(async (req) => {
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
    await buyTokens(
      transactionData.userId,
      transactionData.startupId,
      transactionData.startupName,
      transactionData.tokenAmount,
      transactionData.currentTokenPriceCents
    );
    return { success: true };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Erro ao processar compra de tokens.", error instanceof Error ? error.message : String(error));
  }

});
