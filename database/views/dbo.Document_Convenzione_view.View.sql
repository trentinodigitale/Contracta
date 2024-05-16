USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Convenzione_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[Document_Convenzione_view] as
select 
		C.Idpfu,
		D.IdRow, 
		D.ID, 
		D.DOC_Owner, 
		D.DOC_Name, 
		D.DataCreazione, 
		C.Protocollo as Protocol, 
		C.Protocollo ,
		D.DescrizioneEstesa, 
		D.StatoConvenzione, 
		D.AZI, 
		D.Plant, 
		D.Deleted, 
		D.AZI_Dest, 
		D.NumOrd, 
		D.Imballo, 
		D.Resa, 
		D.Spedizione, 
		D.Pagamento, 
		D.Valuta, 
		D.Total, 
		D.Completo, 
		D.Allegato, 
		D.Telefono, 
		D.Compilatore, 
		D.RuoloCompilatore, 
		D.TipoOrdine, 
		D.SendingDate, 
		D.ProtocolloBando, 
		D.DataInizio, 
		D.DataFine, 
		D.Merceologia, 
		D.TotaleOrdinato, 
		D.IVA, 
		D.NewTotal, 
		D.RicPropBozza, 
		D.ConvNoMail, 
		D.QtMinTot, 
		D.RicPreventivo, 
		D.TipoImporto, 
		D.TipoEstensione, 
		D.RichiediFirmaOrdine, 
		D.OggettoBando, 
		D.DataProtocolloBando, 
		D.Mandataria, 
		D.ProtocolloContratto, 
		D.ProtocolloListino, 
		D.DataContratto, 
		D.DataListino, 
		D.ReferenteFornitore, 
		D.CodiceFiscaleReferente, 
		D.ReferenteFornitoreHide, 
		D.Ambito,

		case 
			when isnull(D.Stipula_in_forma_pubblica,0) = 1  then 'no'
			when ( ISNULL(F1_SIGN_ATTACH,'') <> ''  and ISNULL(F2_SIGN_ATTACH,'') <> '' ) OR ( isnull(ppp.Valore,'') = '0' ) then 'si'
			else 'no' 
		end	as INVIOCONTRATTO

		,ISNULL(c1.Statofunzionale,'')  as StatoContratto  
		,ISNULL(c2.Statofunzionale,'')  as StatoListino 
		
		,
		

		case 
			--nel caso Stipula_in_forma_pubblica = SI 
			--oppure ConvenzioniInUrgenza = 1 aloora basta solo il listino confermato	
			when ( isnull(D.Stipula_in_forma_pubblica,0) = 1 or isnull(D.ConvenzioniInUrgenza ,0) = 1 )  AND ISNULL(c2.Statofunzionale,'') = 'Confermato' then 'SI'
			--when isnull(D.Stipula_in_forma_pubblica,0) = 0 AND ISNULL(c1.Statofunzionale,'') = 'Confermato'  and ISNULL(c2.Statofunzionale,'') = 'Confermato' then 'SI'
			when ISNULL(c1.Statofunzionale,'') = 'Confermato'  and ISNULL(c2.Statofunzionale,'') = 'Confermato' then 'SI'
			else 'NO'
		
		end as 	PUBBLICA_CONVENZIONE ,


		D.GestioneQuote ,
		c.caption,
		ISNULL(c.jumpcheck,'') as jumpcheck,
		case when D.DataFine > getdate() then 'NO' else 'SI' end as SCADUTA,

		case when ISNULL(sys2.DZT_ValueDef,'') <> '' then '1' else '0' end as Check_AIC_Enabled,
		case when ma_id is null then '0' else '1' end as PresenzaAIC,
		isnull(D.Stipula_in_forma_pubblica,0)  as Stipula_in_forma_pubblica
		,ISNULL(ConvenzioniInUrgenza,0) as ConvenzioniInUrgenza
		, case
			when c.StatoFunzionale = 'InLavorazione' then 'false'
			else 'true'
		end as ConvenzioneReadOnly
		,
		--flag per abilitare richiamo contratto
		case 
			when 
				( c.StatoFunzionale = 'InLavorazione'  and  ( StatoContratto = 'Inviato' or  StatoContratto = 'Confermato' ) )
				or 
				( ConvenzioniInUrgenza = '1' and statoconvenzione = 'Pubblicato' and  StatoContratto = 'Inviato' )  then 'true'
			else 'false'

		end	as Abilita_Richiamo_Contratto,
		case when dbo.PARAMETRI('SERVICE_REQUEST','TED','ATTIVO','NO',-1) = 'YES' then 1 else 0 end as ted,
		case when C.FascicoloGenerale <> '' then 1 else 0 end as CAN_GESTIONE_GUEE,

		c.LinkedDoc --in eProcNext andava in errore l'eval del comando "Convenzione Completa", condition : LinkedDoc <> '0'  ~~~ jumpcheck = 'INTEGRAZIONE'
			-- veniva usata la colonna LinkedDoc senza essere stata ritornata dalla vista. il codice vb6 lo gestiva come stringa vuota

from 
	CTL_DOC c with (nolock)
		inner join  Document_Convenzione D with (nolock) on D.id=C.id
		left join ctl_doc_sign with (nolock) on idheader=D.id
		left join ctl_doc c1 with (nolock) on D.id=c1.LinkedDoc and C1.tipodoc='CONTRATTO_CONVENZIONE' and C1.StatoFunzionale <> 'Rifiutato' and c1.deleted = 0
		left join ctl_doc c2 with (nolock) on D.id=c2.LinkedDoc and C2.tipodoc='LISTINO_CONVENZIONE' and C2.StatoFunzionale <> 'Rifiutato' and c2.deleted = 0
		left outer join CTL_Parametri ppp with (nolock) on [Contesto] = 'CONVENZIONE_ALLEGATI_FIRMATI' and [Oggetto] = 'F1_SIGN_ATTACH' and [Proprieta] = 'Obbligatory'
		 --RECUPERA LA SYS_AIC_URL_PAGE
		left join LIB_Dictionary sys2 with (nolock) on sys2.DZT_Name='SYS_AIC_URL_PAGE'
		-- verifica se nel modello c'è la colonna AIC
		left outer join ctl_doc_section_model x with (nolock) on x.IdHeader = c.id and x.DSE_ID = 'PRODOTTI'
		left outer join CTL_ModelAttributes  WITH(INDEX(IX_CTL_ModelAttributes_MA_MOD_ID_MA_DZT_Name_MA_DescML_MA_Pos) nolock)    on MA_MOD_ID = x.MOD_Name and MA_DZT_Name = 'CodiceAIC'	
where 
	c.deleted=0 and c.tipodoc='CONVENZIONE'


GO
