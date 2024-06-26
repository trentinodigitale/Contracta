USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_FORNITORI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[COM_DPE_FORNITORI]
AS
SELECT IdAzi 
     , aziragionesociale 
     , aziPartitaIVA
     , DM_1.vatvalore_ft     AS codicefiscale
	 , DM_2.vatvalore_ft     AS CARBelongTo
	 , DM_3.vatValore_FT AS cancellatodiufficio
     --, c.vatvalore_ft     AS ClasseIscriz
     ,dbo.GetMultiValueAzi(Aziende.IdAzi, 'ClasseIscriz') AS ClasseIscriz
     , aziIndirizzoLeg + ' - ' + azilocalitaleg + ' - ' + aziStatoleg  AS Indirizzo
	
	 ,case when d5.idVat is null and not d4.idVat is null then '10' -- hanno un participant id ma non hanno un idnotier
		  when not d5.idVat is null then '11'-- hanno un idnotier 
		  when not d4.idVat is null then '1_'-- hanno un participant id 
		  when d4.idVat is null then '00' -- non hanno un participant id
     end as iscrittoPeppol
	 , d3.vatValore_FT  as PARTICIPANTID

  FROM Aziende with (nolock)
     --, MPAziende
     --, Profiliutente
     --, DM_Attributi a
     --, DM_Attributi c
 --IdAzi = mpaIdAzi
   --AND mpaIdMp = 1
   --AND pfuIdAzi = IdAzi
   --AND pfuDeleted = 0
   --a.idapp= 1 AND a.lnk = IdAzi AND a.dztNome = 'CARBelongTO'
			LEFT OUTER JOIN DM_Attributi AS DM_1 with (nolock) ON Aziende.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'codicefiscale' 
			LEFT OUTER JOIN DM_Attributi AS DM_2 with (nolock) ON Aziende.IdAzi = DM_2.lnk AND DM_2.idApp = 1 AND DM_2.dztNome = 'carbelongto'
			LEFT OUTER JOIN DM_Attributi AS DM_3 with (nolock) ON Aziende.IdAzi = DM_3.lnk AND DM_3.idApp = 1 AND DM_3.dztNome = 'cancellatodiufficio'
			--LEFT OUTER JOIN DM_Attributi AS DM_2 ON Aziende.IdAzi = DM_2.lnk AND DM_2.idApp = 1 AND DM_2.dztNome = 'ClasseIscriz'
			--AND c.idapp= 1 AND c.lnk = IdAzi AND c.dztNome = 'ClasseIscriz'
			--AND mpaDeleted = 0
			left outer join dbo.DM_Attributi d4 with(nolock) on d4.dztNome = 'PARTICIPANTID' and d4.idApp = 1 and d4.lnk = idazi and isnull(d4.vatValore_FT,'') <> ''
			left outer join dbo.DM_Attributi d5 with(nolock) on d5.dztNome = 'IDNOTIER' and d5.idApp = 1 and d5.lnk = idazi and isnull(d5.vatValore_FT,'') <> ''
			left outer join dbo.DM_Attributi d3 with(nolock) on d3.dztNome = 'PARTICIPANTID' and d3.idApp = 1 and d3.lnk = idazi and isnull(d3.vatValore_FT,'') <> ''
   WHERE 
		aziDeleted = 0 and azivenditore > 0       and aziacquirente = 0
		--ESCLUDO LE RTI
		and aziIdDscFormaSoc <> '845326' 

GO
