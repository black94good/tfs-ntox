# Atualizacoes do Projeto NTOX

Este arquivo registra as mudancas feitas na base do servidor e na source durante o desenvolvimento do OT Naruto.

## 2026-04-30 - Elemento separado do group das spells

### Source C++

- Atualizado `src/spells.h`.
- A classe `Spell` agora tem um campo proprio `element`, separado do `group` principal.
- Atualizado `src/spells.cpp`.
- O XML das spells agora aceita `element="katon|raiton|doton|suiton|fuuton"`.
- O `group` voltou a ser usado apenas para categoria principal. Para os novos jutsus NTOX, o padrao sera `attack` ou `support`; `healing` e `special` continuam aceitos por compatibilidade da base TFS.
- A checagem para usar jutsu elemental agora olha o campo `element`, nao mais o `group` ou `secondarygroup`.
- Atualizado `src/player.cpp`.
- A checagem para aprender jutsu elemental agora tambem usa o campo `element`.

### Datapack

- Atualizado `data/spells/spells.xml`.
- Jutsus de teste que usavam `group="fuuton"` foram movidos para `group="attack" element="fuuton"`.
- `Katon Blast` foi movido para `group="attack" element="katon"`.
- `Fuuton Gust` agora declara `element="fuuton"`.

### Observacao

- Os grupos elementais antigos ainda existem no enum da source por compatibilidade, mas nao devem mais ser usados em novas spells.
- Daqui para frente, elemento deve ser configurado no atributo `element`.

### Arquivos importantes para Git nesta etapa

- `src/spells.h`
- `src/spells.cpp`
- `src/player.cpp`
- `data/spells/spells.xml`
- `README_ATUALIZACOES.md`

## 2026-04-27 - Vocation Shinobi e level maximo

### Base/datapack

- Atualizado `data/XML/vocations.xml`.
- Removidas as vocations padrao de Tibia como Sorcerer, Druid, Paladin, Knight e evolucoes.
- Mantidas apenas duas entradas:
  - `None` para estado neutro/inicial;
  - `Shinobi` como unica vocation jogavel.
- A vocation `Shinobi` ficou com atributos baixos para combinar com level maximo 300 e progressao media:
  - ganho de vida baixo por level;
  - ganho de chakra/mana baixo por level;
  - capacidade baixa por level;
  - attack speed controlado;
  - skills com multiplicadores moderados.

### Experiencia e progressao

- Atualizado `config.lua`.
- Adicionado limite de level:
  - `maxLevel = 300`
- Ajustados os stages de experiencia para ritmo medio:
  - level 1 a 20: multiplicador 8x;
  - level 21 a 50: multiplicador 6x;
  - level 51 a 100: multiplicador 4x;
  - level 101 a 150: multiplicador 3x;
  - level 151 a 220: multiplicador 2x;
  - level 221 a 300: multiplicador 1.5x.
- Ajustados rates base:
  - `rateExp = 3`;
  - `rateSkill = 2`;
  - `rateMagic = 2`.
- Atualizado `data/XML/stages.xml` para ficar coerente com a nova curva, mesmo estando desativado no momento.

### Source C++

- Atualizado `src/configmanager.h`.
- Adicionada nova configuracao numerica:
  - `MAX_LEVEL`.

- Atualizado `src/configmanager.cpp`.
- O servidor agora le `maxLevel` do `config.lua`.
- Valor padrao caso nao exista no config:
  - `300`.

- Atualizado `src/player.cpp`.
- Adicionada trava de level maximo no ganho de experiencia.
- Quando o jogador chega no level configurado em `maxLevel`, ele nao deve continuar passando de level.
- Ao atingir o limite, a experiencia e ajustada para o valor exato do level maximo e o percentual do level fica em 0.

- Atualizado `src/luascript.cpp`.
- Registrado `ConfigManager::MAX_LEVEL` para acesso via Lua, caso scripts precisem consultar essa configuracao no futuro.

### Banco/migrations

- Criado `data/migrations/33.lua`.
- A migration converte jogadores antigos para vocation `1`, que agora representa `Shinobi`.

### Validacao feita

- `data/XML/vocations.xml` validado como XML.
- `data/XML/stages.xml` validado como XML.
- A compilacao C++ ainda nao foi validada porque `cmake` nao esta disponivel no terminal atual.

### Proximo passo recomendado

- Compilar a source para confirmar que a nova configuracao `MAX_LEVEL` esta correta.
- Depois, corrigir o campo `element` no banco/source, que ja aparece como uma pendencia importante no relatorio inicial.

## 2026-04-27 - SQL ntotfs atualizado para Shinobi

### Dump completo

- Atualizado `ntotfs.sql`.
- A coluna `players.vocation` agora nasce com default `1`, que representa `Shinobi`.
- Os personagens existentes no dump foram convertidos para vocation `1`.
- Samples antigos foram renomeados para nomes genericos de Shinobi:
  - `Sorcerer Sample` -> `Shinobi Sample 1`;
  - `Druid Sample` -> `Shinobi Sample 2`;
  - `Paladin Sample` -> `Shinobi Sample 3`;
  - `Knight Sample` -> `Shinobi Sample 4`.
- `server_config.db_version` atualizado de `32` para `33`.

### SQL incremental

- Criado `sql/33_ntox_shinobi_vocation.sql`.
- Este arquivo serve para atualizar um banco `ntotfs` ja existente sem precisar importar o dump completo.
- Ele faz:
  - altera default de `players.vocation` para `1`;
  - converte players antigos para vocation `1`;
  - renomeia samples antigos;
  - atualiza `server_config.db_version` para `33`.

### Arquivos importantes para Git nesta etapa

- `config.lua`
- `data/XML/vocations.xml`
- `data/XML/stages.xml`
- `data/migrations/33.lua`
- `src/configmanager.h`
- `src/configmanager.cpp`
- `src/player.cpp`
- `src/luascript.cpp`
- `ntotfs.sql`
- `sql/33_ntox_shinobi_vocation.sql`
- `README_ATUALIZACOES.md`
- `RELATORIO_INICIAL_NTOX.md`



