/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import {CallableRequest, HttpsError} from "firebase-functions/https";
import { AuthenticatedUser } from "../types";

export function requireAuthenticatedUser(req: CallableRequest): AuthenticatedUser {

  if (!req.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated to perform this action");
  }

  return {
    
    
    uid: req.auth.uid,
    email: req.auth.token.email,
  };
}