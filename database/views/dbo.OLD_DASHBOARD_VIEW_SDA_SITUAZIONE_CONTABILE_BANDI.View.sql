USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_SDA_SITUAZIONE_CONTABILE_BANDI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_DASHBOARD_VIEW_SDA_SITUAZIONE_CONTABILE_BANDI] as

select b.id , Protocollo,titolo,body, sda.importoBando,b.StatoFunzionale,b.DataInvio,b.DataScadenza
		, NumSemp , s.ImportoBaseAsta
		, case when isnull( sda.importoBando , 0 ) = 0 then 0 else isnull( s.ImportoBaseAsta / sda.importoBando , 0 ) end as PercUso
		, case when isnull( sda.importoBando , 0 ) = 0 then 0 else isnull( p.ValoreEconomico / sda.importoBando , 0 ) end as PercAgg 
		, p.ValoreEconomico
		, RUP.idPfu
		, P1.idpfu as Owner
	from ctl_doc b with(nolock)
		inner join profiliutente P1 with (nolock) on P1.pfuIdAzi = b.azienda
		inner join document_bando sda with(nolock) on sda.idheader = b.id
		left join Document_Bando_Commissione RUP with(nolock) on sda.idHeader=RUP.idHeader and RUP.RuoloCommissione='15550'
		left outer join ( select linkedDoc , count(*) as NumSemp , sum(ImportoBaseAsta) as ImportoBaseAsta from ctl_doc with(nolock)  inner join document_bando with(nolock) on id = idheader where deleted=0 and StatoDoc = 'sended' and tipodoc = 'BANDO_SEMPLIFICATO' group by Linkeddoc ) as s on b.id = s.LinkedDoc 
		left outer join (

							select b.LinkedDoc , sum( ValoreEconomico ) as ValoreEconomico --, *
								from  CTL_DOC p with(nolock)
									inner join CTL_DOC b with(nolock) on b.id = p.LinkedDoc
									inner join Document_MicroLotti_Dettagli m with(nolock) on p.id = m.idheader and m.TipoDoc='PDA_MICROLOTTI' 
																			and m.StatoRiga in ( 'AggiudicazioneProvv' ,'AggiudicazioneDef','AggiudicazioneCond')  and m.Voce = 0 and p.deleted = 0
									where p.deleted = 0 and p.TipoDoc = 'PDA_MICROLOTTI' and p.JumpCheck = 'BANDO_SEMPLIFICATO'
								group by b.LinkedDoc 

								) as p on p.LinkedDoc = b.id
	where b.tipodoc = 'BANDO_SDA'
		and b.StatoDoc = 'sended'
		and b.deleted = 0
GO
