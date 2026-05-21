/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { Timestamp } from "firebase-admin/firestore";

export type TokenTransactionType = "compra" | "venda";

export type TokenTransactionDocument = {
  userId: string,
  startupId: string,
  startupName: string,
  currentTokenPriceCents: number,
  tokenAmount: number,
  totalPriceCents: number,
  createdAt?: Timestamp,
}

export type ExchangeDocument = {
  startupId: string,
  startupName: string,
  tokenOwnerId: string,
  quantity: number,
  averagePurchasePriceCents: number,
  currentPriceCents: number,
  createdAt?: Timestamp,
}



/*
startupId: string,
  startupName: string,
  quantity: number,
  averagePurchasePriceCents: number,
  currentPriceCents: number,

  export type WalletTransaction = {
  type: "compra" | "venda",
  startupId: string,
  startupName: string,
  quantity: number,
  priceCents: number,
  date: Timestamp | FieldValue,
}
*/