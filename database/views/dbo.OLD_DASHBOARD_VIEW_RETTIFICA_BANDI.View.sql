USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_RETTIFICA_BANDI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_DASHBOARD_VIEW_RETTIFICA_BANDI] as 

	select 
		C.id,
		C.Titolo,
		C.DataInvio,
		C.StatoFunzionale,
		C.Idpfu,
		C.Protocollo,
		C2.Protocollo as ProtocolloBando,
		C2.Fascicolo,
		case when C.StatoFunzionale in ('InApprove') then 'RETTIFICA_BANDO_IN_APPROVE' else c.TipoDoc end  as OPEN_DOC_NAME,
		C.jumpcheck,
		C.idPfuInCharge,
		DR.idPfu as owner
		,isnull(C2.jumpcheck,'') as JumpCheckBando
	from CTL_DOC C
	inner join CTL_DOC C2 on C2.id=C.LinkedDoc
	inner join Document_Bando_Riferimenti  DR on DR.idheader=C2.id
	
	where C.tipodoc='RETTIFICA_BANDO' and C.Deleted=0

union

	select 
		C.id,
		C.Titolo,
		C.DataInvio,
		C.StatoFunzionale,
		C.Idpfu,
		C.Protocollo,
		C2.Protocollo as ProtocolloBando,
		C2.Fascicolo,
		case when C.StatoFunzionale in ('InApprove') then 'RETTIFICA_BANDO_IN_APPROVE' else c.TipoDoc end  as OPEN_DOC_NAME,
		C.jumpcheck,
		C.idPfuInCharge,
		DC.idPfu as owner
		,isnull(C2.jumpcheck,'') as JumpCheckBando
	from CTL_DOC C
	inner join CTL_DOC C2 on C2.id=C.LinkedDoc
	inner join Document_Bando_Commissione  DC on DC.idheader=C2.id and DC.RuoloCommissione='15550'
	where C.tipodoc='RETTIFICA_BANDO' and C.Deleted=0



GO
