USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_CAL_SEDUTE_LOTTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

---------------------------------------------------------------
--3) modificata la vista per ritornare i record in funzione dell'utente collegato
---------------------------------------------------------------

CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_CAL_SEDUTE_LOTTI] AS
-- documenti validi per tutti gli utenti
select a.*  , idpfu from 
(
		SELECT LEFT(CONVERT(VARCHAR, DataSeduta, 121), 7) AS  MeseCalendar 
			 , 'SCHEDA_PROGETTO' AS OPEN_DOC_NAME 
			 , - a.IdRow  AS id
			 , ReferenteUffAppalti AS Referente 
			 , ProtocolloBando AS Protocollo
			 , NumeroSeduta  
			 , DataSeduta AS Data 
			 , SUBSTRING(CONVERT(VARCHAR, DataSeduta, 121), 12, 5 ) + '-' +  ProtocolloBando + '-' + NumeroSeduta + '-' + DescrizioneSeduta + '-' +  LEFT(ReferenteUffAppalti, 9) AS Descrizione
		  FROM DASHBOARD_VIEW_PROSPETTO_APPALTI a
		 INNER JOIN Document_lotti_Sedute  b ON a.IdRow = b.IdRow

		UNION

		SELECT LEFT(CONVERT(VARCHAR, Data, 121), 7) AS  MeseCalendar  
			 , 'EVENTO.800.300' AS OPEN_DOC_NAME
			 , id
			 , Referente
			 , Protocollo
			 , ''
			 , Data
			 , SUBSTRING(CONVERT(VARCHAR, Data, 121), 12, 5 ) + '-' + Protocollo + '-' + Descrizione + '-' + LEFT(Referente, 9) AS Descrizione
		  FROM Document_Notes 
		 WHERE Deleted = 0
) as a
	cross join profiliutente 


 UNION

-- documenti personali, creati dagli utenti
select 	a.* from 
(
		SELECT LEFT(CONVERT(VARCHAR, expirydate, 100), 7) AS MeseCalendar
			 , ''	 AS OPEN_DOC_NAME
			 , idMsg AS id
			 , '' AS Referente
			 , ProtocolloBando AS Protocollo
			 , '' as NumeroSeduta
			 , expirydate AS Data
			 , SUBSTRING(CONVERT(VARCHAR, expirydate, 121), 12, 5 ) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto AS Descrizione
			 , idpfu
		  FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
		    
		 UNION
		 
		SELECT CASE ISDATE(DataAperturaOfferte)
					WHEN 1 THEN LEFT(CONVERT(VARCHAR, DataAperturaOfferte, 100), 7)
					ELSE ''
			   END   AS MeseCalendar
			 , ''    AS OPEN_DOC_NAME
			 , idMsg AS id
			 , ''    AS Referente
			 , ProtocolloBando AS Protocollo
			 , ''
			 , CASE ISDATE(DataAperturaOfferte)
					WHEN 1 THEN DataAperturaOfferte 
					ELSE ''
			   END AS Data
			 , CASE ISDATE(DataAperturaOfferte)
					WHEN 1 THEN SUBSTRING(CONVERT(VARCHAR, DataAperturaOfferte, 121), 12, 5 ) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto
					ELSE ProtocolloBAndo + '-' + CIG + '-' + dscTesto
			   END AS Descrizione
			 , idpfu
		  FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
		   
		 UNION
		   
		SELECT CASE ISDATE(DataIISeduta)
					WHEN 1 THEN LEFT(CONVERT(VARCHAR, DataIISeduta, 100), 7) 
					ELSE ''
			   END AS MeseCalendar
			 , ''       AS OPEN_DOC_NAME
			 , idMsg    AS id
			 , ''       AS Referente
			 , ProtocolloBando AS Protocollo
			 , ''
			 , CASE ISDATE(DataIISeduta)
					WHEN 1 THEN DataIISeduta
					ELSE ''
			   END AS Data
			 , CASE ISDATE(DataIISeduta)
					WHEN 1 THEN SUBSTRING(CONVERT(VARCHAR, DataIISeduta, 121), 12, 5) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto
					ELSE ProtocolloBAndo + '-' + CIG + '-' + dscTesto
			   END AS Descrizione
			 , idpfu
		  FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
		    
		UNION

		SELECT LEFT(CONVERT(VARCHAR, DataAperturaDomande, 100), 7) AS MeseCalendar
			 , ''	 AS OPEN_DOC_NAME
			 , idMsg AS id
			 , ''    AS Referente
			 , ProtocolloBando AS Protocollo
			 , ''
			 , DataAperturaDomande AS Data
			 , SUBSTRING(CONVERT(VARCHAR, DataAperturaDomande, 121), 12, 5) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto AS Descrizione
			 , idpfu
		FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
) as a
 
 UNION

