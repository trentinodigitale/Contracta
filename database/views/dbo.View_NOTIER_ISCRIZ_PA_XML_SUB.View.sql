USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_NOTIER_ISCRIZ_PA_XML_SUB]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[View_NOTIER_ISCRIZ_PA_XML_SUB]
AS
select * from 
(
    select idheader, row idrow, value, dzt_name
    from ctl_doc_value p with(nolock)
	where ( (dse_id = 'IPA') )
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in ([CodiceIPA], [DenominazioneIPA],[IndirizzoIPA], [TelefonoIPA], [pecIPA], [ReferenteIPA], [EmailReferenteIPA], [Peppol_Invio_DDT] ,[Peppol_Invio_Ordine],[Peppol_Ricezione_DDT],[Peppol_Ricezione_Ordine] ,[Peppol_Invio_Fatture],[Peppol_Invio_NoteDiCredito] )
    ) as PIV


GO
