class Socio {
  final String nome;
  final String cargo;
  final int percentual;
  final String descricao;
  final String avatar;

  const Socio({
    required this.nome,
    required this.cargo,
    required this.percentual,
    required this.descricao,
    required this.avatar,
  });
}

class Mentor {
  final String nome;
  final String cargo;
  final String avatar;

  const Mentor({
    required this.nome,
    required this.cargo,
    required this.avatar,
  });
}

class Pergunta {
  final String id;
  final String pergunta;
  final String resposta;
  final int likes;
  final int comments;

  const Pergunta({
    required this.id,
    required this.pergunta,
    required this.resposta,
    required this.likes,
    required this.comments,
  });
}

class SecaoGeral {
  final String titulo;
  final String conteudo;

  const SecaoGeral({required this.titulo, required this.conteudo});
}

class MaterialAnexo {
  final String titulo;
  final String tipo;
  final String tamanho;

  const MaterialAnexo({
    required this.titulo,
    required this.tipo,
    required this.tamanho,
  });
}

class Startup {
  final String id;
  final String nome;
  final String setor;
  final String codigo;
  final String status;
  final String descricaoBreve;
  final String logoAsset;
  final String capitalAportado;
  final int tokensEmitidos;
  final String previsaoReceita;
  final String cpv;
  final String margemBrutaAlvo;
  final String tokenPrice;
  final double tokenPriceValue;
  final String variacao;
  final bool variacaoPositiva;
  final List<Socio> socios;
  final List<Mentor> mentores;
  final List<Pergunta> perguntas;
  final List<SecaoGeral> geral;
  final List<MaterialAnexo> materiais;

  const Startup({
    required this.id,
    required this.nome,
    required this.setor,
    required this.codigo,
    required this.status,
    required this.descricaoBreve,
    required this.logoAsset,
    required this.capitalAportado,
    required this.tokensEmitidos,
    required this.previsaoReceita,
    required this.cpv,
    required this.margemBrutaAlvo,
    required this.tokenPrice,
    required this.tokenPriceValue,
    required this.variacao,
    required this.variacaoPositiva,
    required this.socios,
    required this.mentores,
    required this.perguntas,
    required this.geral,
    required this.materiais,
  });
}