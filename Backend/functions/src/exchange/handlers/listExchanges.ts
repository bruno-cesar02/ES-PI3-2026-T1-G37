import { onCall, HttpsError } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import { db } from "../shared/firebase";

export const listExchanges = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);
  try {
    // Busca todas as subcoleções "exchanges" de todas as startups
    const snapshot = await db.collectionGroup("exchanges").get();
    
    const ofertas = snapshot.docs.map(doc => {
      const data = doc.data();
      const isMinha = data.tokenOwnerId === user.uid;
      const currentPriceCents = data.currentPriceCents || 0;
      const purchasePriceCents = data.purchasePriceCents || currentPriceCents;
      
      return {
        id: doc.id,
        startupId: data.startupId,
        startupNome: data.startupName,
        ofertanteNome: isMinha ? "Você" : "Investidor Anônimo",
        isMinha: isMinha,
        tokens: data.quantity,
        precoUnitarioCents: purchasePriceCents,
        variacaoPercent: currentPriceCents > 0 
          ? ((purchasePriceCents - currentPriceCents) / currentPriceCents) * 100 
          : 0
      };
    });

    // Retorna os dois arrays prontos para as abas do Flutter
    return {
      disponiveis: ofertas.filter(o => !o.isMinha),
      minhas: ofertas.filter(o => o.isMinha)
    };
  } catch (error) {
    throw new HttpsError("internal", "Erro ao buscar ofertas do balcão.");
  }
});