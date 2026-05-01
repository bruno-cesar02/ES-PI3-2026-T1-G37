import { UserDocument } from "../types";
import { db } from "../shared/firebase";
import { FieldValue } from "firebase-admin/firestore";

// Função exclusiva para salvar o CPF, Celular e nome no Firestore
export async function createUserProfile(uid: string, data: Omit<UserDocument, 'createdAt'>): Promise<void> {
  await db.collection("users").doc(uid).set({
    ...data,
    createdAt: FieldValue.serverTimestamp(),
  });
}