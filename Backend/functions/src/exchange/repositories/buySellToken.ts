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


export async function buyTokens(userId: string, startupId: string, tokenAmount: number) {

  

  if (!userId || !startupId || !tokenAmount || tokenAmount <= 0) {
    throw new HttpsError("invalid-argument", "Parâmetros insuficientes para compra de tokens.");
  }

  const userWalletRef = db.collection("users").doc(userId);
  const tokensRef = await userWalletRef.collection("invested").doc(startupId).get();
  const walletRef = await userWalletRef.get();
  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();


  const totalPriceCents = tokenAmount * startupDoc.data()?.currentTokenPriceCents;


  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada para compra de tokens.");
  }

   if (!walletRef.exists) {
    throw new HttpsError("not-found", "Carteira do usuário não encontrada.");
  }

  if (walletRef.data()?.wallet.balanceCents < totalPriceCents) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente para compra de tokens.");
  }

  updateTokenIssued(startupId, tokenAmount);


  //const lucroPorToken = precoAtualDaStartup - averagePurchasePriceCents; 
  // 1500 - 1300 = +200 centavos de lucro por token

  //const lucroTotal = lucroPorToken * quantidadeDeTokensQueEleTem;
  // 200 * 15 = +3000 centavos ($30.00 de lucro total)

  if(tokensRef.exists) {
    await tokensRef.ref.update({
      quantity: (tokensRef.data()?.quantity || 0) + tokenAmount,
      averagePurchasePriceCents: ((tokensRef.data()?.averagePurchasePriceCents || 0) * (tokensRef.data()?.quantity || 0) + totalPriceCents) / ((tokensRef.data()?.quantity || 0) + tokenAmount),
      currentPriceCents: startupDoc.data()?.currentTokenPriceCents,
      totalPriceCents: totalPriceCents + (tokensRef.data()?.totalPriceCents || 0),
    } as TokenHolding);
  } else {
    await userWalletRef.collection("invested").doc(startupId).set({
      startupId,
      startupName: startupDoc.data()?.name,
      quantity: tokenAmount,
      averagePurchasePriceCents: totalPriceCents / tokenAmount,
      currentPriceCents: startupDoc.data()?.currentTokenPriceCents,
      totalPriceCents: totalPriceCents,
    } as TokenHolding);
  }

  await userWalletRef.collection("transactions").doc().set({
    type: "compra",
    startupId,
    startupName: startupDoc.data()?.name,
    quantity: tokenAmount,
    priceCents: startupDoc.data()?.currentTokenPriceCents,
    date: FieldValue.serverTimestamp(),
  } as WalletTransaction);
  
  await updateWalletBalance(userId, -totalPriceCents, true);

  const userEmail = walletRef.data()?.email as string | undefined;

  await addUserAsInvestor(startupId, userId, {
    tokensOwned: tokenAmount,
    totalInvestedCents: totalPriceCents,
    email: userEmail,
  });
}


export async function updateTokenIssued(startupId: string, tokensDiff: number) {
  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();
  
  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada para atualização de tokens.");
  }

  await startupDoc.ref.update({
    totalTokensIssued: FieldValue.increment(tokensDiff),
    currentTokenPriceCents: (startupDoc.data()?.currentTokenPriceCents || 0) * Math.pow(1.01, tokensDiff)
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
  const buyerRef = db.collection("users").doc(buyerId);

  // Variáveis para atualizar a lista de investidores no final (fora da transaction)
  let sellerId: string = "";
  let quantitySold: number = 0;
  let valueExchangedCents: number = 0;
  let buyerEmail: string | undefined = undefined;

  await db.runTransaction(async (transaction) => {

    const exchangeDoc = await transaction.get(exchangeRef);
    if (!exchangeDoc.exists) {
      throw new HttpsError("not-found", "A oferta já foi concluída ou cancelada.");
    }

    const exchangeData = exchangeDoc.data() as ExchangeDocument;
    sellerId = exchangeData.tokenOwnerId;
    quantitySold = exchangeData.quantity;
    
    if (buyerId === sellerId) {
      throw new HttpsError("invalid-argument", "Você não pode aceitar sua própria oferta.");
    }

    const pricePaidPerToken = exchangeData.purchasePriceCents || exchangeData.currentPriceCents;
    const totalVolumeCents = quantitySold * pricePaidPerToken;
    valueExchangedCents = totalVolumeCents; 

    // 2. Lê a carteira do comprador
    const buyerDoc = await transaction.get(buyerRef);
    buyerEmail = buyerDoc.get("email") as string | undefined;
    const buyerBalance = buyerDoc.get("wallet.balanceCents");

    if (buyerBalance === undefined || typeof buyerBalance !== "number") {
      throw new HttpsError("not-found", "Saldo da carteira do comprador não encontrado.");
    }

    if (buyerBalance < totalVolumeCents) {
      throw new HttpsError("failed-precondition", "Saldo insuficiente para concluir a compra.");
    }

    // 3. Lê o investimento do comprador
    const buyerInvestedRef = buyerRef.collection("invested").doc(startupId);
    const buyerInvestedDoc = await transaction.get(buyerInvestedRef);

    // 4. Lê o investimento do vendedor (para limpar se zerou)
    const sellerRef = db.collection("users").doc(sellerId);
    const sellerInvestedRef = sellerRef.collection("invested").doc(startupId);
    const sellerInvestedDoc = await transaction.get(sellerInvestedRef);


    transaction.update(buyerRef, { "wallet.balanceCents": FieldValue.increment(-totalVolumeCents) });
    transaction.update(sellerRef, { "wallet.balanceCents": FieldValue.increment(totalVolumeCents) });

    // B. Transferência de Tokens (Atualiza apenas o Comprador)
    if (buyerInvestedDoc.exists) {
      const currentBuyerHolding = buyerInvestedDoc.data() as TokenHolding;
      const novaQuantidade = currentBuyerHolding.quantity + quantitySold;
      const custoAntigo = currentBuyerHolding.quantity * currentBuyerHolding.averagePurchasePriceCents;
      const novoPM = Math.round((custoAntigo + totalVolumeCents) / novaQuantidade);

      transaction.update(buyerInvestedRef, {
        quantity: novaQuantidade,
        averagePurchasePriceCents: novoPM,
        totalPriceCents: FieldValue.increment(totalVolumeCents),
        currentPriceCents: exchangeData.currentPriceCents 
      });
    } else {
      const newHolding: TokenHolding = {
        startupId: startupId,
        startupName: exchangeData.startupName,
        quantity: quantitySold,
        averagePurchasePriceCents: pricePaidPerToken,
        currentPriceCents: exchangeData.currentPriceCents,
        totalPriceCents: totalVolumeCents, 
      };
      transaction.set(buyerInvestedRef, newHolding);
    }

    // C. Limpar a carteira vazia do Vendedor (se aplicável)
    if (sellerInvestedDoc.exists && sellerInvestedDoc.data()?.quantity === 0) {
        transaction.delete(sellerInvestedRef);
    }

    // D. Criar Histórico de Transações (Recibo)
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

    // E. Remover a oferta do balcão
    transaction.delete(exchangeRef);
  });

  // ── Pós-transação: atualizar saldos de investidor na startup ────────────
  if (sellerId && quantitySold > 0) {
    await addUserAsInvestor(startupId, buyerId, {
      tokensOwned: quantitySold,
      totalInvestedCents: valueExchangedCents,
      email: buyerEmail, 
    });
  }
}
