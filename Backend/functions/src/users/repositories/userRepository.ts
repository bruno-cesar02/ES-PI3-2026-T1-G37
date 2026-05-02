import {UserDocument} from "../types";
import {db} from "../shared/firebase";
import {FieldValue} from "firebase-admin/firestore";

/**
 *Função exclusiva para salvar o CPF, Celular e nome no Firestore.
 *@param {string} uid O ID de autenticação do usuário.
 *@param {Object} data Os dados do usuário sem o campo de data de criação.
 */
export async function createUserProfile(
  uid: string,
  data: Omit<UserDocument,
  "createdAt">): Promise<void> {
  await db.collection("users").doc(uid).set({
    ...data,
    createdAt: FieldValue.serverTimestamp(),
  });
}
