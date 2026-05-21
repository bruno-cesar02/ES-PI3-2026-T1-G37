/* 
Otávio Augusto Antunes Marquez
RA: 24025832
*/

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../users/shared/auth";
import {
  getWalletData
} from "../repositories/walletRepository";
import { WalletNotFoundError } from "../shared/errors";

export const getWalletDetails = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);

  try {
    const walletDetails = await getWalletData(user.uid);
    return walletDetails;
  } catch (error) {
    console.error("Erro ao buscar detalhes da carteira:", error);

    if (error instanceof WalletNotFoundError) {
      throw new HttpsError("not-found", error.message);
    }
    
    throw new HttpsError("internal", "Erro ao buscar detalhes da carteira");
  }

});
