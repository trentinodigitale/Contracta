USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_3]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[REPORT_3] 
AS

SELECT a.Descrizione
     , a.TipoGara 
     , CASE WHEN a.Importo = 0 OR a.Importo IS NULL THEN 999
	    WHEN b.Importo = 0 OR b.Importo IS NULL THEN -999
            ELSE ((b.Importo / b.Tot_Importo) - (a.Importo / a.Tot_Importo)) -- - 1
       END AS Importo

     , CASE WHEN a.N_Bandi = 0 OR a.N_Bandi IS NULL THEN 999
            WHEN b.N_Bandi = 0 OR b.N_Bandi IS NULL THEN -999
            ELSE ((CAST(b.N_Bandi AS FLOAT) / CAST(b.Tot_Bandi AS FLOAT)) - (CAST(a.N_Bandi AS FLOAT) / CAST(a.Tot_Bandi AS FLOAT))) -- - 1
       END AS N_Bandi

  FROM (
         SELECT a.Descrizione
              , TipoGara
              , SUM(Importo)     AS Importo  
              , SUM(N_Bandi)     AS N_Bandi
              , MAX(Tot_Importo) AS Tot_Importo
              , MAX(Tot_Bandi)   AS Tot_Bandi
	   FROM (
                  SELECT Descrizione
                       , TipoGara
                       , d.Importo 
                       , N_Bandi
                    FROM REPORT_2_Dati AS d
                       , Document_Report_Periodi 
                   WHERE TipoAnalisi = 'REPORT_3' 
                     AND Used = 1 
                     AND deleted = 0
		     AND CONVERT(CHAR(10), DataI, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF, 121)
                ) AS a
              ,
                (
                  SELECT Descrizione  AS Tot_Descr
                       , SUM(Importo) AS Tot_Importo  
                       , SUM(N_Bandi) AS Tot_Bandi
	          FROM (
                          SELECT Descrizione
                               , TipoGara
                               , d.Importo 
                               , N_Bandi
                            FROM REPORT_2_Dati AS d
                               , Document_Report_Periodi 
                           WHERE TipoAnalisi = 'REPORT_3' 
                             AND Used = 1 
                             AND deleted = 0
        		     AND CONVERT(CHAR(10), DataI, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF, 121)
                        ) AS c
                GROUP BY Descrizione
               )  AS Tot_a
           WHERE a.Descrizione = Tot_a.Tot_Descr
          GROUP BY Descrizione, TipoGara
	) AS a

LEFT OUTER JOIN 
        
        (
          SELECT a.Descrizione
               , TipoGara
               , SUM(Importo)     AS Importo  
               , SUM(N_Bandi)     AS N_Bandi
               , MAX(Tot_Importo) AS Tot_Importo
               , MAX(Tot_Bandi)   AS Tot_Bandi
	    FROM (
                   SELECT Descrizione
                        , TipoGara
                        , d.Importo 
                        , N_Bandi
                     FROM REPORT_2_dati AS d
                        , Document_Report_Periodi 
                    WHERE TipoAnalisi = 'REPORT_3' 
                      AND Used = 1 
                      AND deleted = 0
                      AND CONVERT(CHAR(10), DataI2, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF2, 121)
                  ) AS a
                ,
                 (
                   SELECT Descrizione   AS Tot_Descr
                        , SUM(Importo)  AS Tot_Importo  
                        , SUM(N_Bandi)  AS Tot_Bandi 
 	            FROM (
                            SELECT Descrizione
                                 , TipoGara
                                 , d.Importo 
                                 , N_Bandi
                              FROM REPORT_2_dati AS d
                                 , Document_Report_Periodi 
                             WHERE TipoAnalisi = 'REPORT_3' 
                               AND Used = 1 
                               AND deleted = 0
                               AND CONVERT(CHAR(10), DataI2, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF2, 121)
                           ) AS a
                     GROUP BY Descrizione  
 
                 ) AS Tot_b 
             WHERE Tot_b.Tot_Descr = a.Descrizione
                  
            GROUP BY Descrizione, TipoGara

	 ) AS b  ON a.Descrizione = b.Descrizione AND a.TipoGara = b.TipoGara


