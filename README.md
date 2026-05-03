# 🚌 UNIBUS — Banco de Dados

Banco de dados relacional do sistema UNIBUS,
plataforma colaborativa de transporte público
universitário da UNIRIO.

## Tecnologias
- MySQL 8.0.34+
- InnoDB | utf8mb4 | utf8mb4_0900_ai_ci

## Tabelas
- `usuario` — cadastro de usuários
- `linha` — linhas de ônibus
- `avaliacao` — avaliações por linha
- `favorito` — linhas favoritadas
- `ocorrencia` — reportes de ocorrências
- `notificacao` — notificações do sistema
- `rota` — rotas recomendadas

## Como executar
1. Criar o schema: `CREATE SCHEMA unibus ...`
2. Executar: `ddl/DDL.sql`
3. Popular: `dml/unibus_inserts.sql` (futuramente
