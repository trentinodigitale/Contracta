USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COMMISSIONE_PDA_STORICO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[COMMISSIONE_PDA_STORICO]
AS
select 	
	c1.id,
	c1.id as STORICOGrid_ID_DOC,
	c1.protocollo,
	c1.data,
	c1.Idpfu,
	'COMMISSIONE_PDA' as STORICOGrid_OPEN_DOC_NAME,
	c2.id as LinkModified,
	c1.Idpfu as APS_IdPfu
from ctl_doc C1 inner join ctl_doc c2 on c1.linkeddoc=c2.linkeddoc
where C1.tipodoc ='commissione_pda' and C2.tipodoc ='commissione_pda' and c1.statofunzionale in ('Annullato','Pubblicato') and c2.statofunzionale in ('Annullato','Pubblicato','InLavorazione')
GO
