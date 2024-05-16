USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_PUBBLICITA_LEGALE_HISTORY]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_PUBBLICITA_LEGALE_HISTORY]  AS

--DOCUMENTO DOVE SONO COMPILATORE
select 
		C.id,
		C.idpfu,
		C.Titolo,
		cast ( C.body as nvarchar(max)) as body,
		C.StatoFunzionale,
		C.DataInvio,
		C.Protocollo,
		idpfu as owner,
		Tipologia,
		cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
		cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
		Protocol,
		Pratica
		--data as APS_Date
		--,TipoAppaltoGara
		--,ProtocolloBando
	from ctl_doc C  with(nolock)	
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
		--inner join Document_Bando with(nolock) on idHeader=id	
		LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
	where C.TipoDoc='PUBBLICITA_LEGALE' and C.Deleted=0

UNION
--DOCUMENTO DOVE HO IN CHARGE IL DOCUMENTO
select 
		C.id,
		C.idpfu,
		C.Titolo,
		cast ( C.body as nvarchar(max)) as body,
		C.StatoFunzionale,
		C.DataInvio,
		C.Protocollo,
		idPfuInCharge as owner,
		Tipologia,
		cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
		cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
		Protocol,
		Pratica
		--data as APS_Date
		--,TipoAppaltoGara
		--,ProtocolloBando
	from ctl_doc C  with(nolock)	
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
			--inner join Document_Bando with(nolock) on idHeader=id
			LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader
	where C.TipoDoc='PUBBLICITA_LEGALE' and C.Deleted=0
UNION 
--relativi alla ciclo di approvazione dove l'utente figura in uno dei passi 
select 
		C.id,
		C.idpfu,
		C.Titolo,
		cast ( C.body as nvarchar(max)) as body,
		C.StatoFunzionale,
		C.DataInvio,
		C.Protocollo,
		APS_IdPfu as owner,
		Tipologia,
		cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
		cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
		Protocol,
		Pratica
		--data as APS_Date
		--,TipoAppaltoGara
		--,ProtocolloBando
	from ctl_doc C  with(nolock)	
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
			--inner join Document_Bando with(nolock) on idHeader=id
			inner join CTL_ApprovalSteps CA with(nolock) on CA.APS_ID_DOC=C.Id and CA.APS_Doc_Type=C.TipoDoc and CA.APS_IdPfu <> ''
			LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader

	where C.TipoDoc='PUBBLICITA_LEGALE' and C.Deleted=0

UNION
--Nella cartella "Di competenza" aggiungiamo la visibilità ai RUP PROPONENTI 
select 
		C.id,
		C.idpfu,
		C.Titolo,
		cast ( C.body as nvarchar(max)) as body,
		C.StatoFunzionale,
		C.DataInvio,
		C.Protocollo,
		v2.value as owner,
		Tipologia,
		cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
		cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK,
		Protocol,
		Pratica
		--data as APS_Date
		--,TipoAppaltoGara
		--,ProtocolloBando
	from ctl_doc C  with(nolock)	
		left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=c.id
		left outer join CTL_DOC_Value v2 with (nolock) on c.Id = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'CRITERI_ECO' --'InfoTec_comune'
		LEFT JOIN Document_RicPrevPubblic With(nolock) ON C.ID=Document_RicPrevPubblic.idheader

			--inner join Document_Bando with(nolock) on idHeader=id
	where C.TipoDoc='PUBBLICITA_LEGALE' and C.Deleted=0


GO
