USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VALUTAZIONE_BUSTA_AMMINISTRATIVA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VALUTAZIONE_BUSTA_AMMINISTRATIVA_VIEW] as
select 
	C.*	,
	rup.value as user_edit_rup,
	cu.UtenteCommissione as user_edit_pres,
	offerta.Protocollo as ProtocolloOfferta,
	A.aziRagioneSociale
	from CTL_DOC C with(NOLOCK)
		inner join ctl_doc offerta  with(NOLOCK) on offerta.id=c.LinkedDoc
		inner join ctl_doc pda with(NOLOCK) on offerta.LinkedDoc=pda.LinkedDoc and pda.TipoDoc='PDA_MICROLOTTI' and pda.Deleted=0
		--inner join aziende A with(NOLOCK) on A.IdAzi=offerta.Azienda
		inner join Document_PDA_OFFERTE A with(NOLOCK) on A.IdHeader=pda.id and A.IdMsg=offerta.id
		left outer join ctl_doc_value rup with(NOLOCK) on pda.LinkedDoc = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
		left outer join ctl_doc COM with(nolock) on COM.linkeddoc=pda.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
		left outer join Document_CommissionePda_Utenti CU with(nolock) on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
	where c.TipoDoc='VALUTAZIONE_BUSTA_AMMINISTRATIVA'
GO
