USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_IDPFU_ASSEGNA_A_COMMISSIONE_PDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_IDPFU_ASSEGNA_A_COMMISSIONE_PDA] as
--idpfu compilatore del bando
	select
		  C2.idPfu,
		  C.id
	from
	ctl_doc C
		inner join CTL_DOC c2 on c2.id=C.LinkedDoc				
	where C.tipodoc in ( 'COMMISSIONE_PDA')  and C.Deleted=0
union
--user rup
	select
		  CV.Value as idPfu,
		  C.id
	from
	ctl_doc C
	inner join CTL_DOC c2 on c2.id=C.LinkedDoc
	inner join CTL_DOC_Value CV on CV.IdHeader=c2.id and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP'				
	where C.tipodoc in ( 'COMMISSIONE_PDA')  and C.Deleted=0
union
--Riferimenti bando/invito
	select
		  DR.idPfu as idPfu,
		  C.id
	from
	ctl_doc C
	inner join CTL_DOC c2 on c2.id=C.LinkedDoc	
	inner join Document_Bando_Riferimenti  DR on C2.id=DR.idHeader and DR.RuoloRiferimenti='Bando'		
	where C.tipodoc in ( 'COMMISSIONE_PDA')  and C.Deleted=0

GO
