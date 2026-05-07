/* Luiz Antonio - RA: 24026029*/
import {HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {auth} from "../shared/firebase";

export const resetPassword = onCall(async (request) => {
  const {email, novaSenha} = request.data;

  if (!email || !novaSenha) {
    throw new HttpsError("invalid-argument", "E-mail e nova senha são obrigatórios.");
  }

  if (novaSenha.length < 6) {
    throw new HttpsError("invalid-argument", "A senha deve ter pelo menos 6 caracteres.");
  }

  try {
    const user = await auth.getUserByEmail(email.trim());
    await auth.updateUser(user.uid, {password: novaSenha});
    logger.info(`Senha alterada para o usuário: ${user.uid}`);
    return {
      data: {
        message: "Senha alterada com sucesso!",
      },
    };
  } catch (error: any) {
    if (error.code === "auth/user-not-found") {
      throw new HttpsError("not-found", "E-mail não cadastrado.");
    }
    logger.error("Erro ao alterar senha:", error);
    throw new HttpsError("internal", "Erro interno. Tente novamente.");
  }
});