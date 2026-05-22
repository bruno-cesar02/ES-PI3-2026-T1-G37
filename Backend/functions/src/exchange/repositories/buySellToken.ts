/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/
import { db } from "../shared/firebase";
import { TokenHolding, WalletTransaction } from "../../wallet/types";
import { HttpsError } from "firebase-functions/https";
import { FieldValue } from "firebase-admin/firestore";
import { updateWalletBalance } from "../../wallet/repositories/walletRepository";
import {
  addUserAsInvestor,
  removeTokensFromInvestor,
} from "../../startups/repositories/startupRepository";
import { ExchangeDocument } from "../types";


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

      await removeTokensFromInvestor(startupId, userId, {
        tokensSold: tokenAmount,
        valueReceivedCents: totalPriceCents,
      });
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

  const userEmail = walletRef.data()?.email as string | undefined;

  await addUserAsInvestor(startupId, userId, {
    tokensOwned: tokenAmount,
    totalInvestedCents: totalPriceCents,
    email: userEmail,
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

export async function recordExchange(startupId: string, startupName: string, tokenOwnerId: string, quantity: number, averagePurchasePriceCents: number, currentPriceCents: number) {


  if (!startupId || !startupName || !tokenOwnerId || !quantity || quantity <= 0 || !averagePurchasePriceCents || averagePurchasePriceCents <= 0 || !currentPriceCents || currentPriceCents <= 0) {
    throw new HttpsError("invalid-argument", "Parâmetros insuficientes para registro de troca de tokens.");
  }

  const startupInvested = await db.collection("users").doc(tokenOwnerId).collection("invested").doc(startupId).get();
  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();

  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada para registro de troca de tokens.");
  }

  if (!startupInvested.exists) {
    throw new HttpsError("not-found", "Investimento do usuário na startup não encontrado para registro de troca de tokens.");
  }

  if (startupInvested.data()?.quantity < quantity) {
    throw new HttpsError("failed-precondition", "Quantidade de tokens insuficiente para registro de troca.");
  }

  await startupInvested.ref.update({
    quantity: FieldValue.increment(-quantity),
  });

  // Tokens entram em escrow ao serem ofertados no balcão.
  // O usuário deixa de tê-los na carteira, portanto também não conta
  // mais como investidor (se zerar) ou tem posição reduzida.
  const valueAtCurrentPrice = quantity * currentPriceCents;
  await removeTokensFromInvestor(startupId, tokenOwnerId, {
    tokensSold: quantity,
    valueReceivedCents: valueAtCurrentPrice,
  });

  const exchangeData = {
    startupId,
    startupName,
    tokenOwnerId,
    quantity,
    averagePurchasePriceCents,
    currentPriceCents,
    createdAt: FieldValue.serverTimestamp(),
  } as ExchangeDocument;

  await db.collection("startups").doc(startupId).collection("exchanges").doc().set(exchangeData);

}

export async function deleteExchangeRecord(exchangeId: string, startupId: string) {
  const exchangeRef = db.collection("startups").doc(startupId).collection("exchanges").doc(exchangeId);
  const exchangeDoc = await exchangeRef.get();

  if (!exchangeDoc.exists) {
    throw new HttpsError("not-found", "Registro de troca de tokens não encontrado para exclusão.");
  }

  await db.collection("users").doc(exchangeDoc.data()?.tokenOwnerId || "").collection("invested").doc(startupId).update({
    quantity: FieldValue.increment(exchangeDoc.data()?.quantity || 0),
  });

    // Restaura a posição do investidor: oferta cancelada, tokens voltam.
  const exchangeData = exchangeDoc.data() as ExchangeDocument;
  const restoredValueCents = exchangeData.quantity * exchangeData.currentPriceCents;
  await addUserAsInvestor(startupId, exchangeData.tokenOwnerId, {
    tokensOwned: exchangeData.quantity,
    totalInvestedCents: restoredValueCents,
  });

  await exchangeRef.delete();
}


export async function acceptExchange(exchangeId: string, startupId: string, buyerId: string) {

  const exchangeRef = db.collection("startups").doc(startupId).collection("exchanges").doc(exchangeId);
  const buyerRef = db.collection("users").doc(buyerId);

  // Variáveis pra usar fora da transaction (atualizar saldo de investidor)
  let sellerId: string = "";
  let quantitySold: number = 0;
  let valueExchangedCents: number = 0;

  await db.runTransaction(async (transaction) => {

    const exchangeDoc = await transaction.get(exchangeRef);
    if (!exchangeDoc.exists) {
      throw new HttpsError("not-found", "A oferta já foi concluída ou cancelada.");
    }

    const exchangeData = exchangeDoc.data() as ExchangeDocument;
    sellerId = exchangeData.tokenOwnerId;
    quantitySold = exchangeData.quantity;
    valueExchangedCents = exchangeData.quantity * exchangeData.currentPriceCents;

    const sellerRef = db.collection("users").doc(sellerId);

    if (buyerId === sellerId) {
      throw new HttpsError("invalid-argument", "Você não pode aceitar sua própria oferta.");
    }

    const totalVolumeCents = exchangeData.quantity * exchangeData.currentPriceCents;

    const buyerDoc = await transaction.get(buyerRef);
    const sellerInvestedRef = sellerRef.collection("invested").doc(startupId);
    const sellerInvestedDoc = await transaction.get(sellerInvestedRef);
    const buyerInvestedRef = buyerRef.collection("invested").doc(startupId);
    const buyerInvestedDoc = await transaction.get(buyerInvestedRef);

    const buyerBalance = buyerDoc.get("wallet.balanceCents");

    if (!buyerBalance || typeof buyerBalance !== "number") {
      throw new HttpsError("not-found", "Saldo da carteira do comprador não encontrado.");
    }

    if (buyerBalance < totalVolumeCents) {
      throw new HttpsError("failed-precondition", "Saldo insuficiente para concluir a compra.");
    }

    transaction.update(buyerRef, { "wallet.balanceCents": FieldValue.increment(-totalVolumeCents) });
    transaction.update(sellerRef, { "wallet.balanceCents": FieldValue.increment(totalVolumeCents) });

    // B. Atualizar Tokens do Comprador (Adiciona ao Invested)
    if (buyerInvestedDoc.exists) {
      const currentBuyerHolding = buyerInvestedDoc.data() as TokenHolding;
      const novaQuantidade = currentBuyerHolding.quantity + exchangeData.quantity;

      const custoAntigo = currentBuyerHolding.quantity * currentBuyerHolding.averagePurchasePriceCents;
      const custoNovo = exchangeData.quantity * exchangeData.currentPriceCents;
      const novoPM = Math.round((custoAntigo + custoNovo) / novaQuantidade);

      transaction.update(buyerInvestedRef, {
        quantity: novaQuantidade,
        averagePurchasePriceCents: novoPM
      });
    } else {
      const newHolding: TokenHolding = {
        startupId: startupId,
        startupName: exchangeData.startupName,
        quantity: exchangeData.quantity,
        averagePurchasePriceCents: exchangeData.currentPriceCents,
        currentPriceCents: exchangeData.currentPriceCents,
      };
      transaction.set(buyerInvestedRef, newHolding);
    }

    const tokensRestantes = sellerInvestedDoc.data()?.quantity;
    if (tokensRestantes <= 0) {
      transaction.delete(sellerInvestedRef);
    } else {
      transaction.update(sellerInvestedRef, { quantity: tokensRestantes });
    }

    // D. Criar Histórico de Transações
    const timestamp = FieldValue.serverTimestamp();

    const buyerTxRef = buyerRef.collection("transactions").doc();
    transaction.set(buyerTxRef, {
      type: "compra",
      startupId: startupId,
      startupName: exchangeData.startupName,
      quantity: exchangeData.quantity,
      priceCents: exchangeData.currentPriceCents,
      date: timestamp,
    } as WalletTransaction);

    const sellerTxRef = sellerRef.collection("transactions").doc();
    transaction.set(sellerTxRef, {
      type: "venda",
      startupId: startupId,
      startupName: exchangeData.startupName,
      quantity: exchangeData.quantity,
      priceCents: exchangeData.currentPriceCents,
      date: timestamp,
    } as WalletTransaction);

    transaction.delete(exchangeRef);
  });

  // ── Pós-transação: atualizar saldos de investidor na startup ────────────
  // Lembrando que o vendedor já teve sua posição reduzida no recordExchange
  // (quando criou a oferta). Agora precisamos:
  // - Adicionar o comprador como investidor (ou somar à posição existente)
  // O vendedor NÃO é atualizado aqui porque o decremento foi feito no
  // recordExchange, no momento em que ele colocou a oferta no balcão.
  if (sellerId && quantitySold > 0) {
    await addUserAsInvestor(startupId, buyerId, {
      tokensOwned: quantitySold,
      totalInvestedCents: valueExchangedCents,
    });
  }
}
