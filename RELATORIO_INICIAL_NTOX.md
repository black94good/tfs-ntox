# Relatorio inicial do projeto NTOX

Data: 2026-04-27
Base analisada: `C:\Users\freds\Desktop\ntox codex`
Direcao do projeto: OT Naruto usando servidor baseado em TFS 1.4.2 / protocolo 10.98 com OTC Mehah.

## 1. Objetivo do projeto

Criar um OT de Naruto com base TFS 1.4.2, usando uma estrutura simples e expansivel:

- uma unica vocation: `Shinobi`;
- clans como identidade principal do personagem;
- jutsus conquistados por missoes, quests e itens especiais;
- OTC Mehah como cliente principal;
- foco inicial em tres clans: Uchiha, Senju e Uzumaki.

## 2. Decisoes principais ja definidas

### 2.1 Vocation

O servidor tera apenas uma vocation jogavel:

- `Shinobi`

Todos os jogadores serao Shinobi. As diferencas de personagem virao de clan, elemento, jutsus, itens especiais e progresso de quest.

### 2.2 Clans iniciais

| Clan | Funcao | Ideia principal |
| --- | --- | --- |
| Uchiha | DPS | Dano alto, Sharingan, genjutsu e jutsus ofensivos |
| Senju | Support | Cura, buffs, controle de campo e suporte em grupo |
| Uzumaki | Tank | Vida alta, resistencia, selamentos e protecao |

### 2.3 Progressao de jutsus

Os jutsus nao devem ser ganhos automaticamente por level. O jogador deve conquistar jutsus por:

- missoes;
- quests;
- itens especiais;
- escolhas dentro do clan.

Essa decisao deixa a progressao mais parecida com uma jornada ninja e da mais valor ao conteudo do jogo.

## 3. Prioridade maxima: deixar a base consistente

Antes de criar muito conteudo novo, precisamos deixar servidor, banco, datapack e cliente conversando sem erro.

### 3.1 Corrigir banco do sistema elemental

A source ja usa o campo `element` no player, mas o `schema.sql` nao parece ter essa coluna na tabela `players`.

Tarefas:

- adicionar `element` no `schema.sql`;
- criar migration para bancos existentes;
- testar se player salva e carrega o elemento corretamente.

Motivo: sem isso, banco novo pode quebrar quando o servidor tentar carregar ou salvar player.

### 3.2 Trocar vocations padrao por Shinobi

O arquivo `data/XML/vocations.xml` ainda esta com vocations padrao de Tibia:

- Sorcerer;
- Druid;
- Paladin;
- Knight;
- evolucoes dessas vocations.

Tarefas:

- deixar apenas `None` e `Shinobi`;
- garantir que players antigos sejam convertidos para vocation 1;
- revisar samples/personagens de teste no banco.

Motivo: a base do projeto agora e clan, nao vocation.

### 3.3 Corrigir grupos de spells Naruto

O log mostra warnings:

- `Unknown group: fuuton`;
- `Unknown group: katon`.

Tarefas:

- decidir se `katon`, `suiton`, `doton`, `raiton`, `fuuton` serao grupos reais na source;
- ou manter `group="attack"` e controlar elemento por script/atributo separado.

Recomendacao inicial: manter `group="attack"` por enquanto e tratar elemento pelo sistema elemental. Depois, se precisar, criamos grupos proprios.

### 3.4 Confirmar OTC Mehah

Existe `otclient-main.rar`, mas ainda precisa ser confirmado.

Tarefas:

- extrair o cliente;
- confirmar se e OTC Mehah;
- verificar protocolo 10.98;
- configurar IP local;
- testar login no servidor;
- localizar onde criar modulos customizados.

Motivo: o cliente vai ser parte central do projeto, principalmente para HUD de clan, elemento, chakra e Sharingan.

## 4. Prioridade alta: sistema de clans

Depois da base consistente, o primeiro sistema de gameplay deve ser clan.

### 4.1 Como salvar clan

Opcoes:

- storage no player;
- campo proprio no banco.

Recomendacao inicial: comecar com storage, porque e mais rapido e seguro para prototipo.

