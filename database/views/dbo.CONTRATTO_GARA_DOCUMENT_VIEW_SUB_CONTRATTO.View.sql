USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONTRATTO_GARA_DOCUMENT_VIEW_SUB_CONTRATTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CONTRATTO_GARA_DOCUMENT_VIEW_SUB_CONTRATTO]
AS
select * from 
(
    select idheader,  value, dzt_name
    from ctl_doc_value  p with(nolock)
	where dse_id = 'CONTRATTO'
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in (CodiceIPA, firmatario,CF_FORNITORE, Firmatario_OE, DataRiferimento ,  PresenzaListino ,FascicoloSecondario , DataScadenza, IdPfu_Firmatario,DataStipula,DirettoreEsecuzioneContratto)
    ) as PIV

GO