UNION 

SELECT b.Descrizione
     , b.TipoGara  
     , CASE WHEN a.Importo = 0 OR a.Importo IS NULL THEN 999
	    WHEN b.Importo = 0 OR b.Importo IS NULL THEN -999
            ELSE ((b.Importo / b.Tot_Importo) - (a.Importo / a.Tot_Importo)) -- - 1
       END AS Importo

     , CASE WHEN a.N_Bandi = 0 OR a.N_Bandi IS NULL THEN 999
            WHEN b.N_Bandi = 0 OR b.N_Bandi IS NULL THEN -999
            ELSE ((CAST(b.N_Bandi AS FLOAT) / CAST(b.Tot_Bandi AS FLOAT)) - (CAST(a.N_Bandi AS FLOAT) / CAST(a.Tot_Bandi AS FLOAT))) -- - 1
       END AS N_Bandi
  FROM (
         SELECT a.Descrizione
              , TipoGara
              , SUM(Importo)     AS Importo  
              , SUM(N_Bandi)     AS N_Bandi
              , MAX(Tot_Importo) AS Tot_Importo
              , MAX(Tot_Bandi)   AS Tot_Bandi
	   FROM (
                  SELECT Descrizione
                       , TipoGara
                       , d.Importo 
                       , N_Bandi
                    FROM REPORT_2_Dati AS d
                       , Document_Report_Periodi 
                   WHERE TipoAnalisi = 'REPORT_3' 
                     AND Used = 1 
                     AND deleted = 0
		     AND CONVERT(CHAR(10), DataI, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF, 121)
                ) AS a
              ,
                (
                  SELECT Descrizione  AS Tot_Descr
                       , SUM(Importo) AS Tot_Importo  
                       , SUM(N_Bandi) AS Tot_Bandi
	          FROM (
                          SELECT Descrizione
                               , TipoGara
                               , d.Importo 
                               , N_Bandi
                            FROM REPORT_2_Dati AS d
                               , Document_Report_Periodi 
                           WHERE TipoAnalisi = 'REPORT_3' 
                             AND Used = 1 
                             AND deleted = 0
        		     AND CONVERT(CHAR(10), DataI, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF, 121)
                        ) AS c
                GROUP BY Descrizione
               )  AS Tot_a
           WHERE a.Descrizione = Tot_a.Tot_Descr
          GROUP BY Descrizione, TipoGara
	) AS a

RIGHT OUTER JOIN 
		
        (
          SELECT a.Descrizione
               , TipoGara
               , SUM(Importo)     AS Importo  
               , SUM(N_Bandi)     AS N_Bandi
               , MAX(Tot_Importo) AS Tot_Importo
               , MAX(Tot_Bandi)   AS Tot_Bandi
	    FROM (
                   SELECT Descrizione
                        , TipoGara
                        , d.Importo 
                        , N_Bandi
                     FROM REPORT_2_dati AS d
                        , Document_Report_Periodi 
                    WHERE TipoAnalisi = 'REPORT_3' 
                      AND Used = 1 
                      AND deleted = 0
                      AND CONVERT(CHAR(10), DataI2, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF2, 121)
                  ) AS a
                ,
                 (
                   SELECT Descrizione   AS Tot_Descr
                        , SUM(Importo)  AS Tot_Importo  
                        , SUM(N_Bandi)  AS Tot_Bandi 
 	            FROM (
                            SELECT Descrizione
                                 , TipoGara
                                 , d.Importo 
                                 , N_Bandi
                              FROM REPORT_2_dati AS d
                                 , Document_Report_Periodi 
                             WHERE TipoAnalisi = 'REPORT_3' 
                               AND Used = 1 
                               AND deleted = 0
                               AND CONVERT(CHAR(10), DataI2, 121) <= Periodo AND Periodo <= CONVERT(CHAR(10), DataF2, 121)
                           ) AS a
                     GROUP BY Descrizione  
 
                 ) AS Tot_b 
             WHERE Tot_b.Tot_Descr = a.Descrizione
                  
            GROUP BY Descrizione, TipoGara

	 ) AS b  ON a.Descrizione = b.Descrizione AND a.TipoGara = b.TipoGara


GO
