/* Eduardo Neves de Aguiar 
  RA:24026029*/
import {HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {auth} from "../shared/firebase";

export const forgotPassword = onCall(async (request) => {
  const {email} = request.data;

  if (!email || typeof email !== "string") {
    throw new HttpsError("invalid-argument", "E-mail é obrigatório.");
  }

  try {
    await auth.getUserByEmail(email.trim());

    await auth.generatePasswordResetLink(email.trim(), {
      url: "https://pi3-g37.web.app",
    });

    logger.info(`Link de redefinição enviado para: ${email}`);

    return {
      data: {
        message: "Instruções enviadas para o seu e-mail.",
      },
    };
  } catch (error: any) {
    if (error.code === "auth/user-not-found") {
      return {
        data: {
          message: "Instruções enviadas para o seu e-mail.",
        },
      };
    }
    logger.error("Erro ao enviar e-mail de recuperação:", error);
    throw new HttpsError("internal", "Erro interno. Tente novamente.");
  }
});
