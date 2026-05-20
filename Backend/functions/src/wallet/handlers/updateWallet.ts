/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import { updateWalletBalance } from "../repositories/walletRepository";

export const updateWallet = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);
  const userId = user.uid;
  const balanceChangeCents = req.data?.balanceChangeCents;

  try {
    await updateWalletBalance(userId, balanceChangeCents);
    return { success: true };
  } catch (error) {
    console.error("Erro ao atualizar o saldo da carteira:", error);
    throw new HttpsError("internal", "Erro ao atualizar o saldo da carteira", error);
  }
});