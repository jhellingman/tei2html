SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `words` DEFAULT CHARACTER SET utf8 COLLATE default collation ;
USE `words`;

-- -----------------------------------------------------
-- Table `words`.`book`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `words`.`book` (
  `idbook` INT NOT NULL AUTO_INCREMENT ,
  `title` VARCHAR(128) NULL ,
  `author` VARCHAR(128) NULL ,
  `file` VARCHAR(128) NULL ,
  PRIMARY KEY (`idbook`) ,
  INDEX `title` (`title` ASC) ,
  INDEX `author` (`author` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `words`.`word`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `words`.`word` (
  `idword` INT NOT NULL AUTO_INCREMENT ,
  `idbook` INT NULL ,
  `word` VARCHAR(32) NULL ,
  `language` VARCHAR(8) NULL ,
  `count` INT NULL ,
  PRIMARY KEY (`idword`) ,
  INDEX `word` (`word` ASC, `language` ASC) ,
  INDEX `idbook` (`idbook` ASC) ,
  INDEX `idbook` (`idbook` ASC) ,
  CONSTRAINT `idbook`
    FOREIGN KEY (`idbook` )
    REFERENCES `words`.`book` (`idbook` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
