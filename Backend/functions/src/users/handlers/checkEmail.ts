/* Eduardo Neves - RA: 24026029*/
import {HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {auth} from "../shared/firebase";

export const checkEmail = onCall(async (request) => {
  const {email} = request.data;

  if (!email || typeof email !== "string") {
    throw new HttpsError("invalid-argument", "E-mail é obrigatório.");
  }

  try {
    await auth.getUserByEmail(email.trim());
    logger.info(`E-mail encontrado: ${email}`);
    return {
      data: {
        exists: true,
        message: "E-mail encontrado.",
      },
    };
  } catch (error: any) {
    if (error.code === "auth/user-not-found") {
      throw new HttpsError("not-found", "E-mail não cadastrado.");
    }
    logger.error("Erro ao buscar e-mail:", error);
    throw new HttpsError("internal", "Erro interno. Tente novamente.");
  }
});