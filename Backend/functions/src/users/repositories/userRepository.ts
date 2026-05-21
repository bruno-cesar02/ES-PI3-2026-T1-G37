/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import {UserDocument} from "../types";
import {db} from "../shared/firebase";
import {FieldValue} from "firebase-admin/firestore";

/**
 *Função exclusiva para salvar os dados CPF, Celular e nome e criar wallet no Firestore.
 *@param {string} uid O ID de autenticação do usuário.
 *@param {Object} data Os dados do usuário sem o campo de data de criação.
 */
export async function createUserProfile(
  uid: string,
  data: Omit<UserDocument,
  "createdAt">): Promise<void> {

    const batch = db.batch();

    const userRef = db.collection("users").doc(uid);
    batch.set(userRef, {
      ...data,
      wallet:{
        userId: uid,
        totalequity: 0,
        totalProfitLoss: 0,
        balanceCents:0,
      },
      createdAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
}
