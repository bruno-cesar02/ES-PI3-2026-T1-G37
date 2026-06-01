/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 
import { QuestionVisibility, StartupStages } from "../types";

export const allowedStages: StartupStages[] = [
  StartupStages.NOVA,
  StartupStages.EM_OPERACAO,
  StartupStages.EM_EXPANSAO,
];

export const allowedVisibilities: QuestionVisibility[] = [
  QuestionVisibility.PUBLICA,
  QuestionVisibility.PRIVADA,
];