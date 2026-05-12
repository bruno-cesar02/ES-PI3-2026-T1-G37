/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import {FieldValue} from "firebase-admin/firestore";
import { StartupDocument, StartupListItem, StartupStages, StartupQuestionDocument } from "../types";
import { db } from "../shared/firebase";

const startupsCollection = db.collection("startups");

const demoStartups : Array<StartupDocument & {id: string}> = [

  // ── EM OPERAÇÃO ───────────────────────────────────────────────────────────

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
        bio: "Alice é uma empreendedora experiente com um histórico de sucesso em startups de tecnologia.",
      },
      {
        name: "Bruno Costa",
        role: "CTO",
        equityPercentage: 30,
        bio: "Bruno é um especialista em tecnologia com mais de 15 anos de experiência em desenvolvimento de software.",
      },
    ],
    externalMembers: [
      { name: "Carla Mendes", role: "Conselheira", organization: "Tech Advisors Inc." },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo1"],
    pitchDeckUrl: "https://www.slideshare.net/demo1",
    coverImageUrl: "https://example.com/cover1.jpg",
    tags: ["tecnologia", "inovação", "inteligência artificial"],
  },

  {
    id: "demo-startup-2",
    name: "HealthAI",
    stage: StartupStages.EM_OPERACAO,
    shortDescription: "Inteligência artificial aplicada ao diagnóstico médico preventivo.",
    description: "A HealthAI desenvolve soluções de inteligência artificial para auxiliar médicos no diagnóstico precoce de doenças. Sua plataforma analisa exames e histórico clínico para identificar padrões e sugerir diagnósticos com alta precisão.",
    executiveSummary: "Startup de saúde digital em operação, com foco em diagnóstico preventivo por IA. Já integrada a 3 clínicas parceiras e com mais de 5.000 análises realizadas.",
    capitalRaisedCents: 75000000,
    totalTokensIssued: 1500000,
    currentTokenPriceCents: 4800,
    founder: [
      {
        name: "Mariana Oliveira",
        role: "CEO",
        equityPercentage: 45,
        bio: "Médica e empreendedora, Mariana combina experiência clínica com visão de negócio para liderar a HealthAI.",
      },
      {
        name: "Pedro Alves",
        role: "CTO",
        equityPercentage: 35,
        bio: "Especialista em machine learning com foco em aplicações médicas.",
      },
    ],
    externalMembers: [
      { name: "Dr. Roberto Lima", role: "Conselheiro Médico", organization: "Hospital das Clínicas" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo2"],
    pitchDeckUrl: "https://www.slideshare.net/demo2",
    coverImageUrl: "https://example.com/cover2.jpg",
    tags: ["saúde", "inteligência artificial", "diagnóstico"],
  },

  {
    id: "demo-startup-3",
    name: "EduFlex",
    stage: StartupStages.EM_OPERACAO,
    shortDescription: "Plataforma adaptativa de educação personalizada para o ensino básico.",
    description: "A EduFlex utiliza algoritmos de aprendizado adaptativo para personalizar o conteúdo educacional de acordo com o ritmo e estilo de aprendizagem de cada aluno. Atende escolas públicas e privadas com resultados comprovados de melhora no desempenho.",
    executiveSummary: "EdTech em operação com mais de 10.000 alunos ativos em 50 escolas. Modelo SaaS com receita recorrente e crescimento de 20% ao mês.",
    capitalRaisedCents: 40000000,
    totalTokensIssued: 800000,
    currentTokenPriceCents: 3500,
    founder: [
      {
        name: "Lucas Ferreira",
        role: "CEO",
        equityPercentage: 42,
        bio: "Professor universitário e empreendedor serial, Lucas fundou a EduFlex após 10 anos em sala de aula.",
      },
      {
        name: "Ana Paula Souza",
        role: "CPO",
        equityPercentage: 28,
        bio: "Designer de experiências educacionais com foco em acessibilidade e engajamento.",
      },
    ],
    externalMembers: [
      { name: "Prof. Carlos Neto", role: "Conselheiro Pedagógico", organization: "Unicamp" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo3"],
    pitchDeckUrl: "https://www.slideshare.net/demo3",
    coverImageUrl: "https://example.com/cover3.jpg",
    tags: ["educação", "edtech", "aprendizado adaptativo"],
  },

  // ── NOVA ─────────────────────────────────────────────────────────────────

  {
    id: "demo-startup-4",
    name: "FinSmart",
    stage: StartupStages.NOVA,
    shortDescription: "Gestão financeira inteligente para pequenos empreendedores.",
    description: "A FinSmart é uma fintech voltada para pequenos empreendedores que precisam de controle financeiro simples e eficiente. Seu aplicativo integra contas bancárias, categoriza gastos automaticamente e sugere metas de economia personalizadas.",
    executiveSummary: "Fintech em fase de validação com MVP lançado. Primeiros 500 usuários cadastrados organicamente em 30 dias após o lançamento.",
    capitalRaisedCents: 20000000,
    totalTokensIssued: 500000,
    currentTokenPriceCents: 2000,
    founder: [
      {
        name: "Rafael Mendonça",
        role: "CEO",
        equityPercentage: 50,
        bio: "Economista com experiência em banco de investimentos, Rafael fundou a FinSmart para democratizar o acesso à educação financeira.",
      },
      {
        name: "Juliana Torres",
        role: "CTO",
        equityPercentage: 30,
        bio: "Desenvolvedora full-stack especializada em sistemas financeiros e segurança de dados.",
      },
    ],
    externalMembers: [
      { name: "Eduardo Campos", role: "Mentor", organization: "Mescla" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo4"],
    pitchDeckUrl: "https://www.slideshare.net/demo4",
    coverImageUrl: "https://example.com/cover4.jpg",
    tags: ["fintech", "finanças", "empreendedorismo"],
  },

  {
    id: "demo-startup-5",
    name: "EcoTrack",
    stage: StartupStages.NOVA,
    shortDescription: "Rastreamento de pegada de carbono para empresas e pessoas físicas.",
    description: "A EcoTrack desenvolve ferramentas para medir, monitorar e compensar a pegada de carbono de empresas e indivíduos. Sua plataforma gamificada incentiva a adoção de hábitos sustentáveis com recompensas reais.",
    executiveSummary: "Greentech em ideação avançada com protótipo funcional. Parceria firmada com 2 empresas de médio porte para projeto piloto de compensação de carbono.",
    capitalRaisedCents: 15000000,
    totalTokensIssued: 400000,
    currentTokenPriceCents: 1500,
    founder: [
      {
        name: "Fernanda Castro",
        role: "CEO",
        equityPercentage: 48,
        bio: "Engenheira ambiental apaixonada por sustentabilidade e impacto social positivo.",
      },
      {
        name: "Thiago Brito",
        role: "CTO",
        equityPercentage: 32,
        bio: "Desenvolvedor com experiência em IoT e sistemas de monitoramento ambiental.",
      },
    ],
    externalMembers: [
      { name: "Dra. Sofia Gomes", role: "Conselheira", organization: "PUC-Campinas" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo5"],
    pitchDeckUrl: "https://www.slideshare.net/demo5",
    coverImageUrl: "https://example.com/cover5.jpg",
    tags: ["sustentabilidade", "greentech", "carbono"],
  },

  {
    id: "demo-startup-6",
    name: "AgriBot",
    stage: StartupStages.NOVA,
    shortDescription: "Robótica agrícola acessível para pequenos produtores rurais.",
    description: "A AgriBot desenvolve robôs agrícolas de baixo custo para automatizar tarefas repetitivas no campo, como irrigação, monitoramento de pragas e colheita. Foco em pequenos produtores que não têm acesso à automação industrial.",
    executiveSummary: "Agritech em fase inicial com protótipo de robô testado em campo. Parceria com cooperativa agrícola do interior de São Paulo para validação em escala.",
    capitalRaisedCents: 10000000,
    totalTokensIssued: 300000,
    currentTokenPriceCents: 1200,
    founder: [
      {
        name: "Marcos Vieira",
        role: "CEO",
        equityPercentage: 45,
        bio: "Engenheiro mecatrônico filho de agricultor, Marcos combina conhecimento técnico com vivência no campo.",
      },
      {
        name: "Camila Rocha",
        role: "CTO",
        equityPercentage: 35,
        bio: "Especialista em robótica e sistemas embarcados com foco em aplicações agrícolas.",
      },
    ],
    externalMembers: [
      { name: "João Batista", role: "Mentor", organization: "Embrapa" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo6"],
    pitchDeckUrl: "https://www.slideshare.net/demo6",
    coverImageUrl: "https://example.com/cover6.jpg",
    tags: ["agritech", "robótica", "agricultura"],
  },

  {
    id: "demo-startup-karpos",
    name: "Karpós S.A",
    stage: StartupStages.NOVA,
    shortDescription: "Soluções tecnológicas para o agronegócio brasileiro.",
    description: "A Karpós S.A é uma startup de agronegócio que desenvolve soluções tecnológicas para aumentar a produtividade e sustentabilidade do campo brasileiro. Com foco em pequenos e médios produtores, a Karpós oferece ferramentas de gestão, monitoramento e análise de dados agrícolas.",
    executiveSummary: "Startup em fase inicial com foco em tecnologia para o agronegócio. Protótipo validado com produtores rurais da região de Campinas e em busca de capital para expansão.",
    capitalRaisedCents: 12000000,
    totalTokensIssued: 350000,
    currentTokenPriceCents: 1500,
    founder: [
      {
        name: "Felipe Ragonha",
        role: "CEO",
        equityPercentage: 100,
        bio: "Empreendedor apaixonado pelo agronegócio, Felipe fundou a Karpós com a missão de levar tecnologia acessível ao campo brasileiro.",
      },
    ],
    externalMembers: [],
    demoVideos: [],
    pitchDeckUrl: undefined,
    coverImageUrl: "https://example.com/cover-karpos.jpg",
    tags: ["agronegócio", "agritech", "tecnologia rural"],
  },

  // ── EM EXPANSÃO ───────────────────────────────────────────────────────────

  {
    id: "demo-startup-7",
    name: "LogiFlow",
    stage: StartupStages.EM_EXPANSAO,
    shortDescription: "Otimização de rotas e logística urbana com inteligência artificial.",
    description: "A LogiFlow é uma logtech que utiliza IA para otimizar rotas de entrega em tempo real, reduzindo custos e emissões de carbono. Atende e-commerces e transportadoras com redução média de 30% no tempo de entrega.",
    executiveSummary: "Logtech em expansão nacional com operação consolidada em São Paulo e Rio de Janeiro. Crescimento de 150% no último ano com 200 clientes ativos.",
    capitalRaisedCents: 150000000,
    totalTokensIssued: 3000000,
    currentTokenPriceCents: 8500,
    founder: [
      {
        name: "Roberto Santos",
        role: "CEO",
        equityPercentage: 35,
        bio: "Ex-executivo de logística com 20 anos de experiência em grandes varejistas.",
      },
      {
        name: "Patricia Lima",
        role: "CTO",
        equityPercentage: 25,
        bio: "Cientista de dados especializada em otimização de rotas e algoritmos de IA.",
      },
      {
        name: "Diego Souza",
        role: "COO",
        equityPercentage: 20,
        bio: "Especialista em operações e expansão de startups de tecnologia.",
      },
    ],
    externalMembers: [
      { name: "Henrique Faria", role: "Conselheiro", organization: "Mescla" },
      { name: "Ana Beatriz", role: "Mentora", organization: "Aceleradora Nacional" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo7"],
    pitchDeckUrl: "https://www.slideshare.net/demo7",
    coverImageUrl: "https://example.com/cover7.jpg",
    tags: ["logtech", "logística", "inteligência artificial"],
  },

  {
    id: "demo-startup-8",
    name: "MentalCare",
    stage: StartupStages.EM_EXPANSAO,
    shortDescription: "Plataforma de saúde mental acessível com terapia online e IA.",
    description: "A MentalCare conecta pessoas a psicólogos credenciados de forma acessível e oferece suporte complementar através de uma IA empática. Com planos a partir de R$ 49/mês, democratiza o acesso à saúde mental no Brasil.",
    executiveSummary: "Healthtech em expansão com 50.000 usuários ativos e 800 psicólogos cadastrados. Presente em todas as regiões do Brasil com receita mensal recorrente de R$ 2,5M.",
    capitalRaisedCents: 200000000,
    totalTokensIssued: 4000000,
    currentTokenPriceCents: 12000,
    founder: [
      {
        name: "Isabella Martins",
        role: "CEO",
        equityPercentage: 38,
        bio: "Psicóloga e empreendedora, Isabella fundou a MentalCare após identificar a lacuna de acesso à saúde mental no Brasil.",
      },
      {
        name: "Gabriel Neves",
        role: "CTO",
        equityPercentage: 27,
        bio: "Engenheiro de software com experiência em plataformas de saúde e LGPD.",
      },
    ],
    externalMembers: [
      { name: "Dra. Renata Dias", role: "Conselheira Clínica", organization: "CFP" },
      { name: "Marcus Andrade", role: "Conselheiro", organization: "Mescla" },
    ],
    demoVideos: ["https://www.youtube.com/watch?v=demo8"],
    pitchDeckUrl: "https://www.slideshare.net/demo8",
    coverImageUrl: "https://example.com/cover8.jpg",
    tags: ["saúde mental", "healthtech", "psicologia"],
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
  };
}

export async function listStartupsItems(): Promise<StartupListItem[]> {
  const snapshot = await startupsCollection.limit(100).get();
  return snapshot.docs.map((doc) => toListItem(doc.id, doc.data() as StartupDocument));
}

export async function getStartupById(startupId: string): Promise<StartupDocument | undefined> {
  const startupSnapshot = await startupsCollection.doc(startupId).get();
  if (!startupSnapshot.exists) return undefined;
  return startupSnapshot.data() as StartupDocument;
}

export async function seedDemoStartups(): Promise<string[]> {
  const batch = db.batch();

  demoStartups.forEach((startup) => {
    const {id, ...data} = startup;
    const startupRef = startupsCollection.doc(id);
    batch.set(
      startupRef,
      { ...data, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
  });

  await batch.commit();
  return demoStartups.map((s) => s.id);
}

export async function createQuestion(
  startupId: string,
  question: StartupQuestionDocument
): Promise<string> {
  const questionRef = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .add(question);
  return questionRef.id;
}

export async function userIsInvestor(startupId: string, uid: string): Promise<boolean> {
  const investorSnapshot = await startupsCollection
    .doc(startupId)
    .collection("investors")
    .doc(uid)
    .get();
  return investorSnapshot.exists;
}

export async function listPublicQuestions(startupId: string) {
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "publica")
    .limit(50)
    .get();

  return questionsSnapshot.docs
    .map((doc) => ({
      id: doc.id,
      text: doc.get("text"),
      answer: doc.get("answer") ?? null,
      answeredAt: doc.get("answeredAt")?.toDate?.()?.toISOString?.() ?? null,
      createdAt: doc.get("createdAt")?.toDate?.()?.toISOString?.() ?? null,
    }))
    .sort((left, right) =>
      String(right.createdAt ?? "").localeCompare(String(left.createdAt ?? ""))
    );
}