USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONTRATTI_DOCUMENTI_FORNITORI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_CONTRATTI_DOCUMENTI_FORNITORI] 
AS
SELECT 
	C.*
	, a.Idpfu as DOC_OWNER
	,C.tipodoc as OPEN_DOC_NAME
	,DC.Titolo as Name 
	from ctl_doc C
		inner join  ProfiliUtente a on pfuidazi = destinatario_azi
		inner join ctl_doc DC on DC.id=C.linkeddoc
where C.tipodoc in ('CONTRATTO_PROROGA','CONTRATTO_ESTENSIONE')
	and C.statofunzionale='Confermato'

GO
