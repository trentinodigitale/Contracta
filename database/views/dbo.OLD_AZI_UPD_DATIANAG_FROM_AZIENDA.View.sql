USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AZI_UPD_DATIANAG_FROM_AZIENDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_AZI_UPD_DATIANAG_FROM_AZIENDA]
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
		
		 , d5.vatValore_FT as Attiva_OCP
		 , d6.vatValore_FT as DataAttivazioneOCP

		 , case when dzt.id is null then 0 else 1 end as OCP_Modulo_Attivo

	 FROM Aziende with(nolock)
		LEFT outer JOIN DM_Attributi d1 with(nolock) ON IdAzi = d1.Lnk AND d1.IdApp = 1 AND d1.dztNome = 'codicefiscale'
		LEFT outer JOIN DM_Attributi d2 with(nolock) ON IdAzi = d2.Lnk AND d2.IdApp = 1 AND d2.dztNome = 'TIPO_AMM_ER'
		left outer join dbo.DM_Attributi d3 with(nolock) on d3.lnk = idazi and d3.idApp = 1 and d3.dztNome = 'PARTICIPANTID'
		left outer join dbo.DM_Attributi d4 with(nolock) on d4.lnk = idazi and d4.idApp = 1 and d4.dztNome = 'IDNOTIER'
		left outer join dbo.DM_Attributi d5 with(nolock) on d5.lnk = idazi and d5.idApp = 1 and d5.dztNome = 'Attiva_OCP'
		left outer join dbo.DM_Attributi d6 with(nolock) on d6.lnk = idazi and d6.idApp = 1 and d6.dztNome = 'DataAttivazioneOCP'
		left join LIB_Dictionary dzt with(nolock) on dzt.DZT_Name = 'SYS_MODULI_RESULT' and SUBSTRING(dzt.dzt_valuedef, 424,1) = '1'

GO
