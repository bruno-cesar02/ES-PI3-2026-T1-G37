/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/
import { db } from "../shared/firebase";
import { TokenHolding, WalletTransaction } from "../../wallet/types";
import { HttpsError } from "firebase-functions/https";
import { FieldValue } from "firebase-admin/firestore";
import {
  addUserAsInvestor,
  removeTokensFromInvestor,
} from "../../startups/repositories/startupRepository";
import { ExchangeDocument } from "../types";


export async function buyTokens(userId: string, startupId: string, tokenAmount: number) {
  if (!userId || !startupId || !tokenAmount || tokenAmount <= 0) {
    throw new HttpsError("invalid-argument", "Parâmetros insuficientes para compra de tokens.");
  }

  const userRef = db.collection("users").doc(userId);
  const startupRef = db.collection("startups").doc(startupId);
  const investedRef = userRef.collection("invested").doc(startupId);
  const investorRef = startupRef.collection("investors").doc(userId);
  const txRef = userRef.collection("transactions").doc();

  await db.runTransaction(async (transaction) => {
    const [startupDoc, userDoc, investedDoc, investorDoc] = await Promise.all([
      transaction.get(startupRef),
      transaction.get(userRef),
      transaction.get(investedRef),
      transaction.get(investorRef),
    ]);

    if (!startupDoc.exists) throw new HttpsError("not-found", "Startup não encontrada.");
    if (!userDoc.exists) throw new HttpsError("not-found", "Carteira do usuário não encontrada.");

    // Fallbacks para garantir que NENHUM dado venha undefined e quebre o Firestore
    const startupData = startupDoc.data() || {};
    const userData = userDoc.data() || {};

    const currentPriceCents = Math.round(startupData.currentTokenPriceCents || 0);
    const totalPriceCents = tokenAmount * currentPriceCents;
    const newPriceCents = Math.round(currentPriceCents * Math.pow(1.01, tokenAmount));
    
    // PROTEÇÃO 1: Evita que undefined no nome quebre a criação do registro
    const startupName = startupData.name || "Startup Desconhecida"; 

    // PROTEÇÃO 2: Lê o saldo de forma segura, independente de como o usuário foi criado
    const walletData = userData.wallet || {};
    const currentBalance = walletData.balanceCents ?? userData.balanceCents ?? 0;

    if (currentBalance < totalPriceCents) {
      throw new HttpsError("failed-precondition", "Saldo insuficiente para compra de tokens.");
    }

    // 1. Atualiza os dados da Startup
    transaction.update(startupRef, {
      totalTokensIssued: FieldValue.increment(tokenAmount),
      currentTokenPriceCents: newPriceCents,
      averageTokenPriceCents: newPriceCents 
    });

    // 1.5 Registra a valorização no histórico de preços (Faltava isso!)
    const priceHistoryRef = startupRef.collection("priceHistory").doc();
    transaction.set(priceHistoryRef, {
      priceCents: newPriceCents,
      tokensDiff: tokenAmount,
      reason: "primary_market_appreciation",
      createdAt: FieldValue.serverTimestamp()
    });

    // 2. Atualiza a Carteira do Usuário de forma 100% segura (sem usar notação de ponto)
    transaction.update(userRef, {
      wallet: {
        ...walletData, // Mantém outros dados da carteira intactos
        balanceCents: currentBalance - totalPriceCents
      }
    });

    // 3. Atualiza a subcoleção 'invested'
    if (investedDoc.exists) {
      const existing = investedDoc.data() || {};
      const currentQty = existing.quantity || 0;
      const currentTotal = existing.totalPriceCents || 0;
      const newQty = currentQty + tokenAmount;
      const newAvg = Math.round((currentTotal + totalPriceCents) / newQty);

      transaction.update(investedRef, {
        quantity: newQty,
        averagePurchasePriceCents: newAvg,
        currentPriceCents: currentPriceCents,
        totalPriceCents: FieldValue.increment(totalPriceCents),
      });
    } else {
      transaction.set(investedRef, {
        startupId: startupId,
        startupName: startupName,
        quantity: tokenAmount,
        averagePurchasePriceCents: currentPriceCents,
        currentPriceCents: currentPriceCents,
        totalPriceCents: totalPriceCents,
      });
    }

    // 4. Registra a Transação
    transaction.set(txRef, {
      type: "compra",
      startupId: startupId,
      startupName: startupName,
      quantity: tokenAmount,
      priceCents: currentPriceCents,
      date: FieldValue.serverTimestamp(),
    } as WalletTransaction);

    // 5. Atualiza/Cria subcoleção 'investors'
    const userEmail = userData.email ?? null; // Null é aceito pelo Firebase, undefined não
    if (investorDoc.exists) {
      transaction.update(investorRef, {
        tokensOwned: FieldValue.increment(tokenAmount),
        totalInvestedCents: FieldValue.increment(totalPriceCents),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      transaction.set(investorRef, {
        uid: userId,
        email: userEmail,
        tokensOwned: tokenAmount,
        totalInvestedCents: totalPriceCents,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  });
}

// Mantemos a função original corrigida com Math.round para não quebrar outros arquivos que a importem
export async function updateTokenIssued(startupId: string, tokensDiff: number) {
  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();
  
  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada para atualização de tokens.");
  }

  const currentPriceCents = Math.round(startupDoc.data()?.currentTokenPriceCents || 0);
  const newPriceCents = Math.round(currentPriceCents * Math.pow(1.01, tokensDiff));

  await startupDoc.ref.update({
    totalTokensIssued: FieldValue.increment(tokensDiff),
    currentTokenPriceCents: newPriceCents
  });
}

export async function recordExchange(startupId: string, tokenOwnerId: string, quantity: number, purchasePriceCents?: number) {


  if (!startupId || !tokenOwnerId || !quantity || quantity <= 0 || (purchasePriceCents && purchasePriceCents <= 0)) {
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

  const currentPriceCents = startupDoc.data()?.currentTokenPriceCents || 0;
  const currentQty = startupInvested.data()?.quantity || 0;
  const currentAvgPrice = startupInvested.data()?.averagePurchasePriceCents || 0;

  if (currentQty < quantity){
    throw new HttpsError("failed-precondition", "Quantidade de tokens insuficiente para registro de troca.");
  }

  const newQty = currentQty - quantity;

  if (newQty === 0) {
    await startupInvested.ref.update({
      quantity: 0,
      currentPriceCents: currentPriceCents,
      totalPriceCents: 0,
    });
  } else {

    await startupInvested.ref.update({
      quantity: newQty,
      averagePurchasePriceCents: currentAvgPrice,
      currentPriceCents: currentPriceCents,
      totalPriceCents: newQty * currentPriceCents,
    });
  }

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
    startupName : startupDoc.data()?.name || "",
    tokenOwnerId,
    quantity,
    purchasePriceCents: purchasePriceCents,
    currentPriceCents: currentPriceCents,
    createdAt: FieldValue.serverTimestamp(),
  };

  await db.collection("startups").doc(startupId).collection("exchanges").doc().set(exchangeData);

}

export async function deleteExchangeRecord(exchangeId: string, startupId: string) {
  const exchangeRef = db.collection("startups").doc(startupId).collection("exchanges").doc(exchangeId);
  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();
  const exchangeDoc = await exchangeRef.get();

  if (!exchangeDoc.exists) {
    throw new HttpsError("not-found", "Registro de troca de tokens não encontrado para exclusão.");
  }

  await db.collection("users").doc(exchangeDoc.data()?.tokenOwnerId || "").collection("invested").doc(startupId).update({
    quantity: FieldValue.increment(exchangeDoc.data()?.quantity || 0),
    currentPriceCents: startupDoc.data()?.currentTokenPriceCents || 0,
    totalPriceCents: FieldValue.increment((exchangeDoc.data()?.quantity || 0) * (startupDoc.data()?.currentTokenPriceCents || 0)),
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
  const startupRef = db.collection("startups").doc(startupId);
  const buyerRef = db.collection("users").doc(buyerId);

  let sellerId: string = "";
  let quantitySold: number = 0;
  let valueExchangedCents: number = 0;
  let buyerEmail: string | undefined = undefined;

  await db.runTransaction(async (transaction) => {
    // 1. Leituras essenciais
    const exchangeDoc = await transaction.get(exchangeRef);
    const startupDoc = await transaction.get(startupRef);
    const buyerDoc = await transaction.get(buyerRef);

    if (!exchangeDoc.exists) throw new HttpsError("not-found", "A oferta já foi concluída ou cancelada.");
    if (!startupDoc.exists) throw new HttpsError("not-found", "Startup não encontrada.");

    const exchangeData = exchangeDoc.data() as ExchangeDocument;
    sellerId = exchangeData.tokenOwnerId;
    quantitySold = exchangeData.quantity;
    
    if (buyerId === sellerId) {
      throw new HttpsError("invalid-argument", "Você não pode aceitar sua própria oferta.");
    }

    const pricePaidPerToken = exchangeData.purchasePriceCents || exchangeData.currentPriceCents;
    const totalVolumeCents = quantitySold * pricePaidPerToken;
    valueExchangedCents = totalVolumeCents; 

    // 2. Lógica de Desvalorização (Média Ponderada)
    const currentStartupPrice = startupDoc.data()?.currentTokenPriceCents || 0;
    const totalTokensIssued = startupDoc.data()?.totalTokensIssued || 1; 

    if (pricePaidPerToken < currentStartupPrice) {
      const safeQuantitySold = Math.min(quantitySold, totalTokensIssued);
      const totalValuePreserved = (totalTokensIssued - safeQuantitySold) * currentStartupPrice;
      const totalValueSold = safeQuantitySold * pricePaidPerToken;
      
      const newPriceCents = Math.round((totalValuePreserved + totalValueSold) / totalTokensIssued);

      if (newPriceCents < currentStartupPrice) {
        transaction.update(startupRef, {
          currentTokenPriceCents: newPriceCents,
          averageTokenPriceCents: newPriceCents 
        });

        const priceHistoryRef = startupRef.collection("priceHistory").doc();
        transaction.set(priceHistoryRef, {
          priceCents: newPriceCents,
          tokensDiff: 0, 
          reason: "exchange_depreciation_weighted",
          triggeringVolume: quantitySold,
          triggeringPrice: pricePaidPerToken,
          createdAt: FieldValue.serverTimestamp()
        });
      }
    }

    // 3. Validação de Saldo do Comprador de forma segura
    const buyerData = buyerDoc.data() || {};
    buyerEmail = buyerData.email;
    const buyerWalletData = buyerData.wallet || {};
    const buyerBalance = buyerWalletData.balanceCents ?? buyerData.balanceCents ?? 0;

    if (buyerBalance < totalVolumeCents) {
      throw new HttpsError("failed-precondition", "Saldo insuficiente para concluir a compra.");
    }

    // 4. Leituras dos investimentos
    const buyerInvestedRef = buyerRef.collection("invested").doc(startupId);
    const sellerRef = db.collection("users").doc(sellerId);
    const sellerInvestedRef = sellerRef.collection("invested").doc(startupId);

    const buyerInvestedDoc = await transaction.get(buyerInvestedRef);
    const sellerInvestedDoc = await transaction.get(sellerInvestedRef);

    // 5. Transferência Financeira
    transaction.update(buyerRef, { 
      wallet: {
        ...buyerWalletData,
        balanceCents: buyerBalance - totalVolumeCents
      }
    });
    // O seller recebe o dinheiro (usando increment para simplificar, mas certifique-se que o schema suporta)
    transaction.update(sellerRef, { "wallet.balanceCents": FieldValue.increment(totalVolumeCents) });

    // 6. Transferência de Tokens
    if (buyerInvestedDoc.exists) {
      const currentBuyerHolding = buyerInvestedDoc.data() as TokenHolding;
      const novaQuantidade = currentBuyerHolding.quantity + quantitySold;
      const custoAntigo = currentBuyerHolding.quantity * currentBuyerHolding.averagePurchasePriceCents;
      const novoPM = Math.round((custoAntigo + totalVolumeCents) / novaQuantidade);

      transaction.update(buyerInvestedRef, {
        quantity: novaQuantidade,
        averagePurchasePriceCents: novoPM,
        totalPriceCents: FieldValue.increment(totalVolumeCents),
        currentPriceCents: pricePaidPerToken < currentStartupPrice ? pricePaidPerToken : exchangeData.currentPriceCents 
      });
    } else {
      const newHolding: TokenHolding = {
        startupId: startupId,
        startupName: exchangeData.startupName,
        quantity: quantitySold,
        averagePurchasePriceCents: pricePaidPerToken,
        currentPriceCents: pricePaidPerToken < currentStartupPrice ? pricePaidPerToken : exchangeData.currentPriceCents,
        totalPriceCents: totalVolumeCents, 
      };
      transaction.set(buyerInvestedRef, newHolding);
    }

    // 7. Limpeza e Recibos
    if (sellerInvestedDoc.exists && sellerInvestedDoc.data()?.quantity === 0) {
        transaction.delete(sellerInvestedRef);
    }

    const timestamp = FieldValue.serverTimestamp();

    const buyerTxRef = buyerRef.collection("transactions").doc();
    transaction.set(buyerTxRef, {
      type: "compra",
      startupId: startupId,
      startupName: exchangeData.startupName,
      quantity: quantitySold,
      priceCents: pricePaidPerToken,
      date: timestamp,
    } as WalletTransaction);

    const sellerTxRef = sellerRef.collection("transactions").doc();
    transaction.set(sellerTxRef, {
      type: "venda",
      startupId: startupId,
      startupName: exchangeData.startupName,
      quantity: quantitySold,
      priceCents: pricePaidPerToken,
      date: timestamp,
    } as WalletTransaction);

    transaction.delete(exchangeRef);
  });

  // 8. Pós-transação: atualizar investidores
  if (sellerId && quantitySold > 0) {
    await addUserAsInvestor(startupId, buyerId, {
      tokensOwned: quantitySold,
      totalInvestedCents: valueExchangedCents,
      email: buyerEmail, 
    });
  }
}
