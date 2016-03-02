--
-- Erstellungszeit: 02. Mrz 2016
-- Datenbank - Funktionen und Views für `MediaDB`
--

-- ---------------------------------------------------------------------

-- --------------------------------------------------------
-- Funktionen
-- --------------------------------------------------------

DROP FUNCTION IF EXISTS func_counter_inc;
	DELIMITER $$
	CREATE FUNCTION func_counter_inc() RETURNS int(11)
	BEGIN
	  DECLARE var INT;
	  SET @var = IFNULL( @var,0) + 1;
	  return @var;
	END;
	$$
	DELIMITER ;
DROP FUNCTION IF EXISTS func_counter;
	DELIMITER $$
	CREATE FUNCTION func_counter() RETURNS int(11)
	BEGIN
	  return @var;
	END;
	$$
	DELIMITER ;

--
-- Views
-- --------------------------------------------------------
-- Stuktur:
-- Erst alle Subviews
-- Danach der Hauptview bzw.
-- die Hauptviews
-- --------------------------------------------------------	

	-- --------------------------------------------------------	
	-- Subview: Filmstatistik 
	-- für watchStatistic	
	-- --------------------------------------------------------	
		CREATE OR REPLACE VIEW `FilmeStatistikSUB` AS	
			SELECT 
				year(`Filme`.`lastView`) AS `Jahr`,
				month(`Filme`.`lastView`) AS `Monat`,
				SUM(Filme.duration) AS LastViewDuration,
				SUM(0) 				AS AddedDuration,
				COUNT(Filme.imdbID) AS LastViewCount,
				SUM(0) 				AS AddedCount
			FROM Filme WHERE (Filme.lastView is not null) group by year(`Filme`.`lastView`),month(`Filme`.`lastView`)
			UNION SELECT 
				year(`Filme`.`added`) AS `Jahr`,
				month(`Filme`.`added`) AS `Monat`,
				SUM(0) AS LastViewDuration,
				SUM(Filme.duration) AS AddedDuration,
				SUM(0) 				AS LastViewCount,
				COUNT(Filme.imdbID)	AS AddedCount
			FROM Filme group by year(`Filme`.`added`),month(`Filme`.`added`);
		CREATE OR REPLACE VIEW `FilmeStatistik` AS
			SELECT dp.Jahr, dp.Monat, round(SUM(dp.LastViewDuration))	AS FilmeGesehenLaufzeit, SUM(dp.LastViewCount) AS FilmeGesehenCount
									, round(SUM(dp.AddedDuration))		AS FilmeaddedLaufzeit,   SUM(dp.AddedCount)    AS FilmeAddedCount,
					(100*SUM(dp.LastViewDuration))/SUM(dp.AddedDuration) AS FilmeGesehen
			FROM FilmeStatistikSUB AS dp
			GROUP BY dp.Jahr, dp.Monat ;

	-- --------------------------------------------------------	
	-- Subview: Serienstatistik 
	-- für watchStatistic	
	-- --------------------------------------------------------	
		CREATE OR REPLACE VIEW `SerienStatistikSUB` AS
			SELECT 
				year(`Episoden`.`lastView`) AS `Jahr`,
				month(`Episoden`.`lastView`) AS `Monat`,
				SUM(Episoden.duration) AS LastViewDuration,
				SUM(0) 				AS AddedDuration,
				COUNT(Episoden.size) AS LastViewCount,
				SUM(0) 				AS AddedCount
			FROM Episoden WHERE (Episoden.lastView is not null) group by year(`Episoden`.`lastView`),month(`Episoden`.`lastView`)
			UNION SELECT 
				year(`Episoden`.`added`) AS `Jahr`,
				month(`Episoden`.`added`) AS `Monat`,
				SUM(0) AS LastViewDuration,
				SUM(Episoden.duration) AS AddedDuration,
				SUM(0) 				AS LastViewCount,
				COUNT(Episoden.size)	AS AddedCount
			FROM Episoden group by year(`Episoden`.`added`),month(`Episoden`.`added`);
		CREATE OR REPLACE VIEW `SerienStatistik` AS
			SELECT dp.Jahr, dp.Monat, round(SUM(dp.LastViewDuration))	AS EpisodenGesehenLaufzeit, SUM(dp.LastViewCount) AS EpisodenGesehenCount
									, round(SUM(dp.AddedDuration))		AS EpisodenaddedLaufzeit,   SUM(dp.AddedCount)    AS EpisodenAddedCount,
					(100*SUM(dp.LastViewDuration))/SUM(dp.AddedDuration) AS EpisodenGesehen
			FROM SerienStatistikSUB AS dp
			GROUP BY dp.Jahr, dp.Monat ;

	-- --------------------------------------------------------	
	-- Subview: watchStatistic 
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `watchStatisticSUB` AS 	
			SELECT 
				s.Jahr AS Jahr,
				s.Monat AS Monat,
				s.FilmeGesehenLaufzeit AS FilmeGesehenLaufzeit,
				s.FilmeGesehenCount AS FilmeGesehenCount,
				s.FilmeaddedLaufzeit AS FilmeaddedLaufzeit,
				s.FilmeAddedCount AS FilmeAddedCount,
				s.FilmeGesehen AS FilmeGesehen,
				0 AS EpisodenGesehenLaufzeit,
				0 AS EpisodenGesehenCount,
				0 AS EpisodenaddedLaufzeit,
				0 AS EpisodenAddedCount,
				0 AS EpisodenGesehen
			FROM FilmeStatistik s
				UNION
			SELECT 
				s.Jahr AS Jahr,
				s.Monat AS Monat,
				0 AS FilmeGesehenLaufzeit,
				0 AS FilmeGesehenCount,
				0 AS FilmeaddedLaufzeit,
				0 AS FilmeAddedCount,
				0 AS FilmeGesehen,
				s.EpisodenGesehenLaufzeit AS EpisodenGesehenLaufzeit,
				s.EpisodenGesehenCount AS EpisodenGesehenCount,
				s.EpisodenaddedLaufzeit AS EpisodenaddedLaufzeit,
				s.EpisodenAddedCount AS EpisodenAddedCount,
				s.EpisodenGesehen AS EpisodenGesehen
			FROM SerienStatistik s;

	-- --------------------------------------------------------	
	-- Hauptview: Monatsstatistik
	-- watchStatistic 
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `watchStatistic` AS 	
			SELECT Jahr, Monat , sec_to_time(SUM(FilmeGesehenLaufzeit)) AS MoviesSeen, 
								 sec_to_time(SUM(FilmeaddedLaufzeit)) AS MoviesNew, 
								 SUM(FilmeGesehenCount) AS MoviesSeenC, 
								 SUM(FilmeAddedCount) AS MoviesNewC, 
								 concat(round(SUM(FilmeGesehen),2)," %") AS Movies,
								 sec_to_time(SUM(EpisodenGesehenLaufzeit)) AS SeriesSeen, 
								 sec_to_time(SUM(EpisodenaddedLaufzeit)) AS SeriesNew, 
								 SUM(EpisodenGesehenCount) AS SeriesSeenC, 
								 SUM(EpisodenAddedCount) AS SeriesNewC, 
								 concat(round(SUM(EpisodenGesehen),2)," %") AS Series,
								 sec_to_time(SUM(FilmeGesehenLaufzeit) + SUM(EpisodenGesehenLaufzeit)) AS TotalSeen,
								 sec_to_time(SUM(FilmeaddedLaufzeit) + SUM(EpisodenaddedLaufzeit)) AS TotalNew,
								 SUM(FilmeGesehenCount) + SUM(EpisodenGesehenCount) AS TotalSeenC,
								 SUM(FilmeAddedCount) + SUM(EpisodenAddedCount) AS TotalNewC,
								 concat(round((100*(SUM(FilmeGesehenLaufzeit) + SUM(EpisodenGesehenLaufzeit)))/(SUM(FilmeaddedLaufzeit) + SUM(EpisodenaddedLaufzeit)),2)," %") AS Total
			FROM watchStatisticSUB dp
			GROUP BY dp.Jahr, dp.Monat ;
			
	-- ##################################################

	-- --------------------------------------------------------		
	-- Subview: Belegter Speicher
	-- --------------------------------------------------------	
		CREATE OR REPLACE VIEW `belegterSpeicherRAW` AS
			SELECT (coalesce((SELECT sum(`size`) FROM `Filme` WHERE hdd =1),0)+coalesce((SELECT sum(`size`) FROM `Episoden` WHERE hdd =1),0)) AS `Media 1`,
				   (coalesce((SELECT sum(`size`) FROM `Filme` WHERE hdd =2),0)+coalesce((SELECT sum(`size`) FROM `Episoden` WHERE hdd =2),0)) AS `Media 2`,
				   (coalesce((SELECT sum(`size`) FROM `Filme` WHERE hdd =3),0)+coalesce((SELECT sum(`size`) FROM `Episoden` WHERE hdd =3),0)) AS `Media 3`,
				   (coalesce((SELECT sum(`size`) FROM `Filme` WHERE hdd =4),0)+coalesce((SELECT sum(`size`) FROM `Episoden` WHERE hdd =4),0)) AS `Media 4`,
				   (coalesce((SELECT sum(`size`) FROM `Filme` WHERE hdd =5),0)+coalesce((SELECT sum(`size`) FROM `Episoden` WHERE hdd =5),0)) AS `Media 5`,
				   (coalesce((SELECT sum(`size`) FROM `Filme`             ),0)+coalesce((SELECT sum(`size`) FROM `Episoden`             ),0)) AS `Total`;
			   
	-- --------------------------------------------------------			
	-- Hauptview: Belegter Speicher
	-- --------------------------------------------------------	
		CREATE OR REPLACE VIEW `belegterSpeicher` AS
			SELECT concat(format(((SELECT `Media 1` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 1`,
				   concat(format(((SELECT `Media 2` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 2`,
				   concat(format(((SELECT `Media 3` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 3`,
				   concat(format(((SELECT `Media 4` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 4`,
				   concat(format(((SELECT `Media 5` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 5`,
				   concat(format(((SELECT `Total`   FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Total`;
			   
	-- --------------------------------------------------------			   
	-- Hauptview: Freier Speicher 
	-- basierend auf belegterSpeicherRAW
	-- 
	-- --------------------------------------------------------	
		CREATE OR REPLACE VIEW `freierSpeicher` AS 
			SELECT concat(format((5329 - (SELECT `Media 1` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 1`,
				   concat(format((0    - (SELECT `Media 2` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 2`,
				   concat(format((0    - (SELECT `Media 3` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 3`,
				   concat(format((0    - (SELECT `Media 4` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 4`,
				   concat(format((0    - (SELECT `Media 5` FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Media 5`,
				   concat(format((5329 - (SELECT `Total`   FROM belegterSpeicherRAW)/pow(1024,3)),0, 'de_DE'),' GB') AS `Total`;

	-- ##################################################			   
	
	-- --------------------------------------------------------
	-- Hauptview: Laufzeit des gesehenen Materials
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `laufzeitGesehen` AS 
			SELECT concat(format((sum((`Filme`.`duration` * `Filme`.`views`)) / (3600)),2),' h') AS `Filme`,
			(SELECT concat(format((sum((`Episoden`.`duration` * `Episoden`.`views`)) / (3600)),2),' h') FROM `Episoden`) AS `Serien`,
			concat(format(((SELECT (sum((`Filme`.`duration` * `Filme`.`views`)) / (3600 ))) + (SELECT (sum((`Episoden`.`duration` * `Episoden`.`views`)) / (3600 )) FROM `Episoden`)),2),' h') AS `Total` 
			FROM `Filme`;

	-- ##################################################			   
	
	-- --------------------------------------------------------
	-- Hauptview: Prozentual gesehen
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `prozentualGesehen` AS 
			SELECT
				CASE func_counter_inc()
					WHEN 4 THEN "Prozent"
					WHEN 3 THEN "Gigabyte"
					WHEN 2 THEN "Stunden"
					WHEN 1 THEN "Anzahl"
				END AS `Beschreibung`,
				CASE func_counter()
					WHEN 4 THEN concat(format(((IFNULL((SELECT sum(`Filme`.`duration`   ) FROM `Filme` WHERE    (`Filme`.`views` > 0   )), 0) / IFNULL((SELECT sum(`Filme`.`duration`   ) FROM `Filme`   ), 0)) * 100),2),' %')
					WHEN 3 THEN concat(format((SELECT sum(`Filme`.`size`) FROM `Filme` WHERE (`Filme`.`views` > 0))/pow(1024,3), 2),' GB')
					WHEN 2 THEN concat(format((SELECT sum(`Filme`.`duration`) FROM `Filme` WHERE (`Filme`.`views` > 0))/3600, 2),' h')
					WHEN 1 THEN concat(IFNULL((SELECT COUNT(`Filme`.`duration`) FROM `Filme` WHERE (`Filme`.`views` > 0)),0),' st')
				END AS `Filme`,
				CASE func_counter()
					WHEN 4 THEN concat(format(((IFNULL((SELECT sum(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0) / IFNULL((SELECT sum(`Episoden`.`duration`) FROM `Episoden`), 0)) * 100),2),' %')
					WHEN 3 THEN concat(format(IFNULL((SELECT sum(`Episoden`.`size`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0)/pow(1024,3), 2),' GB')
					WHEN 2 THEN concat(format(IFNULL((SELECT sum(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0)/3600, 2),' h')
					WHEN 1 THEN concat(IFNULL((SELECT COUNT(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0),' st')
				END  AS `Serien`,
				CASE func_counter()
					WHEN 4 THEN concat(format((((IFNULL((SELECT sum(`Filme`.`duration`   ) FROM `Filme` WHERE    (`Filme`.`views` > 0   )), 0)+ IFNULL((SELECT sum(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0))/(IFNULL((SELECT sum(`Filme`.`duration`   ) FROM `Filme`   ), 0) + IFNULL((SELECT sum(`Episoden`.`duration`) FROM `Episoden`), 0))) * 100),2),' %')
					WHEN 3 THEN concat(format((IFNULL((SELECT sum(`Episoden`.`size`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0) + IFNULL((SELECT sum(`Filme`.`size`) FROM `Filme` WHERE (`Filme`.`views` > 0)), 0))/pow(1024,3), 2),' GB')
					WHEN 2 THEN concat(format((IFNULL((SELECT sum(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0) + IFNULL((SELECT sum(`Filme`.`duration`) FROM `Filme` WHERE (`Filme`.`views` > 0)), 0))/3600, 2),' h')
					WHEN 1 THEN concat((IFNULL((SELECT COUNT(`Filme`.`duration`) FROM `Filme` WHERE (`Filme`.`views` > 0)),0)+ IFNULL((SELECT COUNT(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`views` > 0)), 0)), ' st')
				END AS `Total`
			FROM Filme LIMIT 4;

	-- ##################################################			   
	
	-- --------------------------------------------------------
	-- Hauptview: Prozentual defekt
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `prozentualDefekt` AS 
			SELECT concat(format((((SELECT sum(`Filme`.`duration`) FROM `Filme` WHERE (`Filme`.`checked` = 0)) / (SELECT sum(`Filme`.`duration`) FROM `Filme`)) * 100),2),' %') AS `Filme`,
			concat(format((((SELECT sum(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`checked` = 0)) / (SELECT sum(`Episoden`.`duration`) FROM `Episoden`)) * 100),2),' %') AS `Serien`,
			concat(format(((((SELECT sum(`Filme`.`duration`) FROM `Filme` WHERE (`Filme`.`checked` = 0)) + (SELECT sum(`Episoden`.`duration`) FROM `Episoden` WHERE (`Episoden`.`checked` = 0))) / ((SELECT sum(`Filme`.`duration`) FROM `Filme`) + (SELECT sum(`Episoden`.`duration`) FROM `Episoden`))) * 100),2),' %') AS `Total`;

	-- ##################################################			   
	
	-- --------------------------------------------------------
	-- Hauptview: defekte Episoden
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `defekteEpisoden` AS 
			SELECT 
				`Serien`.`name` AS `Serie`,
				`Staffeln`.`season` AS `Staffel`,
				`Episoden`.`episodenumber` AS `Episode`,
				`Episoden`.`name` AS `Titel`,
				`Episoden`.`comment` AS `Kommentar` 
			FROM ((`Serien` join `Staffeln`) join `Episoden`) WHERE ((`Serien`.`series_nr` = `Episoden`.`series_nr`) and (`Staffeln`.`season_nr` = `Episoden`.`season_nr`) and (`Episoden`.`checked` = 0));

	-- ##################################################			   
	
	-- --------------------------------------------------------
	-- Hauptview: defekte Filme
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `defekteFilme` AS 
			SELECT `Filme`.`name` AS `name`,`Filme`.`comment` AS `comment` FROM `Filme` WHERE (`Filme`.`checked` = 0);
	
	-- ##################################################			   
	
	-- --------------------------------------------------------
	-- Hauptview: DBstatistik
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `DBstatistik` AS 
			SELECT
				(SELECT COUNT(*) FROM Filme) AS 'Anzahl Filme',
				(SELECT COUNT(*) FROM Filme WHERE youtube = "") AS 'Filme ohne Trailer',
				(SELECT COUNT(*) FROM Filme WHERE youtube LIKE "DE%") AS 'Filme mit DE Trailer',
				(SELECT COUNT(*) FROM Filme WHERE youtube LIKE "EN%") AS 'Filme mit EN Trailer',
				(SELECT COUNT(*) FROM Filme WHERE resolution = "1080p") AS 'Filme in 1080p',
				(SELECT COUNT(*) FROM Filme WHERE resolution = "720p") AS 'Filme in 720p',
				(SELECT COUNT(*) FROM Filme WHERE resolution = "SD") AS 'Filme in SD',
				(SELECT DATE_FORMAT(added, "%d.%m.%y") FROM Filme ORDER BY added DESC LIMIT 1) AS 'FilmeLastAdded',
				(SELECT COUNT(*) FROM Serien) AS SerienCount;
				
	-- --------------------------------------------------------
	-- Hauptview: GenreFilmanzahl
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `GenreFilmanzahl` AS 
			SELECT g.gername AS Genre, COUNT(imdbID) AS "Anzahl Filme" 
			FROM Genre  g JOIN FilmGenre fg ON g.genreID = fg.genreID 
			GROUP BY g.genreID 
			ORDER BY COUNT(imdbID) ASC;
	
	-- --------------------------------------------------------
	-- Hauptview: SchauspielerFilmanzahl
	-- --------------------------------------------------------
		CREATE OR REPLACE VIEW `SchauspielerFilmanzahl` AS 
			SELECT s.name AS Name, COUNT(imdbID) AS "Anzahl Filme" 
			FROM Schauspieler  s JOIN FilmSchauspieler fs ON s.schauspielerID = fs.schauspielerID 
			GROUP BY s.schauspielerID 
			HAVING COUNT(imdbID)>10
			ORDER BY COUNT(imdbID) ASC;
