/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/
import { db } from "../shared/firebase";
import { TokenHolding, WalletTransaction } from "../../wallet/types";
import { HttpsError } from "firebase-functions/https";
import { FieldValue } from "firebase-admin/firestore";
import { updateWalletBalance } from "../../wallet/repositories/walletRepository";
import { addUserAsInvestor } from "../../startups/repositories/startupRepository";


export async function sellTokens(userId: string, startupId: string, tokenAmount: number, startupName: string, currentPriceCents: number) {

  const totalPriceCents = tokenAmount * currentPriceCents;

  if (!userId || !startupId || !tokenAmount || tokenAmount <= 0 || !startupName || !currentPriceCents || currentPriceCents <= 0) {
    throw new HttpsError("invalid-argument", "Parâmetros insuficientes para venda de tokens.");
  }

  const userWalletRef = db.collection("users").doc(userId);
  const tokensRef = await userWalletRef.collection("invested").doc(startupId).get();
  const walletRef = await userWalletRef.get();

   if (!walletRef.exists) {
    throw new HttpsError("not-found", "Carteira do usuário não encontrada.");
  }

  if(tokensRef.exists) {
    updateTokenIssues(startupId, tokenAmount, currentPriceCents);
    const tokenData = tokensRef.data();
    if(tokenData && tokenData.quantity >= tokenAmount) {
      if (tokenData.quantity === tokenAmount) {
        await tokensRef.ref.delete();

        /*

          REMOVER DE INVESTIDOR DA STARTUP SE A QUANTIDADE DE TOKENS CHEGAR A ZERO APÓS VENDA

        */

      } else {
        await tokensRef.ref.update({
          quantity: tokenData.quantity - tokenAmount,
          averagePurchasePriceCents: ((tokensRef.data()?.averagePurchasePriceCents || 0) * (tokensRef.data()?.quantity || 0) + totalPriceCents) / ((tokensRef.data()?.quantity || 0) + tokenAmount),
          currentPriceCents: currentPriceCents,
          totalPriceCents: totalPriceCents,
        } as TokenHolding);
      }
      await userWalletRef.collection("transactions").doc().set({
          type: "venda",
          startupId,
          startupName: startupName,
          quantity: tokenAmount,
          priceCents: currentPriceCents, 
          date: FieldValue.serverTimestamp(),
        } as WalletTransaction);

      await updateWalletBalance(userId, totalPriceCents);
    } else {
      throw new HttpsError("failed-precondition", "Quantidade de tokens insuficiente para venda.");
    }
  } else {
    throw new HttpsError("not-found", "Tokens não encontrados para venda.");
  }
}


export async function buyTokens(userId: string, startupId: string, startupName: string, tokenAmount: number, currentPriceCents: number) {

  const totalPriceCents = tokenAmount * currentPriceCents;

  if (!userId || !startupId || !startupName || !tokenAmount || tokenAmount <= 0 || !currentPriceCents || currentPriceCents <= 0) {
    throw new HttpsError("invalid-argument", "Parâmetros insuficientes para compra de tokens.");
  }

  const userWalletRef = db.collection("users").doc(userId);
  const tokensRef = await userWalletRef.collection("invested").doc(startupId).get();
  const walletRef = await userWalletRef.get();

   if (!walletRef.exists) {
    throw new HttpsError("not-found", "Carteira do usuário não encontrada.");
  }

  if (walletRef.data()?.wallet.balanceCents < totalPriceCents) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente para compra de tokens.");
  }

  if(tokensRef.exists) {
    updateTokenIssues(startupId, -tokenAmount, currentPriceCents);
    await tokensRef.ref.update({
      quantity: (tokensRef.data()?.quantity || 0) + tokenAmount,
      averagePurchasePriceCents: ((tokensRef.data()?.averagePurchasePriceCents || 0) * (tokensRef.data()?.quantity || 0) + totalPriceCents) / ((tokensRef.data()?.quantity || 0) + tokenAmount),
      currentPriceCents: currentPriceCents,
      totalPriceCents: totalPriceCents + (tokensRef.data()?.totalPriceCents || 0),
    } as TokenHolding);
  } else {
    await userWalletRef.collection("invested").doc(startupId).set({
      startupId,
      startupName,
      quantity: tokenAmount,
      averagePurchasePriceCents: totalPriceCents / tokenAmount,
      currentPriceCents: currentPriceCents,
      totalPriceCents: totalPriceCents,
    } as TokenHolding);
  }

  await userWalletRef.collection("transactions").doc().set({
    type: "compra",
    startupId,
    startupName,
    quantity: tokenAmount,
    priceCents: totalPriceCents / tokenAmount, 
    date: FieldValue.serverTimestamp(),
  } as WalletTransaction);
  
  await updateWalletBalance(userId, -totalPriceCents);
  
  await addUserAsInvestor(startupId, userId, {
    tokensOwned: tokenAmount,
    totalInvestedCents: totalPriceCents
  });
}


export async function updateTokenIssues(startupId: string, tokensDiff: number, newCurrentPriceCents?: number) {
  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();
  
  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada para atualização de tokens.");
  }

  if (newCurrentPriceCents || newCurrentPriceCents !== undefined) {
    await startupRef.update({
      totalTokensIssued: FieldValue.increment(tokensDiff),
      currentTokenPriceCents: newCurrentPriceCents,
    });
  } else {
  await startupRef.update({
    totalTokensIssued: FieldValue.increment(tokensDiff),
  });
  }
}

