import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {allowedVisibilities} from "../shared/constants";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {
  createQuestion,
  getStartupById,
  userIsInvestor,
} from "../repositories/startupRepository";
import {QuestionVisibility, StartupQuestionDocument} from "../types";

export const createStartupQuestion = onCall(async (request) => {
  const user = requireAuthenticatedUser(request);
  const startupId = normalizeString(request.data?.startupId);
  const text = normalizeString(request.data?.text);
  
  // Usa o Enum como padrão caso não venha nada
  const visibility = (normalizeString(request.data?.visibility) as QuestionVisibility) ?? QuestionVisibility.PUBLICA;

  if (!startupId || !text) {
    throw new HttpsError("invalid-argument", "Informe startupId e text.");
  }

  if (!allowedVisibilities.includes(visibility)) {
    throw new HttpsError(
      "invalid-argument",
      "Visibility invalida. Use publica ou privada."
    );
  }

  const startup = await getStartupById(startupId);

  if (!startup) {
    throw new HttpsError("not-found", "Startup nao encontrada.");
  }

  // Verifica se a visibilidade é PRIVADA usando o Enum
  if (visibility === QuestionVisibility.PRIVADA) {
    const isInvestor = await userIsInvestor(startupId, user.uid);

    if (!isInvestor) {
      throw new HttpsError(
        "permission-denied",
        "Somente investidores desta startup podem enviar perguntas privadas."
      );
    }
  }

  const question: StartupQuestionDocument = {
    authorUid: user.uid,
    authorEmail: user.email,
    text,
    visibility: visibility,
    createdAt: FieldValue.serverTimestamp(),
  };

  const questionId = await createQuestion(startupId, question);

  logger.info("Pergunta criada para startup.", {
    startupId,
    questionId,
    visibility,
  });

  return {
    data: {
      id: questionId,
      startupId,
      visibility,
    },
  };
});