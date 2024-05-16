USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ANNULLA_ODA_EVASI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_ANNULLA_ODA_EVASI] as
select 
	C1.Id
		, o.idHeader
		, Id_Convenzione
		, IdAzi
		, pfuIdAzi 
		, c1.Destinatario_Azi as idAzi2
		, Destinatario_Azi
		, ImpegnoSpesa
		, IndirizzoRitiro
		, o.IVA     
		, a.pfuNome
		, a.pfuRuoloAziendale    
		, Titolo     
		, RDP_DataPrevCons
		, ReferenteConsegna
		, ReferenteEMail
		, ReferenteIndirizzo
		, ReferenteRitiro
		, ReferenteTelefono
		, RefOrd
		, RefOrdEMail
		, RefOrdInd
		, RefOrdTel
		, RitiroEMail
		, TelefonoRitiro
		, dbo.afs_round (TotalIva , 2) as TotalIva
		, Id_Convenzione AS Convenzione
		, o.TipoOrdine
		, NoMail
		, AllegatoConsegna 
		, 'ANNULLA_ODA' as OPEN_DOC_NAME
		, C1.SIGN_HASH
		, C1.SIGN_ATTACH
		, C1.SIGN_LOCK
		--, case 
		--	when R.utente = 'COMPILATORE' then isnull( attvalue,'') 
		--	else ''
		--	end
		--	as UserRole            --------------->
		, c1.IdPfu as Owner
		, StatoFunzionale
		--, C1.IdPfu
	 
		--, case 
		--	when R.utente = 'COMPILATORE' then isnull( SUB.Value , C1.IdPfu ) 
		--	else O.UserRup 
		--	end
		--	as IdPfu     --------------->

		, o.IdRow
		, o.UserRUP
		, isnull(O.NotEditable,'') as NotEditable
		, C1.azienda
		, Az.aziragionesociale	
		, ReferenteStato
		, ReferenteProvincia
		, ReferenteLocalita
		, ReferenteCap
		, ReferenteStato2
		, ReferenteProvincia2
		, ReferenteLocalita2
		, FatturazioneStato
		, FatturazioneProvincia
		, FatturazioneLocalita
		, FatturazioneCap
		, FattuarzioneStato2
		, FatturazioneLocalita2
		, FatturazioneProvincia2
		, idPfuInCharge
		, TipoDoc
		, DataInvio as Data
		, C1.Protocollo
		, IdDocIntegrato
		, O.Allegato
		, codiceIPA
		, TotaleEroso
		, TotalIvaEroso
		, TotalIvaEroso - TotaleEroso AS ValoreIva
		, case 
			when isnull(O.IdDocIntegrato,0) > 0 then 'si'
			else 'no'
			end as Multiplo	 
		, O.TotaleValoreAccessorio
		--, PO_ORIGIN.value as PO_ORIGINARIO	
		, C1.StatoDoc
		, o.EsitoControlli
from 
	ctl_doc C1 with(nolock) 
		inner join document_oda O  with(nolock) on C1.linkeddoc = o.idHeader
		left join  ProfiliUtente a with( nolock ) on o.UserRUP  = a.IdPfu
		left join aziende AZ with( nolock ) on AZ.idazi=a.pfuidazi
where 
	TipoDoc='ANNULLA_ORDINATIVO' and Statofunzionale in ('Approved','Denied')
	and deleted=0


GO
