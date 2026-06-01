/*
    Nicolas Carvalho Nogueira
    RA: 24801664
*/

import { HttpsError, onCall } from "firebase-functions/https";
import { getUserProfileByUid } from "../repositories/userRepository";


export const getUserProfile = onCall (async (request) => {
    const uid = request.auth?.uid;

    if (!uid){
        throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }
    
    const userProfile = await getUserProfileByUid(uid);

    if (userProfile == null){
        throw new HttpsError("not-found", "Usuário inexistente.");
    }

    return userProfile;
});