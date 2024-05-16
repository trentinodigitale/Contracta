USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROROGA_GARA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_PROROGA_GARA] AS
	select 
		C.Id,
		C.idpfu,
		C.TipoDoc,
		C.StatoDoc,
		C.Protocollo,
		C.Deleted,
		C.Titolo,
		C.DataInvio,
		C.JumpCheck,
		C.StatoFunzionale,
		ISNULL(T.CIG,D.CIG) as CIG,
		ISNULL(T.ProtocolloBando,D.ProtocolloBando) as ProtocolloBando,
		ISNULL(T.Object_Cover1,C.Body ) as Oggetto
	from ctl_doc C
		left join tab_messaggi_fields T on C.LinkedDoc=T.idmsg and C.jumpcheck like '%55;%'
		left join Document_Bando D on C.LinkedDoc=D.IdHeader and C.jumpcheck='BANDO_GARA'
	where C.tipodoc='PROROGA_GARA'

GO
