/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import { HttpsError, onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import { db } from "../shared/firebase";

export const listMyInvestments = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);
  
  try {
    // Busca na subcoleção 'invested' do usuário apenas os tokens ativos (quantidade > 0)
    const snapshot = await db.collection("users").doc(user.uid).collection("invested").where("quantity", ">", 0).get();
    
    const investimentos = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: data.startupId,
        nome: data.startupName || "Startup",
        disponiveis: data.quantity || 0,
        precoBase: (data.currentPriceCents || 0) / 100.0 // Converte de centavos para reais
      };
    });

    return { data: investimentos };
  } catch (error) {
    throw new HttpsError("internal", "Erro ao buscar os investimentos da sua carteira.");
  }
});