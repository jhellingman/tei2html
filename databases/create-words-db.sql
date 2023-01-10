
CREATE DATABASE `words` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

-- words.book definition

CREATE TABLE `book` (
  `idbook` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(768) DEFAULT NULL,
  `author` varchar(768) DEFAULT NULL,
  `file` varchar(128) DEFAULT NULL,
  `changeDate` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`idbook`),
  KEY `title` (`title`),
  KEY `author` (`author`)
) ENGINE=InnoDB AUTO_INCREMENT=69749 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- words.word definition

CREATE TABLE `word` (
  `idword` int(11) NOT NULL AUTO_INCREMENT,
  `idbook` int(11) DEFAULT NULL,
  `word` varchar(128) DEFAULT NULL,
  `canonical` varchar(128) DEFAULT NULL,
  `language` varchar(32) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`idword`),
  KEY `word` (`word`,`language`),
  KEY `idbook` (`idbook`),
  CONSTRAINT `idbook` FOREIGN KEY (`idbook`) REFERENCES `book` (`idbook`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10153301 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- words.title definition

CREATE TABLE `title` (
  `idbook` int(11) NOT NULL,
  `language` varchar(100) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `nfc` int(11) DEFAULT 0,
  `title` varchar(512) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- words.person definition

CREATE TABLE `person` (
  `idbook` int(11) DEFAULT NULL,
  `key` varchar(512) DEFAULT NULL,
  `name` varchar(512) DEFAULT NULL,
  `viaf` varchar(100) DEFAULT NULL,
  `role` varchar(100) DEFAULT NULL,
  `dates` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- words.keyword definition

CREATE TABLE `keyword` (
  `idbook` int(11) DEFAULT NULL,
  `keyword` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

