import { HttpsError, onCall } from "firebase-functions/https";
import { getAuth } from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";
import { CreateUserRequest } from "../types";
import { createUserProfile } from "../repositories/userRepository";

export const createUser = onCall(async (request) => {
  const data = request.data as CreateUserRequest;

  // 1. Checa se o app mandou todos os dados obrigatórios
  if (!data.email || !data.senha || !data.nome || !data.cpf || !data.celular) {
    throw new HttpsError("invalid-argument", "Todos os campos são obrigatórios.");
  }

  const auth = getAuth();
  let userRecord;

  // 2. Tenta criar no Auth primeiro
  try {
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

  // 3. Tenta salvar no Firestore
  try {
    await createUserProfile(userRecord.uid, {
      nome: data.nome.trim(),
      cpf: data.cpf.trim(),
      celular: data.celular.trim(),
      mfaEnabled: false, 
    });
    
    logger.info(`Perfil salvo no Firestore para o usuário: ${userRecord.uid}`);

    // 4. Sucesso total! Retorna para o app
    return {
      data: {
        uid: userRecord.uid,
        message: "Usuário criado com sucesso!"
      }
    };

  } catch (error: any) {
    // 🚨 A MÁGICA DO ROLLBACK ACONTECE AQUI 🚨
    // Deu erro no Firestore. Então vamos apagar o usuário do Auth para evitar o limbo!
    logger.error(`Erro no Firestore. Fazendo rollback: Apagando usuário ${userRecord.uid} do Auth.`, error);
    
    await auth.deleteUser(userRecord.uid);
    
    throw new HttpsError("internal", "Erro ao salvar os dados do perfil. O cadastro foi cancelado, tente novamente.");
  }
});