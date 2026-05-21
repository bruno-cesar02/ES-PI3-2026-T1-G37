/* 
Name: Otávio Augusto Antunes Marquez
RA: 24025832
*/

export class WalletNotFoundError extends Error {
  constructor(message = "Carteira do usuário não encontrada.") {
    super(message);
    this.name = "WalletNotFoundError";
  }
}