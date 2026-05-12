/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import {HttpsError, onCall} from "firebase-functions/https";
import {normalizeString} from "../shared/validation";
import {listStartupsItems} from "../repositories/startupRepository";
import {StartupStages} from "../types";

export const listStartups = onCall(async (req) => {
  //requireAuthenticatedUser(req);

  const stage = normalizeString(req.data?.stage);

  const search = normalizeString(req.data?.search)
    ?.toLocaleLowerCase("pt-BR");

  if (stage &&
    !StartupStages[stage.toUpperCase() as keyof typeof StartupStages]) {
    throw new HttpsError("invalid-argument", "Invalid stage provided");
  }

  const startups = (await listStartupsItems())
    .filter((startup) => !stage || startup.stage === stage)
    .filter((startup) => {
      if (!search) return true;

      const searchable = [
        startup.name,
        startup.shortDescription,
        startup.stage,
        ...startup.tags,
      ].join(" ").toLocaleLowerCase("pt-BR");

      return searchable.includes(search);
    })
    .sort((left, right) => left.name.localeCompare(right.name, "pt-BR"));

  console.log(startups);

  return {
    count: startups.length,
    filters: {
      availableStages: Object.values(StartupStages),
      stage: stage ?? null,
      search: search ?? null,
    },
    data: startups,
  };
});


