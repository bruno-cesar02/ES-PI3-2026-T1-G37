/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 

export function normalizeString(value: unknown): string | undefined {
  if (typeof value !== "string") {
    return undefined;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}