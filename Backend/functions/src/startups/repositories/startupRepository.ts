/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

import {FieldValue} from "firebase-admin/firestore";
import { StartupDocument, StartupListItem, StartupStages } from "../types";
import { db } from "../shared/firebase";

const startupsCollection = db.collection("startups");

const demoStartups : Array<StartupDocument & {id: string}> = [
  {
    id: "demo-startup-1",
    name: "TechNova",
    stage: StartupStages.EM_OPERACAO,
    shortDescription: "Revolucionando a indústria de tecnologia com soluções inovadoras.",
    description: "A TechNova é uma startup focada em desenvolver soluções tecnológicas inovadoras para empresas de diversos setores. Com uma equipe de especialistas em inteligência artificial, big data e desenvolvimento de software, a TechNova tem como missão transformar a maneira como as empresas utilizam a tecnologia para alcançar seus objetivos.",
    executiveSummary: "A TechNova é uma startup de tecnologia que oferece soluções inovadoras para empresas. Com uma equipe especializada em inteligência artificial e desenvolvimento de software, a TechNova tem como objetivo transformar a maneira como as empresas utilizam a tecnologia para alcançar seus objetivos.",
    capitalRaisedCents: 50000000,
    totalTokensIssued: 1000000,
    currentTokenPriceCents: 5000,
    founder: [
      {
        name: "Alice Silva",
        role: "CEO",
        equityPercentage: 40,
        bio: "Alice é uma empreendedora experiente com um histórico de sucesso em startups de tecnologia. Ela é apaixonada por inovação e tem uma visão clara para o futuro da TechNova."
      },
      {
        name: "Bruno Costa",
        role: "CTO",
        equityPercentage: 30,
        bio: "Bruno é um especialista em tecnologia com mais de 15 anos de experiência em desenvolvimento de software e inteligência artificial. Ele lidera a equipe técnica da TechNova, garantindo que as soluções oferecidas sejam de alta qualidade e inovadoras."
      }
    ],
    externalMembers: [
      {
        name: "Carla Mendes",
        role: "Conselheira",
        organization: "Tech Advisors Inc."
      }
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo1"],
    pitchDeckUrl: "https://www.slideshare.net/demo1",
    coverImageUrl: "https://example.com/cover1.jpg",
    tags: ["tecnologia", "inovação", "inteligência artificial"],
  },
];

function toListItem(id: string, startup: StartupDocument): StartupListItem {
  return {
    id,
    name: startup.name,
    stage: startup.stage,
    shortDescription: startup.shortDescription,
    capitalRaisedCents: startup.capitalRaisedCents,
    totalTokensIssued: startup.totalTokensIssued,
    currentTokenPriceCents: startup.currentTokenPriceCents,
    coverImageUrl: startup.coverImageUrl,
    tags: startup.tags,
  }
}

export async function listStartupsItems(): Promise<StartupListItem[]> {
  const snapshot = await startupsCollection.limit(100).get();

  return snapshot.docs.map(doc => toListItem(doc.id, doc.data() as StartupDocument));
}

export async function getStartupById(startupId: string): Promise<StartupDocument | undefined> {
  const startupSnapshot = await startupsCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return undefined;
  }

  return startupSnapshot.data() as StartupDocument;
}

export async function seedDemoStartups() : Promise<string[]> {
  const batch = db.batch();

  demoStartups.forEach(startup => {
    const {id, ...data} = startup;
    const startupRef = startupsCollection.doc(id);
    batch.set(startupRef, {...data, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()});
  }, {merge:true});

  await batch.commit();

  return demoStartups.map(s => s.id);
}

// Continuar com dados das sturtups sobre usuarios