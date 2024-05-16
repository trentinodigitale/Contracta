USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_INVITI_ROTAZIONE2_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[REPORT_INVITI_ROTAZIONE2_VIEW] AS
select 
		DI.*,
		DI.idAzi as Azienda ,
		[DataConferma] as Data,
		CD.NumRiga
	from DOCUMENT_BANDO_INVITI_LAVORI DI with(nolock)
		inner join CTL_DOC_DESTINATARI CD with(nolock) on CD.idrow=DI.idHeader
	where ISNULL(DI.idHeader,0) > 0
GO
