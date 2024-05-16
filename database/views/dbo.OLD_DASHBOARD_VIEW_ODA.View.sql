USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ODA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_ODA]
AS
SELECT    
		o.idHeader
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
		, 'ODA' as OPEN_DOC_NAME
		, C1.SIGN_HASH
		, C1.SIGN_ATTACH
		, C1.SIGN_LOCK
		, case 
			when R.utente = 'COMPILATORE' then isnull( attvalue,'') 
			else ''
			end
			as UserRole            --------------->

		, StatoFunzionale
		--, C1.IdPfu
	 
		, case 
			when R.utente = 'COMPILATORE' then isnull( SUB.Value , C1.IdPfu ) 
			else O.UserRup 
			end
			as IdPfu     --------------->

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
		, DataInvio
		, Data
		, C1.Protocollo
		, IdDocIntegrato
		, O.Allegato
		, codiceIPA
		, TotaleEroso
		, TotalIvaEroso
		, o.ValoreIva
		, case 
			when isnull(O.IdDocIntegrato,0) > 0 then 'si'
			else 'no'
			end as Multiplo	 
		, O.TotaleValoreAccessorio
		, PO_ORIGIN.value as PO_ORIGINARIO	
		, C1.StatoDoc
		, o.EsitoControlli
	  
FROM           
	CTL_DOC C1 with( nolock ) 
	inner join	Document_ODA O with( nolock ) on O.idHeader=C1.id 
	left join  ProfiliUtente a with( nolock ) on o.UserRUP  = a.IdPfu
	left join aziende AZ with( nolock ) on AZ.idazi=a.pfuidazi	
	inner join profiliutenteattrib PA with( nolock ) on C1.idpfu=PA.idpfu and dztnome='UserRoleDefault'
	left outer join ctl_doc_value  SUB with( nolock ) on SUB.DSE_ID='Subentro' and dzt_name = 'Subentro'  and c1.id = SUB.idheader 
	inner join ( select 'COMPILATORE' as utente union all select 'RUP' as utente ) as R on ( R.utente = 'COMPILATORE' ) or (  R.utente = 'RUP' and isnull( SUB.Value , C1.IdPfu ) <> O.UserRup and C1.statofunzionale <> 'InLavorazione' )
	left outer join ctl_doc_value  PO_ORIGIN with( nolock ) on  PO_ORIGIN.DSE_ID='PO_ORIGINARIO' and PO_ORIGIN.dzt_name = 'PO_ORIGINARIO'  and c1.id = PO_ORIGIN.idheader 
 
 WHERE 
	C1.TipoDoc='ODA'
	AND C1.deleted=0
GO
