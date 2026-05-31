/* 
Name: Otávio Augusto Antunes Marquez
RA: 24025832
*/
import { WalletDocument, TokenHolding, WalletTransaction} from "../types/index";
import { WalletNotFoundError } from "../shared/errors";
import {db} from "../shared/firebase";
import { HttpsError } from "firebase-functions/https";
import { FieldValue } from "firebase-admin/firestore";

export async function getWalletData(userId: string) {

  if (!userId || typeof userId !== "string") {
    console.error("getWalletData esta chamando um userId inválido:", userId);
    throw new HttpsError("invalid-argument", "Invalid userId provided");
  }

  const userRef = db.collection("users").doc(userId);

  const [userdoc, investedSnapshot, transactionsSnapshot] = await Promise.all([
    userRef.get(),
    userRef.collection("invested").get(),
    userRef.collection("transactions").orderBy("date", "desc").limit(10).get(),
  ]);

  if (!userdoc.exists) {
    throw new WalletNotFoundError();
  }

  const { wallet } = userdoc.data() as WalletDocument ;
  
  const holdings = investedSnapshot.docs.map(doc => ({
    id: doc.id,
    ...(doc.data() as TokenHolding)
  }));

  const batch = db.batch();
  let hasUpdates = false;
  
  let totalEquityCents = 0; 
  let totalProfitLossCents = 0;   // Ajustado para o nome do seu banco
  let totalInvestedCostCents = 0; // Necessário para calcular a porcentagem

  const investedData = await Promise.all(
    holdings.map(async (h) => {
      let coverImageUrl: string | null = null;
      let currentPriceCents = h.currentPriceCents || 0;
      let totalPriceCents = h.totalPriceCents || 0;
      const quantity = h.quantity || 0;
      const averagePurchasePriceCents = h.averagePurchasePriceCents || 0;

      if (h.startupId) {
        const startupDoc = await db.collection("startups").doc(h.startupId).get();
        
        if (startupDoc.exists) {
          const startupData = startupDoc.data() || {};
          coverImageUrl = (startupData.coverImageUrl as string) ?? null;
          
          const realStartupPrice = startupData.currentTokenPriceCents || 0;

          // 1. ATUALIZA O INVESTED SE O PREÇO MUDOU
          if (realStartupPrice !== h.currentPriceCents) {
            currentPriceCents = realStartupPrice;
            totalPriceCents = quantity * realStartupPrice;

            const investedRef = userRef.collection("invested").doc(h.id);
            batch.update(investedRef, {
              currentPriceCents: currentPriceCents,
              totalPriceCents: totalPriceCents
            });
            hasUpdates = true;
          }
        }
      }

      // 2. SOMA PATRIMÔNIO E CUSTOS
      totalEquityCents += totalPriceCents;
      
      const originalCostForThisStartup = averagePurchasePriceCents * quantity;
      totalInvestedCostCents += originalCostForThisStartup;

      // 3. CALCULA O LUCRO/PREJUÍZO USANDO SUA REGRA
      const profitLossForThisStartup = (currentPriceCents - averagePurchasePriceCents) * quantity;
      totalProfitLossCents += profitLossForThisStartup;

      const { id, ...holdingData } = h;
      return { 
        ...holdingData, 
        coverImageUrl,
        currentPriceCents,
        totalPriceCents
      };
    })
  );

  // 4. ATUALIZA O DOC DO USUÁRIO SE ESTIVER DESATUALIZADO
  const currentDbEquity = wallet.totalequity || 0;
  const currentDbProfitLoss = wallet.totalProfitLoss || 0;

  if (currentDbEquity !== totalEquityCents || currentDbProfitLoss !== totalProfitLossCents) {
    batch.update(userRef, {
      "wallet.totalequity": totalEquityCents,
      "wallet.totalProfitLoss": totalProfitLossCents
    });
    hasUpdates = true;
  }

  // Executa todas as gravações (investimentos + usuário) de uma só vez
  if (hasUpdates) {
    await batch.commit();
  }

  // 5. CALCULA A PORCENTAGEM GLOBAL DE LUCRO/PREJUÍZO
  let profitPercentage = 0;
  if (totalInvestedCostCents > 0) {
    profitPercentage = (totalProfitLossCents / totalInvestedCostCents) * 100;
  }

  const transactionsData = transactionsSnapshot.docs.map(doc => doc.data() as WalletTransaction);

  return {
    wallet: {
      ...wallet,
      totalequity: totalEquityCents,
      totalProfitLoss: totalProfitLossCents, // Agora usa a mesma chave do seu banco
      profitPercentage: parseFloat(profitPercentage.toFixed(2)) // Ex: 10.50
    },
    invested: investedData,
    transactions: transactionsData,
  };
}


export async function updateWalletBalance(userId: string, balanceChangeCents: number){

  if(!userId || typeof userId !== "string") {
    console.error("updateWalletBalance esta chamando um userId inválido:", userId);
    throw new HttpsError("invalid-argument", "Invalid userId provided");
  }

  if(typeof balanceChangeCents !== "number") {
    console.error("updateWalletBalance esta chamando com mudanças de saldo inválidas:", {balanceChangeCents});
    throw new HttpsError("invalid-argument", "Invalid balance change values provided");
  }

  const userRef = db.collection("users").doc(userId);
  
  // Removida a busca de 'invested' para deixar a função mais leve e rápida
  const [userDoc, transactionsSnapshot] = await Promise.all([
    userRef.get(),
    userRef.collection("transactions").get()
  ]);

  const {wallet} = userDoc.data() as WalletDocument ;

  if (wallet.balanceCents + balanceChangeCents < 0) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente para esta operação");
  }

  let totalCashOut = 0;
  let totalCashIn = 0;

  transactionsSnapshot.forEach(doc => {
    const transaction = doc.data() as WalletTransaction;
    const fullPrice = transaction.quantity * transaction.priceCents;
    if (transaction.type === "compra") {
      totalCashOut += fullPrice;
    } else if (transaction.type === "venda") {
      totalCashIn += fullPrice;
    }
  });

  const totalProfitLossCents = totalCashIn - totalCashOut;
  
  // Atualiza apenas o saldo em caixa e o histórico de lucros/perdas
  await userRef.update({
    "wallet.balanceCents": FieldValue.increment(balanceChangeCents),
    "wallet.totalProfitLoss": totalProfitLossCents
  });

  if (balanceChangeCents > 0) {
    await userRef.collection("transactions").doc().set({
      type: "deposito",
      startupId: "cash",
      startupName: "Saldo da Carteira",
      quantity: 1,
      priceCents: balanceChangeCents,
      date: FieldValue.serverTimestamp(),
    } as WalletTransaction);
  } else if (balanceChangeCents < 0) {
    await userRef.collection("transactions").doc().set({
      type: "saque",
      startupId: "cash",
      startupName: "Saldo da Carteira",
      quantity: 1,
      priceCents: balanceChangeCents,
      date: FieldValue.serverTimestamp(),
    } as WalletTransaction);
  }
}
