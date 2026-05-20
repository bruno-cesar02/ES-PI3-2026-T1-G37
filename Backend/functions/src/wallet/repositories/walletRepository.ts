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

  const {wallet} = userdoc.data() as {wallet: WalletDocument};
  const investedData = investedSnapshot.docs.map(doc => doc.data() as TokenHolding);
  const transactionsData = transactionsSnapshot.docs.map(doc => doc.data() as WalletTransaction);

  return {
    wallet,
    invested: investedData,
    transactions: transactionsData,
  };
}


export async function updateWalletBalance(userId: string, balanceChangeCents: number){

  if(!userId || typeof userId !== "string") {
    console.error("updateWalletBalance esta chamando um userId inválido:", userId);
    throw new HttpsError("invalid-argument", "Invalid userId provided");
  }

  if(!balanceChangeCents || typeof balanceChangeCents !== "number") {
    console.error("updateWalletBalance esta chamando com mudanças de saldo inválidas:", {balanceChangeCents});
    throw new HttpsError("invalid-argument", "Invalid balance change values provided");
  }

  const userRef = db.collection("users").doc(userId)
  
  const [userDoc, investedSnapshot, transactionsSnapshot] = await Promise.all([
    userRef.get(),
    userRef.collection("invested").get(),
    userRef.collection("transactions").get()
  ]);

  const {wallet} = userDoc.data() as WalletDocument;

  console.log(wallet);
  console.log("Saldo atual:", wallet.balanceCents);
  console.log("Mudança de saldo solicitada:", balanceChangeCents);

  if (wallet.balanceCents + balanceChangeCents < 0) {
    throw new HttpsError("failed-precondition", "Saldo insuficiente para esta operação");
  }

  let totalEquityCents = balanceChangeCents;

  investedSnapshot.forEach(doc => {
    const holding = doc.data() as TokenHolding;
    totalEquityCents += holding.quantity * (holding.currentPriceCents / 100);
  });

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
  
  await userRef.update({
    "wallet.balanceCents": FieldValue.increment(balanceChangeCents),
    "wallet.totalequity": totalEquityCents,
    "wallet.totalProfitLoss": totalProfitLossCents
  });
}
