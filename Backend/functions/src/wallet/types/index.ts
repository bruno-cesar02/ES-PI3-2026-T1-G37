/* 
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import { FieldValue, Timestamp } from "firebase-admin/firestore";

export type WalletDocument = {
  wallet: {
    balanceCents: number,
    totalequity: number,
    totalProfitLoss: number,
    userId: string,
  }
}

export type TokenHolding = {
  startupId: string,
  startupName: string,
  quantity: number,
  averagePurchasePriceCents: number,
  currentPriceCents: number,
}

export type WalletTransaction = {
  type: "compra" | "venda",
  startupId: string,
  startupName: string,
  quantity: number,
  priceCents: number,
  date: Timestamp | FieldValue,
}