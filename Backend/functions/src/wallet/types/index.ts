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
  id?: string,
  startupId: string,
  startupName: string,
  quantity: number,
  averagePurchasePriceCents: number,
  currentPriceCents: number,
  totalPriceCents?: number,
  coverImageUrl?: string | null,
}

export type WalletTransaction = {
  type: "deposito" | "saque" | "compra" | "venda",
  startupId: string,
  startupName: string,
  quantity: number,
  priceCents: number,
  date: Timestamp | FieldValue,
}