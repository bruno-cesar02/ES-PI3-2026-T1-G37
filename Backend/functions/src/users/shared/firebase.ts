import {getAuth} from "firebase-admin/auth";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// Checa se o Firebase já foi iniciado para não dar erro de duplicidade
if (getApps().length === 0) {
  initializeApp();
}

// Exporta o banco e a autenticação já prontos para uso
export const auth = getAuth();
export const db = getFirestore();
