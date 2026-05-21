/* Bruno César Gonçalves Lima Mota
   RA: 24795502
   Detalhes da startup — agora traz perguntas privadas para investidores. */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {
  getStartupById,
  listPublicQuestions,
  listInvestorVisibleQuestions,
  userIsInvestor,
} from "../repositories/startupRepository";

/**
 * Busca os dados completos de uma startup específica.
 *
 * Esta Firebase Function é callable e deve ser chamada pelo app com:
 *
 * - `id`: identificador da startup no Firestore.
 *
 * A função exige autenticação e retorna a visão detalhada do item 5.2:
 * sumário executivo, estrutura societária, membros externos, vídeos,
 * perguntas e flags de acesso para investidores.
 *
 * Comportamento das perguntas:
 * - Se o usuário NÃO é investidor: retorna apenas perguntas públicas.
 * - Se o usuário É investidor: retorna públicas + privadas, e cada item
 *   carrega o campo `visibility` para que o app possa diferenciar.
*/
export const getStartupDetails = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);

  const startupId = normalizeString(request.data?.id);

  if (!startupId) {
    throw new HttpsError(
      "invalid-argument",
      "Informe o parametro id da startup."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError("not-found", "Startup nao encontrada.");
  }

  const isInvestor = await userIsInvestor(startupId, user.uid);

  const questions = isInvestor
    ? await listInvestorVisibleQuestions(startupId, user.uid)
    : await listPublicQuestions(startupId);

  return {
    data: {
      id: startupId,
      ...startup,
      createdAt: startup.createdAt?.toDate().toISOString() ?? null,
      updatedAt: startup.updatedAt?.toDate().toISOString() ?? null,
      publicQuestions: questions,
      access: {
        isInvestor,
        canTradeTokens: isInvestor,
        canSendPrivateQuestions: isInvestor,
      },
    },
  };
});