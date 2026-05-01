import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { UserDocument } from "../types";

const db = getFirestore();

// Função exclusiva para salvar o CPF, Celular e nome no Firestore
export async function createUserProfile(uid: string, data: Omit<UserDocument, 'createdAt'>): Promise<void> {
  await db.collection("users").doc(uid).set({
    ...data,
    createdAt: FieldValue.serverTimestamp(),
  });
}