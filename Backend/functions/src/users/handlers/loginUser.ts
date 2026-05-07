import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { auth } from "../shared/firebase";

export const loginUser = onCall(async (request) => {
  const email = request.data?.email;
  const senha = request.data?.senha;
  const apiKey = request.data?.apiKey;

  if (!email || !senha || !apiKey) {
    throw new HttpsError(
      "invalid-argument",
      "E-mail, senha e API Key são obrigatórios."
    );
  }

  try {
    const isEmulator = process.env.FUNCTIONS_EMULATOR === "true" || process.env.FUNCTIONS_EMULATOR === "1";
    
    let url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`;
    
    if (isEmulator) {
      const authEmulatorHost = process.env.FIREBASE_AUTH_EMULATOR_HOST || "127.0.0.1:9099";
      url = `http://${authEmulatorHost}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`;
      logger.info(`[MODO DEV] Redirecionando validação para o emulador: ${authEmulatorHost}`);
    }

    // 3. Faz a requisição REST
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: email.trim(),
        password: senha,
        returnSecureToken: true,
      }),
    });

    const payload = await response.json();

    if (!response.ok) {
      logger.error("Erro na validação da REST API:", payload);
      throw new HttpsError("permission-denied", "E-mail ou senha inválidos.");
    }

    const customToken = await auth.createCustomToken(payload.localId);

    logger.info(`Login validado com sucesso para o usuário: ${payload.localId}`);

    return {
      data: {
        customToken: customToken,
        uid: payload.localId,
      },
    };
  } catch (error: any) {
    if (error instanceof HttpsError) throw error;
    
    logger.error("Erro interno no processo de login:", error);

    if (error.name === "ReferenceError" && error.message.includes("fetch")) {
        throw new HttpsError("internal", "Versão do Node.js incompatível com fetch. Atualize para o Node 18+.");
    }
    
    throw new HttpsError("internal", "Erro ao processar o login. Tente novamente.");
  }
});