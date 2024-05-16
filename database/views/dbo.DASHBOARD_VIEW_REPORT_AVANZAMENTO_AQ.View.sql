USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REPORT_AVANZAMENTO_AQ]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REPORT_AVANZAMENTO_AQ] AS

select 
	d.id,
	d.Protocollo,
	d.DataInvio,
	d.Body as Oggetto,	
	b.ImportoBaseAsta as ImportoBaseAsta,
	RILANCIO.Protocollo as protocolloriferimento,
	RILANCIO.Body as OggettoDet,
	b2.ImportoBaseAsta as ValoreImportoLotto,
	RILANCIO.StatoFunzionale,
	aziRagioneSociale
	
from ctl_doc as d with(nolock)
		inner join  document_bando b with(nolock) on d.id = b.idheader and b.TipoProceduraCaratteristica <> 'RDO' and b.TipoSceltaContraente='ACCORDOQUADRO'
		left join CTL_DOC RILANCIO with(nolock) on RILANCIO.LinkedDoc=d.id and RILANCIO.TipoDoc='BANDO_GARA' and RILANCIO.Deleted=0 and RILANCIO.StatoFunzionale <> 'InLavorazione'
		left join Document_Bando  b2 with(nolock) on b2.idHeader=RILANCIO.id
		left join Aziende A with(nolock) on A.IdAzi=RILANCIO.Azienda
	where d.TipoDoc in ( 'BANDO_GARA' ) and d.deleted=0 and d.StatoFunzionale <> 'InLavorazione'


GO
