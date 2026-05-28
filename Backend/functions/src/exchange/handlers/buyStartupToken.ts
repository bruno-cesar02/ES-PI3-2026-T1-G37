/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { HttpsError, onCall, CallableRequest } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import {
  buyTokens
} from "../repositories/buySellToken";

export const buyStartupToken = onCall(async (req: CallableRequest) => {
  const user = requireAuthenticatedUser(req);

  const transactionData = {
    userId: user.uid,
    startupId: req.data.startupId,
    tokenAmount: req.data.tokenAmount,
  }

  try {
    await buyTokens(
      transactionData.userId,
      transactionData.startupId,
      transactionData.tokenAmount,
    );
    return { success: true };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "Erro ao processar compra de tokens.", error instanceof Error ? error.message : String(error));
  }

});
