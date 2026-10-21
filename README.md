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

O banco de dados inicial será o SQLite. O Prisma é a camada de acesso tipada e a ferramenta inicial para gerar e executar as migrações.

## Estado de desenvolvimento

O repositório possui a fundação inicial do backend; os fluxos de autenticação, leitores NFC, administração e agentes serão adicionados nas tarefas correspondentes.

## Backend

O backend fica em `backend/` e utiliza Express, TypeScript, Prisma e SQLite. Neste estágio, ele expõe somente os endpoints de fundação aprovados:

- `GET /health` — confirma que a aplicação está viva, sem consultar o banco.
- `GET /ready` — confirma que a aplicação consegue consultar o banco SQLite configurado.

### Configuração local

Use Node.js 22 LTS; a versão validada está registrada em `backend/.node-version`.

1. Entre em `backend/`.
2. Copie `.env.example` para `.env` e ajuste o banco, host, porta ou timeout. Não envie `.env` ao repositório.
3. Instale as dependências com `npm ci`.
4. Gere o cliente Prisma com `npm run prisma:generate`.
5. Inicie o serviço de desenvolvimento com `npm run dev`. Esse comando aplica as migrações pendentes antes de iniciar a API.

O comando de migração configura internamente o nível de log necessário pelo Prisma Migrate para SQLite. Isso contorna um defeito conhecido do Prisma sem depender de sintaxe específica de Windows ou Linux.

O arquivo `.env` local define o banco e a interface de rede. Para outro local de banco, defina `DATABASE_URL` com uma URL SQLite válida, por exemplo `file:./dados/tagame.db`.

### Verificação

Execute, dentro de `backend/`:

```text
npm run prisma:generate
npm run build
npm run lint
npm test
```

Com o banco migrado e o serviço em execução, `GET /health` deve retornar `200` mesmo que o banco fique indisponível. `GET /ready` retorna `200` apenas quando o banco pode ser usado com segurança; caso contrário, retorna `503` sem revelar detalhes internos.

### Recuperação de banco

Migrações são incrementais e não possuem rollback automático. Antes de qualquer atualização ou recuperação:

1. Pare a API para evitar novas gravações.
2. Faça uma cópia consistente de `tagame.db`, `tagame.db-wal` e `tagame.db-shm`, se os dois últimos existirem.
3. Preserve a cópia em volume local separado antes de executar `npm run migrate:deploy`.
4. Se uma migração falhar, mantenha os arquivos de diagnóstico, restaure o conjunto copiado para o mesmo local e só então reinicie a API.

Não edite manualmente a tabela `_prisma_migrations` para forçar o estado de uma migração. A correção deve ser uma nova migração versionada ou uma restauração validada do backup.
