USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AZI_UPD_DATIANAG_FROM_AZIENDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_AZI_UPD_DATIANAG_FROM_AZIENDA]
AS
--Versione=2&data=2014-09-01&Attivita=61998&Nominativo=Sabato

SELECT IdAzi AS ID_FROM
     , IdAzi
     , aziDataCreazione
     , aziRagioneSociale
     , aziPartitaIVA
     , aziIdDscFormaSoc
     , aziE_Mail
     , aziIndirizzoLeg
     , aziLocalitaLeg
     , aziProvinciaLeg
     , aziStatoLeg
     , aziCAPLeg
     , aziTelefono1
     , aziTelefono2
     , aziFAX
     , aziSitoWeb
     , d1.vatValore_FT AS CodiceFiscale
     , d2.vatValore_FT AS TIPO_AMM_ER
     , TipoDiAmministr
	 , d3.vatValore_FT  as PARTICIPANTID
	 ,case when ISNULL(d4.vatValore_FT ,'')='' then '' else ' PARTICIPANTID ' end as NotEditable
 FROM Aziende
	LEFT outer JOIN DM_Attributi d1 ON IdAzi = d1.Lnk AND d1.IdApp = 1 AND d1.dztNome = 'codicefiscale'
	LEFT outer JOIN DM_Attributi d2 ON IdAzi = d2.Lnk AND d2.IdApp = 1 AND d2.dztNome = 'TIPO_AMM_ER'
	left outer join dbo.DM_Attributi d3 on d3.lnk = idazi and d3.idApp = 1 and d3.dztNome = 'PARTICIPANTID'
	left outer join dbo.DM_Attributi d4 on d4.lnk = idazi and d4.idApp = 1 and d4.dztNome = 'IDNOTIER'

GO
