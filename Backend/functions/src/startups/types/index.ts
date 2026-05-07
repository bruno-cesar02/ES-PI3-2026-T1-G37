/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 
import { FieldValue, Timestamp } from "firebase-admin/firestore";


export type AuthenticatedUser = {
  uid: string,
  email?: string,
};

export enum StartupStages {
  NOVA = "nova",
  EM_OPERACAO = "em_operacao",
  EM_EXPANSAO = "em_expansao"
}

export enum QuestionVisibility {
  PUBLICA = "publica",
  PRIVADA = "privada"
}

export type Founder = {
  name: string,
  role: string,
  equityPercentage: number,
  bio?: string,
}


export type ExternalMember = {
  name: string,
  role: string,
  organization?: string,
}

export type StartupDocument = {
  name: string,
  stage: StartupStages,
  shortDescription: string,
  description: string,
  executiveSummary: string,
  capitalRaisedCents: number,
  totalTokensIssued: number,
  currentTokenPriceCents: number,
  founder: Founder[],
  externalMembers: ExternalMember[],
  demoVideos: string[],
  pitchDeckUrl?: string,
  coverImageUrl?: string,
  tags: string[],
  createdAt?: Timestamp,
  updatedAt?: Timestamp,
}


export type StartupListItem = {
  id: string,
  name: string,
  stage: StartupStages,
  shortDescription: string,
  capitalRaisedCents: number,
  totalTokensIssued: number,
  currentTokenPriceCents: number,
  coverImageUrl?: string,
  tags: string[],
}


export type StartupQuestionDocument = {
  authorUid: string,
  authorEmail?: string,
  text: string,
  visibility: QuestionVisibility,
  answer?: string,
  answeredAt?: Timestamp,
  createdAt: FieldValue,
}