-- documenti visualizzati per appartenenza come ruolo al ciclo di approvazione
select 	a.* , u.idpfu from 
(
		SELECT LEFT(CONVERT(VARCHAR, expirydate, 100), 7) AS MeseCalendar
			 , ''	 AS OPEN_DOC_NAME
			 , idMsg AS id
			 , '' AS Referente
			 , ProtocolloBando AS Protocollo
			 , '' as NumeroSeduta
			 , expirydate AS Data
			 , SUBSTRING(CONVERT(VARCHAR, expirydate, 121), 12, 5 ) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto AS Descrizione
		  FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
		    
		 UNION
		 
		SELECT CASE ISDATE(DataAperturaOfferte)
					WHEN 1 THEN LEFT(CONVERT(VARCHAR, DataAperturaOfferte, 100), 7)
					ELSE ''
			   END   AS MeseCalendar
			 , ''    AS OPEN_DOC_NAME
			 , idMsg AS id
			 , ''    AS Referente
			 , ProtocolloBando AS Protocollo
			 , ''
			 , CASE ISDATE(DataAperturaOfferte)
					WHEN 1 THEN DataAperturaOfferte 
					ELSE ''
			   END AS Data
			 , CASE ISDATE(DataAperturaOfferte)
					WHEN 1 THEN SUBSTRING(CONVERT(VARCHAR, DataAperturaOfferte, 121), 12, 5 ) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto
					ELSE ProtocolloBAndo + '-' + CIG + '-' + dscTesto
			   END AS Descrizione
		  FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
		   
		 UNION
		   
		SELECT CASE ISDATE(DataIISeduta)
					WHEN 1 THEN LEFT(CONVERT(VARCHAR, DataIISeduta, 100), 7) 
					ELSE ''
			   END AS MeseCalendar
			 , ''       AS OPEN_DOC_NAME
			 , idMsg    AS id
			 , ''       AS Referente
			 , ProtocolloBando AS Protocollo
			 , ''
			 , CASE ISDATE(DataIISeduta)
					WHEN 1 THEN DataIISeduta
					ELSE ''
			   END AS Data
			 , CASE ISDATE(DataIISeduta)
					WHEN 1 THEN SUBSTRING(CONVERT(VARCHAR, DataIISeduta, 121), 12, 5) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto
					ELSE ProtocolloBAndo + '-' + CIG + '-' + dscTesto
			   END AS Descrizione
		  FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
		    
		UNION

		SELECT LEFT(CONVERT(VARCHAR, DataAperturaDomande, 100), 7) AS MeseCalendar
			 , ''	 AS OPEN_DOC_NAME
			 , idMsg AS id
			 , ''    AS Referente
			 , ProtocolloBando AS Protocollo
			 , ''
			 , DataAperturaDomande AS Data
			 , SUBSTRING(CONVERT(VARCHAR, DataAperturaDomande, 121), 12, 5) + '-' + ProtocolloBAndo + '-' + CIG + '-' + dscTesto AS Descrizione
		FROM DASHBOARD_VIEW_DOCUMENTI 
			 , DizionarioAttributi
			 , TipiDatiRange
			 , DescsI
		 WHERE msgIType = 55 
		   AND msgISubType = 167
		   AND dztIdTid = tdrIdTid
		   AND tdrCodice = FaseGara
		   AND tdrIdDsc = IdDsc
		   AND dztNome = 'FaseGara'
		   AND tdrDeleted = 0
) as a
inner join CTL_ApprovalSteps on  APS_Doc_Type = 'APPROVAZIONE' and  APS_ID_DOC = a.id
inner join profiliutenteattrib u on APS_UserProfile = attvalue and dztnome = 'UserRole'
GO
