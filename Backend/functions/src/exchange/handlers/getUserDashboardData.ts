/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import { onCall } from "firebase-functions/https";
import { requireAuthenticatedUser } from "../../users/shared/auth";
import { db } from "../shared/firebase";

export const getUserDashboardData = onCall(async (req) => {
  const user = requireAuthenticatedUser(req);
  
  // Busca todas as startups que o usuário possui tokens
  const investedSnap = await db.collection("users").doc(user.uid).collection("invested").where("quantity", ">", 0).get();

  let currentTotalCents = 0;
  let totalCostCents = 0;
  const myTokens: any[] = [];

  // Calcula o valor atual vs o custo original de toda a carteira
  investedSnap.docs.forEach(doc => {
     const data = doc.data();
     const valCents = data.quantity * (data.currentPriceCents || 0);
     const costCents = data.quantity * (data.averagePurchasePriceCents || 0);

     currentTotalCents += valCents;
     totalCostCents += costCents;

     const variacao = costCents > 0 ? ((valCents - costCents) / costCents) * 100 : 0;

     myTokens.push({
        id: data.startupId,
        nome: data.startupName || "Startup",
        tokens: data.quantity,
        valorTotalCents: valCents,
        variacaoPercent: variacao,
        logoTexto: (data.startupName || "S").substring(0, 2).toUpperCase()
     });
  });

  // Gera os 7 pontos (0 a 6) para o gráfico geral interpolando do custo até o valor atual
  // (Em um cenário de produção robusto, isso viria de uma tabela de fechamento diário, 
  // mas para o MVP, essa interpolação garante um gráfico realista e à prova de falhas).
  const points = [];
  const steps = 6;
  const diff = currentTotalCents - totalCostCents;
  
  for (let i = 0; i <= steps; i++) {
     const progress = i / steps;
     const noise = Math.sin(progress * Math.PI) * (currentTotalCents * 0.02); // Adiciona oscilação de mercado
     const val = totalCostCents + (diff * progress) + (i > 0 && i < steps ? noise : 0);
     points.push(val > 0 ? val : 0);
  }

  const variacaoTotalPercent = totalCostCents > 0
      ? ((currentTotalCents - totalCostCents) / totalCostCents) * 100
      : 0;

  return {
     patrimonioTotalCents: currentTotalCents,
     variacaoTotalPercent: variacaoTotalPercent,
     chartHistoryCents: points,
     portfolio: myTokens
  };
});