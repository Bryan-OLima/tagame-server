# tagame-server

Aplicação completa do TAGAME hospedada no CasaOS.

## Responsabilidades

- Disponibilizar o painel web de administração.
- Disponibilizar uma API autenticada para celulares leitores e agentes.
- Gerenciar usuários, aparelhos, tags, jogos, computadores, associações, sessões e registros de auditoria.
- Executar as migrações e persistir os dados.
- Utilizar SQLite com modo WAL na implantação inicial no CasaOS.
- Distribuir os eventos de início e encerramento dos jogos.
- Fornecer a configuração de implantação para CasaOS e Docker.

## Estrutura planejada

```text
tagame-server/
├── frontend/
├── backend/
├── migrations/
├── tests/
├── deploy/
└── README.md
```

## Especificação do projeto

As especificações oficiais do produto e do banco de dados são mantidas no repositório separado `tagame-docs`, especialmente em `docs/ARCHITECTURE.md`, `docs/DB.md` e `docs/RULES.md`.

O banco de dados inicial será o SQLite. A ferramenta específica usada para gerar e executar as migrações ainda será escolhida.

## Estado de desenvolvimento

O repositório está atualmente em planejamento e ainda não possui uma implementação de produção.
