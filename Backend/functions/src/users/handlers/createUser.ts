import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { CreateUserRequest } from "../types";
import { createUserProfile } from "../repositories/userRepository";
import { auth } from "../shared/firebase"; // <-- Puxando o auth inicializado!

export const createUser = onCall(async (request) => {
  const data = request.data as CreateUserRequest;

  if (!data.email || !data.senha || !data.nome || !data.cpf || !data.celular) {
    throw new HttpsError("invalid-argument", "Todos os campos são obrigatórios.");
  }

  let userRecord;

  try {
    // Usando a variável 'auth' que foi importada lá em cima
    userRecord = await auth.createUser({
      email: data.email.trim(),
      password: data.senha,
      displayName: data.nome.trim(),
    });
    logger.info(`Usuário criado no Auth com sucesso: ${userRecord.uid}`);
  } catch (error: any) {
    logger.error("Erro na etapa do Auth:", error);
    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError("already-exists", "Este e-mail já está em uso.");
    }
    throw new HttpsError("internal", "Erro ao criar o usuário no sistema de senhas.");
  }

  try {
    await createUserProfile(userRecord.uid, {
      nome: data.nome.trim(),
      cpf: data.cpf.trim(),
      celular: data.celular.trim(),
      mfaEnabled: false, 
    });
    
    logger.info(`Perfil salvo no Firestore para o usuário: ${userRecord.uid}`);

    return {
      data: {
        uid: userRecord.uid,
        message: "Usuário criado com sucesso!"
      }
    };

  } catch (error: any) {
    logger.error(`Erro no Firestore. Apagando usuário ${userRecord.uid} do Auth.`, error);
    await auth.deleteUser(userRecord.uid);
    throw new HttpsError("internal", "Erro ao salvar os dados. Tente novamente.");
  }
});   