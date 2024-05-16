USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_MODULO_PDF_DICHIARAZIONE_FORN_SUB]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_VIEW_MODULO_PDF_DICHIARAZIONE_FORN_SUB]
AS
select * from 
(
    select idheader, value, dzt_name
		from ctl_doc_value  p with(nolock)
		where dse_id = 'TESTATA' 
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in (aziPartitaIVA, aziStatoLeg,aziProvinciaLeg, aziLocalitaLeg, aziIdDscFormaSoc, aziRagioneSociale, CodiceEORI, OperazioniStraordinarie
		,DataVariazione, aziIndirizzoLeg,aziCAPLeg, aziLocalitaAmm, aziProvinciaAmm, AttoOperazioneStraordinaria, aziIndirizzoAmm, aziCAPAmm , DataDecorrenzaVariazioni
		,azie_mail
		 )
    ) as PIV



GO
