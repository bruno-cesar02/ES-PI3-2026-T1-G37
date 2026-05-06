/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import {HttpsError, onCall} from "firebase-functions/https";
import { seedDemoStartups } from "../repositories/startupRepository";
import { normalizeString } from "../shared/validation";


export const seedStartupCatalog = onCall(async (req) => {
  if (!process.env.FUNCTIONS_EMULATOR) {
    const seedKey = normalizeString(req.data?.seedKey);

    if (!process.env.SEED_STARTUP_CATALOG_KEY || seedKey !== process.env.SEED_STARTUP_CATALOG_KEY) {
      throw new HttpsError("permission-denied", "Invalid seed key");
    }
  }

  const startupIds = await seedDemoStartups();

  return {
    data: {
      count: startupIds.length,
      ids: startupIds,
    },
  };
});