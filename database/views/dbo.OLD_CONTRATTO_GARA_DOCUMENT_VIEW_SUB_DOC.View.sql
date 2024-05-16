USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONTRATTO_GARA_DOCUMENT_VIEW_SUB_DOC]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_CONTRATTO_GARA_DOCUMENT_VIEW_SUB_DOC]
AS
select * from 
(
    select idheader, value, dzt_name
    from ctl_doc_value  p with(nolock)
	where dse_id = 'DOCUMENT'
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in (DataBando, DataRiferimentoInizio,DataRisposta, DataScadenzaOfferta, ProtocolloOfferta  , FROM_INIZIATIVA )
    ) as PIV

GO