Storages sugeridas:

| Storage | Uso |
| --- | --- |
| 51000 | Clan do jogador |
| 51001 | Caminho de Sharingan escolhido |
| 51002 | Estado de desbloqueio do Sharingan |

Antes de usar definitivo, verificar se essa faixa nao conflita com quests existentes.

### 4.2 Regras dos clans

- Uchiha: foco em DPS e Sharingan.
- Senju: foco em suporte, cura e controle.
- Uzumaki: foco em tank, selamentos e chakra forte.

Cada clan deve ter:

- bonus passivo simples;
- lista de jutsus possiveis;
- quests proprias;
- papel claro em grupo.

## 5. Prioridade alta: sistema especial Uchiha

O clan Uchiha tera progressao especial de Sharingan.

### 5.1 Fluxo do Sharingan

1. Player pertence ao clan Uchiha.
2. Faz uma missao inicial do clan.
3. Recebe um item especial ligado ao Sharingan.
4. Usa esse item como chave para acessar quests do Sharingan.
5. Faz uma quest de escolha.
6. Escolhe um caminho: Sasuke, Madara, Obito ou Itachi.
7. Desbloqueia jutsus especificos desse caminho por missoes futuras.

### 5.2 Caminhos de Sharingan

| Caminho | Estilo | Poderes planejados |
| --- | --- | --- |
| Sasuke | DPS explosivo | Chidori, Amaterasu, Susanoo ofensivo |
| Madara | DPS em area | Katon massivo, Susanoo, pressao de batalha |
| Obito | Controle e mobilidade | Kamui, intangibilidade, controle espacial |
| Itachi | Genjutsu e controle | Tsukuyomi, Amaterasu, Susanoo defensivo |

## 6. Prioridade media: jutsus iniciais

Criar poucos jutsus bons primeiro, em vez de muitos jutsus incompletos.

Primeiro pacote sugerido:

- Uchiha: Katon basico e primeiro jutsu de Sharingan;
- Senju: cura ou buff de suporte;
- Uzumaki: defesa, vida extra ou selamento simples;
- jutsu neutro para todo Shinobi.

Regras:

- jutsu deve ter missao ou condicao de liberacao;
- nao liberar tudo por level;
- manter custo em chakra/mana;
- testar cooldown e dano desde o inicio.

## 7. Prioridade media: mapa e conteudo jogavel

O `config.lua` ja aponta para o mapa `konoha`.

Tarefas:

- confirmar se `konoha.otbm` abre sem erro;
- revisar spawn e house XML;
- criar area inicial simples;
- criar NPC de escolha/entrada de clan;
- criar primeira missao Uchiha;
- criar area de teste de combate.

## 8. Prioridade baixa: limpeza de conteudo Tibia

A base ainda tem muitos arquivos padrao de Tibia. Isso nao precisa ser limpo tudo agora.

Limpar aos poucos:

- monsters padrao;
- NPCs padrao;
- quests padrao;
- spells padrao;
- items que nao combinam com Naruto.

Regra: remover apenas quando houver substituto ou quando atrapalhar o teste.

## 9. Ordem recomendada de trabalho

1. Corrigir banco/source do `element`.
2. Trocar vocations para `Shinobi`.
3. Corrigir warnings de spells `katon` e `fuuton`.
4. Extrair e testar OTC Mehah.
5. Criar sistema simples de clan por storage.
6. Criar comando ou NPC de teste para definir clan.
7. Criar item base do Sharingan.
8. Criar primeira missao Uchiha.
9. Criar os primeiros jutsus por clan.
10. Integrar informacoes de clan/Sharingan no OTC.

## 10. Recomendacao atual

O projeto deve continuar nessa base. Ela ja tem pontos importantes para Naruto: mapa Konoha, sistema elemental na source, sinais de jutsus e suporte a OTC.

A prioridade agora e parar de espalhar ideias soltas e transformar a base em um nucleo limpo: `Shinobi`, clans, elemento, jutsus por quest e OTC funcionando. Depois disso, o conteudo cresce com menos risco.
