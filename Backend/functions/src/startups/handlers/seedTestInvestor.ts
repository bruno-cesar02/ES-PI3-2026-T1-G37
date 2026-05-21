/* Bruno César Gonçalves Lima Mota
   RA: 24795502
   Handler de seed: marca o usuário autenticado como investidor de uma
   startup. Útil para testar perguntas privadas e funcionalidades de
   investidor antes da feature de compra de tokens estar pronta.
   Funciona apenas no emulador. */

import {HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {
  addUserAsInvestor,
  getStartupById,
} from "../repositories/startupRepository";

/**
 * Marca o usuário autenticado como investidor de uma startup.
 *
 * Esta Firebase Function é callable e existe exclusivamente para fins de
 * teste em ambiente de emulator. Em produção (sem FUNCTIONS_EMULATOR), a
 * chamada é bloqueada.
 *
 * Recebe em `data`:
 * - `startupId`: identificador da startup.
 *
 * Após esta chamada, o usuário ganha acesso a:
 * - Compra/venda de tokens (quando implementado).
 * - Envio de perguntas privadas.
 * - Visualização de perguntas privadas no `getStartupDetails`.
*/


export const seedTestInvestor = onCall(async (request) => {
  if (!process.env.FUNCTIONS_EMULATOR) {
    throw new HttpsError(
      "permission-denied",
      "Esta funcao so pode ser executada no emulador."
    );
  }

  const user = requireAuthenticatedUser(request);

  const startupId = normalizeString(request.data?.startupId);

  if (!startupId) {
    throw new HttpsError(
      "invalid-argument",
      "Informe o parametro startupId."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError("not-found", "Startup nao encontrada.");
  }

  await addUserAsInvestor(startupId, user.uid, {
    email: user.email,
    tokensOwned: 100,
    totalInvestedCents: 12500,
  });

  logger.info("Usuario marcado como investidor (seed de teste).", {
    startupId,
    uid: user.uid,
  });

  return {
    data: {
      startupId,
      uid: user.uid,
      message: "Usuario agora e investidor desta startup.",
    },
  };
});
