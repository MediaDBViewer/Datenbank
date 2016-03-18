--
-- Erstellungszeit: 02. Mrz 2016
-- Datenbank - Stuktur für `MediaDB`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Episoden`
--

CREATE TABLE IF NOT EXISTS `Episoden` (
  `episodenumber` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `source` varchar(10) DEFAULT NULL,
  `size` bigint(20) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `md5` varchar(32) DEFAULT NULL,
  `vcodec` varchar(15) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `totalbitrate` int(11) DEFAULT NULL,
  `acodecger` varchar(10) DEFAULT NULL,
  `abitrateger` int(11) DEFAULT NULL,
  `channelsger` tinyint(4) DEFAULT NULL,
  `acodeceng` varchar(10) DEFAULT NULL,
  `abitrateeng` int(11) DEFAULT NULL,
  `channelseng` tinyint(4) DEFAULT NULL,
  `hdd` tinyint(4) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `checked` tinyint(1) DEFAULT NULL,
  `views` int(11) DEFAULT NULL,
  `lastView` date DEFAULT NULL,
  `added` date DEFAULT NULL,
  `season_nr` int(11) NOT NULL DEFAULT '0',
  `series_nr` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`episodenumber`,`season_nr`,`series_nr`),
  KEY `season_nr` (`season_nr`),
  KEY `series_nr` (`series_nr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `Episoden`
--
DROP TRIGGER IF EXISTS `watchedEpisode`;
DELIMITER //
CREATE TRIGGER `watchedEpisode` BEFORE UPDATE ON `Episoden`
 FOR EACH ROW IF (NEW.views > OLD.views) THEN
  SET NEW.lastView = now();
END IF
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Filme`
--

CREATE TABLE IF NOT EXISTS `Filme` (
  `imdbID` char(7) NOT NULL DEFAULT '',
  `name` varchar(200) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `size` bigint(20) DEFAULT NULL,
  `md5` varchar(32) DEFAULT NULL,
  `3d` varchar(10) NOT NULL DEFAULT '',
  `vcodec` varchar(10) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `totalbitrate` int(11) DEFAULT NULL,
  `resolution` varchar(10) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `acodecger` varchar(10) DEFAULT NULL,
  `abitrateger` int(11) DEFAULT NULL,
  `channelsger` int(11) DEFAULT NULL,
  `acodeceng` varchar(10) DEFAULT NULL,
  `abitrateeng` int(11) DEFAULT NULL,
  `channelseng` int(11) DEFAULT NULL,
  `hdd` int(11) DEFAULT NULL,
  `rating` float(2,1) DEFAULT NULL,
  `summary` text NOT NULL,
  `youtube` varchar(14) NOT NULL,
  `fsk` int(11) NOT NULL,
  `checked` tinyint(1) DEFAULT NULL,
  `views` int(11) DEFAULT NULL,
  `comment` varchar(200) DEFAULT NULL,
  `added` date DEFAULT NULL,
  `lastView` date DEFAULT NULL,
  `lastUpdate` date DEFAULT NULL,
  PRIMARY KEY (`imdbID`,`3d`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `Filme`
--
DROP TRIGGER IF EXISTS `watchedMovie`;
DELIMITER //
CREATE TRIGGER `watchedMovie` BEFORE UPDATE ON `Filme`
 FOR EACH ROW IF (NEW.views > OLD.views) THEN
  SET NEW.lastView = now();
END IF
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `FilmGenre`
--

CREATE TABLE IF NOT EXISTS `FilmGenre` (
  `imdbID` char(7) DEFAULT NULL,
  `genreID` int(11) DEFAULT NULL,
  UNIQUE KEY `imdbID_2` (`imdbID`,`genreID`),
  KEY `imdbID` (`imdbID`),
  KEY `genreID` (`genreID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `FilmSchauspieler`
--

CREATE TABLE IF NOT EXISTS `FilmSchauspieler` (
  `imdbID` char(7) DEFAULT NULL,
  `schauspielerID` char(7) DEFAULT NULL,
  `role` char(255) DEFAULT NULL,
  KEY `imdbID` (`imdbID`),
  KEY `schauspielerID` (`schauspielerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Genre`
--

CREATE TABLE IF NOT EXISTS `Genre` (
  `genreID` int(11) NOT NULL AUTO_INCREMENT,
  `engname` varchar(255) DEFAULT NULL,
  `gername` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`genreID`),
  KEY `genreID` (`genreID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=24 ;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Schauspieler`
--

CREATE TABLE IF NOT EXISTS `Schauspieler` (
  `name` varchar(255) DEFAULT NULL,
  `schauspielerID` char(7) NOT NULL DEFAULT '',
  PRIMARY KEY (`schauspielerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Serien`
--

CREATE TABLE IF NOT EXISTS `Serien` (
  `name` varchar(255) DEFAULT NULL,
  `finished` tinyint(1) DEFAULT NULL,
  `series_nr` int(11) NOT NULL,
  PRIMARY KEY (`series_nr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Staffeln`
--

CREATE TABLE IF NOT EXISTS `Staffeln` (
  `season` tinyint(4) DEFAULT NULL,
  `resolution` varchar(10) DEFAULT NULL,
  `sound` varchar(5) DEFAULT NULL,
  `source` varchar(10) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `season_nr` int(11) NOT NULL,
  `series_nr` int(11) DEFAULT NULL,
  PRIMARY KEY (`season_nr`),
  KEY `series_nr` (`series_nr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `Episoden`
--
ALTER TABLE `Episoden`
  ADD CONSTRAINT `Episoden_ibfk_1` FOREIGN KEY (`season_nr`) REFERENCES `Staffeln` (`season_nr`),
  ADD CONSTRAINT `Episoden_ibfk_2` FOREIGN KEY (`series_nr`) REFERENCES `Serien` (`series_nr`);

--
-- Constraints der Tabelle `FilmGenre`
--
ALTER TABLE `FilmGenre`
  ADD CONSTRAINT `FilmGenre_ibfk_1` FOREIGN KEY (`imdbID`) REFERENCES `Filme` (`imdbID`),
  ADD CONSTRAINT `FilmGenre_ibfk_2` FOREIGN KEY (`genreID`) REFERENCES `Genre` (`genreID`);

--
-- Constraints der Tabelle `FilmSchauspieler`
--
ALTER TABLE `FilmSchauspieler`
  ADD CONSTRAINT `FilmSchauspieler_ibfk_1` FOREIGN KEY (`imdbID`) REFERENCES `Filme` (`imdbID`),
  ADD CONSTRAINT `FilmSchauspieler_ibfk_2` FOREIGN KEY (`schauspielerID`) REFERENCES `Schauspieler` (`schauspielerID`);

--
-- Constraints der Tabelle `Staffeln`
--
ALTER TABLE `Staffeln`
  ADD CONSTRAINT `Staffeln_ibfk_1` FOREIGN KEY (`series_nr`) REFERENCES `Serien` (`series_nr`);
