USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_SDA_PAR_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_PARAMETRI_SDA_PAR_FROM_USER]
as

select 
 idpfu as ID_FROM
 , DataInizio, DataFine, NumAnniApertura, NumGiorniValutazione, NumGiorniPresentazioneDomande, 
 PresenzaBustaTecnica, PeriodoValiditaAmmissione, SollecitoRinnovo, NotificaRettificaSDA, NotificaRettificaSemplificato,
  NumeroMancateRisposte, SospensionePropostaRevoca, SospensioneAmmissioneSDA,InvitiSemplificatoCoerenti,NumGiorniDomandaPartecipazione,Obbligo_valutazione_istanze
  , Scelta_Classi_Libera
from profiliutente
inner join Document_Parametri_SDA PS on  deleted = 0
inner join Document_Parametri_Abilitazioni PA on PA.idheader = PS.idheader

GO
