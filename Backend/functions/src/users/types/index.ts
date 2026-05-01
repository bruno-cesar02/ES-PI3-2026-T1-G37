import { FieldValue, Timestamp } from "firebase-admin/firestore";

// O que o Flutter manda para a Function
export type CreateUserRequest = {
  nome: string;
  email: string;
  cpf: string;
  celular: string;
  senha: string;
};

// O que a Function salva no banco de dados (Firestore)
export type UserDocument = {
  nome: string;
  cpf: string;
  celular: string;
  createdAt: FieldValue | Timestamp;
  mfaEnabled: boolean; // Já deixamos pronto para a Autenticação de 2 Fatores
};