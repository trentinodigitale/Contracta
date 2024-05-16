USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PARAMETRI_SDA_PAR_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_PARAMETRI_SDA_PAR_FROM_USER]
as

select 
 idpfu as ID_FROM
 , DataInizio, DataFine, NumAnniApertura, NumGiorniValutazione, NumGiorniPresentazioneDomande, 
 PresenzaBustaTecnica, PeriodoValiditaAmmissione, SollecitoRinnovo, NotificaRettificaSDA, NotificaRettificaSemplificato,
  NumeroMancateRisposte, SospensionePropostaRevoca, SospensioneAmmissioneSDA,InvitiSemplificatoCoerenti,NumGiorniDomandaPartecipazione,Obbligo_valutazione_istanze

from profiliutente
inner join Document_Parametri_SDA on  deleted = 0


GO
