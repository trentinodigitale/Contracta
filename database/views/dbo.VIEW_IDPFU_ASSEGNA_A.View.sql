USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_IDPFU_ASSEGNA_A]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_IDPFU_ASSEGNA_A] as

	select
	   DR.idPfu,
	   id
	from
	ctl_doc C
		inner join Document_Bando_Riferimenti  DR on DR.idheader=C.linkeddoc
	where C.tipodoc in ( 'REVOCA_BANDO','RETTIFICA_BANDO','PROROGA_BANDO')  and C.Deleted=0
 
 union

	 select
	   DC.idPfu,
	   id
	from
	ctl_doc C
		inner join Document_Bando_Commissione  DC on DC.idheader=C.linkeddoc and DC.RuoloCommissione='15550'
	where C.tipodoc in ( 'REVOCA_BANDO','RETTIFICA_BANDO','PROROGA_BANDO') and C.Deleted=0


GO
