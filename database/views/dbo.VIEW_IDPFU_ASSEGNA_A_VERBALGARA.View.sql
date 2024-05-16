USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_IDPFU_ASSEGNA_A_VERBALGARA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_IDPFU_ASSEGNA_A_VERBALGARA] as
--riferimenti (Inviti) del bando
	select
		   DR.idPfu as idPfu,
		  C.id
	from
	ctl_doc C with(nolock) 
		inner join CTL_DOC c2 with(nolock) on c2.id=C.LinkedDoc	and c2.TipoDoc='PDA_MICROLOTTI'		
		inner join Document_Bando_Riferimenti  DR   with(nolock) on C2.LinkedDoc=DR.idHeader and DR.RuoloRiferimenti='Bando'		
	where C.tipodoc in ( 'VERBALEGARA')  and C.Deleted=0
union
--gli utenti utili sono i membri della commissione
	select
		  DCU.UtenteCommissione as idPfu,
		  C.id
	from
	ctl_doc C with(nolock) 
		inner join CTL_DOC c2 with(nolock) on c2.id=C.LinkedDoc	and c2.TipoDoc='PDA_MICROLOTTI'		
		inner join ctl_doc COM  with(nolock) on com.LinkedDoc=c2.LinkedDoc and COM.TipoDoc='COMMISSIONE_PDA' and COM.Deleted=0 and COM.StatoFunzionale='Pubblicato'
		inner join Document_CommissionePda_Utenti DCU with(nolock) on DCU.IdHeader=COM.id		
	where C.tipodoc in ( 'VERBALEGARA')  and C.Deleted=0
GO
