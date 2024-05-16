USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASBOARD_VIEW_PREVENTIVI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASBOARD_VIEW_PREVENTIVI] as
select 
	p.Id
	,p.IdPfu
	,p.TipoDoc
	,p.StatoDoc
	,p.Data
	,p.Protocollo
	,p.Titolo
	,p.StrutturaAziendale
	,p.DataInvio
	,DOC_Name
	,c.ID as Convenzione
	,p.StatoFunzionale
from CTL_DOC p
	left outer join Document_Convenzione c on c.ID = p.LinkedDoc
 where TipoDoc = 'PREVENTIVO' and p.deleted = 0


GO
