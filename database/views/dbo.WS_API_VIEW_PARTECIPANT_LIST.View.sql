USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WS_API_VIEW_PARTECIPANT_LIST]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[WS_API_VIEW_PARTECIPANT_LIST] AS
	select l.*
			--,az.aziLog as CodiceAzienda,
			--az.aziPartitaIVA as PartitaIVA
			--,case when l.isRTI = '1' then 'RTI' else z1.dscTesto end as FormaGiuridica
	from Gare_Elenco_Invitati_Partecipanti L
			--aggiungendo la inner join sulle aziende le prestazioni si degradavano molto, forse la colonna esposta idAzienda essendo una coalesce creava problemi negli accessi
			-- spostiamo quindi queste logiche di recupero nel codice del WS passando da una tabella temporanea
			--INNER JOIN aziende az WITH(NOLOCK) ON az.IdAzi = l.idAzienda
			---- forma giuridica
			--left join dizionarioattributi x1 with (nolock) on x1.dztNome = 'NAGI'
			--left outer join tipidatirange y1 with (nolock) on x1.dztIdTid = y1.tdrIdTid 
			--													and y1.tdrCodice = cast(az.aziIdDscFormaSoc as varchar)
			--left outer join descsi z1 with (nolock) on z1.IdDsc = y1.tdrIdDsc 
GO
