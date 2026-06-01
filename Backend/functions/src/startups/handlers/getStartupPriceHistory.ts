/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import { Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";

export const getStartupPriceHistory = onCall(async (req) => {

  const { startupId, range } = req.data;

  if (!startupId) {
    throw new HttpsError("invalid-argument", "O ID da startup é obrigatório.");
  }

  const startupRef = db.collection("startups").doc(startupId);
  const startupDoc = await startupRef.get();
  
  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada.");
  }

  // 1. Lógica para calcular a data de corte com base no 'range'
  let startDate: Date | null = null;
  const now = new Date();

  switch (range) {
    case "1D": // 1 Dia
      startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      break;
    case "1S": // 1 Semana (7 dias)
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case "1M": // 1 Mês
      startDate = new Date(now);
      startDate.setMonth(now.getMonth() - 1);
      break;
    case "6M": // 6 Meses
      startDate = new Date(now);
      startDate.setMonth(now.getMonth() - 6);
      break;
    case "YTD": // Year to Date (Desde 1º de Janeiro do ano atual)
      startDate = new Date(now.getFullYear(), 0, 1);
      break;
    default:
      // Se mandar "ALL" ou não mandar nenhum range, startDate continua null (busca tudo)
      startDate = null;
      break;
  }

  // 2. Montagem da Query dinâmica
  let historyQuery = startupRef.collection("priceHistory").orderBy("createdAt", "asc");

  if (startDate) {
    // Aplica o filtro: só pega os documentos criados DEPOIS da data de corte
    historyQuery = historyQuery.where("createdAt", ">=", startDate);
  }

  const historySnapshot = await historyQuery.get();

  // 3. Mapeia os documentos para o Frontend
  const historyData = historySnapshot.docs.map(doc => {
    const data = doc.data();
    
    const createdAtTimestamp = data.createdAt instanceof Timestamp 
      ? data.createdAt.toMillis() 
      : Date.now();

    return {
      id: doc.id,
      priceCents: data.priceCents,
      reason: data.reason || "unknown",
      createdAtMs: createdAtTimestamp, 
    };
  });

  const startupData = startupDoc.data() || {};

  // 4. Retorna os dados agregados
  return {
    startupId: startupId,
    name: startupData.name || "",
    currentPriceCents: startupData.currentTokenPriceCents || 0,
    previousPriceCents: startupData.previousTokenPriceCents || 0,
    averagePriceCents: startupData.averageTokenPriceCents || 0,
    history: historyData
  };
});