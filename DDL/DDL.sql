USE `unibus`;

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------
-- Table `unibus`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario` (
    `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único do usuário',
    `email` VARCHAR(150) NOT NULL COMMENT 'E-mail de login, deve ser único',
    `nome` VARCHAR(100) NOT NULL COMMENT 'Nome completo do usuário',
    `senha` VARCHAR(255) NOT NULL COMMENT 'Hash bcrypt da senha',
    `notificacoes_ativas` TINYINT NOT NULL DEFAULT 1 COMMENT '1 = ativas, 0 = desativadas',
    `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de cadastro',

    CONSTRAINT `pk_usuario` PRIMARY KEY (`id_usuario`),
    CONSTRAINT `uq_usuario_email` UNIQUE (`email`)
);

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------
-- Table `unibus`.`linha`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `linha` (
    `id_linha` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da linha',
    `numero_linha` VARCHAR(10) NOT NULL COMMENT 'Número da linha ex: 474, 485',
    `nome_linha` VARCHAR(100) NOT NULL COMMENT 'Nome descritivo da linha',
    `origem` VARCHAR(100) NOT NULL COMMENT 'Bairro/local de origem',
    `destino` VARCHAR(100) NOT NULL COMMENT 'Bairro/local de destino',

    CONSTRAINT `pk_linha` PRIMARY KEY (`id_linha`),
    CONSTRAINT `uq_linha_numero` UNIQUE (`numero_linha`)
);

-- -----------------------------------------------------
-- Table `unibus`.`avaliacao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `avaliacao` (
    `id_avaliacao` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da avaliação',
    `id_usuario` INT UNSIGNED NOT NULL COMMENT 'Usuário que realizou a avaliação',
    `id_linha` INT UNSIGNED NOT NULL COMMENT 'Linha avaliada',
    `nota` TINYINT NOT NULL COMMENT 'Nota de 1 a 5',
    `comentario` VARCHAR(500) NULL COMMENT 'Comentário opcional do usuário',
    `num_denuncias` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Qtd de denúncias recebidas - RN08',
    `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora da avaliação - controle RN03',

    CONSTRAINT `pk_avaliacao` PRIMARY KEY (`id_avaliacao`),
    CONSTRAINT `fk_aval_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_aval_linha` FOREIGN KEY (`id_linha`) REFERENCES `linha` (`id_linha`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_aval_nota` CHECK (`nota` BETWEEN 1 AND 5)
);

-- -----------------------------------------------------
-- Table `unibus`.`favorito`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `favorito` (
    `id_usuario` INT UNSIGNED NOT NULL COMMENT 'Usuário que favoritou',
    `id_linha` INT UNSIGNED NOT NULL COMMENT 'Linha favoritada',
    `data_marcacao` DATE NOT NULL DEFAULT (CURRENT_DATE) COMMENT 'Data em que a linha foi favoritada',

    CONSTRAINT `pk_favorito` PRIMARY KEY (`id_usuario`, `id_linha`),
    CONSTRAINT `fk_fav_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_fav_linha` FOREIGN KEY (`id_linha`) REFERENCES `linha` (`id_linha`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- Table `unibus`.`ocorrencia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocorrencia` (
    `id_ocorrencia` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da ocorrência',
    `id_usuario` INT UNSIGNED NOT NULL COMMENT 'Usuário que registrou a ocorrência',
    `id_linha` INT UNSIGNED NOT NULL COMMENT 'Linha relacionada à ocorrência',
    `tipo` ENUM('SUPERLOTACAO', 'ATRASO', 'ACIDENTE', 'INTERRUPCAO') NOT NULL COMMENT 'Tipo da ocorrência - ENUM de acordo com RF05',
    `descricao` VARCHAR(500) NULL COMMENT 'Descrição opcional da ocorrência',
    `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do registro - controle RN02 e RN10',

    CONSTRAINT `pk_ocorrencia` PRIMARY KEY (`id_ocorrencia`),
    CONSTRAINT `fk_ocor_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_ocor_linha` FOREIGN KEY (`id_linha`) REFERENCES `linha` (`id_linha`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------
-- Table `unibus`.`notificacao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `notificacao` (
    `id_notificacao` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da notificação',
    `id_usuario` INT UNSIGNED NOT NULL COMMENT 'Usuário que recebe a notificação',
    `id_ocorrencia` INT UNSIGNED NOT NULL COMMENT 'Ocorrência que gerou a notificação',
    `mensagem` VARCHAR(300) NOT NULL COMMENT 'Texto da notificação exibido ao usuário',
    `lida` TINYINT NOT NULL DEFAULT 0 COMMENT '0 = não lida, 1 = lida',
    `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora do envio - controle RN07',

    CONSTRAINT `pk_notificacao` PRIMARY KEY (`id_notificacao`),
    CONSTRAINT `fk_noti_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_noti_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_noti_lida` CHECK (`lida` IN (0, 1))
);

-- -----------------------------------------------------
-- Table `unibus`.`rota`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `rota` (
    `id_rota` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da rota',
    `id_usuario` NOT NULL COMMENT 'Usuário que criou ou referencia a rota',
    `origem` VARCHAR(100) NOT NULL COMMENT 'Bairro/local de origem',
    `destino` VARCHAR(100) NOT NULL COMMENT 'Bairro/local de destino - sempre UNIRIO',
    `descricao` VARCHAR(500) NULL COMMENT 'Dicas e recomendações práticas da rota',
    `popularidade` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Quantidade de likes recebidos - RN09',
    `tipo_rota` ENUM('mais_rapida', 'mais_segura', 'menos_lotada', 'recomendada') NOT NULL COMMENT 'Classificação da rota - RF07',
    `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação da rota',

    CONSTRAINT `pk_rota` PRIMARY KEY (`id_rota`),
    CONSTRAINT `fk_rota_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_rota_pop` CHECK (`popularidade` >= 0)
);
