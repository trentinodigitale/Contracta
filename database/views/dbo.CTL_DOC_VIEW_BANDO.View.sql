USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_VIEW_BANDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view [dbo].[CTL_DOC_VIEW_BANDO] as

--Versione=2&data=2014-09-03&Attivita=62233&Nominativo=Sabato
--Versione=3&data=2014-12-19&Attivita=67491&Nominativo=Sabato

select  


	d.Id,
	d.IdPfu,
	d.IdDoc,
	d.TipoDoc,
	d.StatoDoc,
	d.Data,
	d.Protocollo,
	d.PrevDoc,
	cast(d.Deleted as int ) as deleted, 
	d.Titolo, 
	d.Body, 
	d.Azienda, 
	d.StrutturaAziendale, 
	d.DataInvio,
	--d.DataScadenza,

	case when convert(varchar(10),d.DataScadenza,121)<> '1900-01-01'
		then convert(varchar ,d.DataScadenza,121) 
		else '3000-01-01'
	end
	as  DataScadenza,


	d.ProtocolloRiferimento,
	d.ProtocolloGenerale,
	d.Fascicolo, 
	d.Note,
	d.DataProtocolloGenerale, 
	d.LinkedDoc, 
	d.SIGN_HASH, 
	d.SIGN_ATTACH, 
	d.SIGN_LOCK, 
	isnull( d.JumpCheck , '' ) as JumpCheck, 
	d.StatoFunzionale, 
	d.Destinatario_User, 
	d.Destinatario_Azi,
	convert(varchar,getdate(),121) as DATACORRENTE,
	d.RichiestaFirma,
	d.NumeroDocumento,
	d.DataDocumento,
	d.Versione,
	d.VersioneLinkedDoc,
	d.GUID,
	
	isnull( d.idPfuInCharge , 0 ) as idPfuInCharge,
	ISNULL(DC.idpfu,'') as ResponsabileProcedimento,
    isnull(d.CanaleNotifica,'mail') as CanaleNotifica ,

	case when b.datascadenza is null then  'no' 
		 when b.datascadenza < getdate() then  'si' 
		 else 'no'
		 end as	BANDO_SCADUTO
	,
	
	

	rup.Value as UserRUP,
	 case when getdate() >= d.DataScadenza and d.StatoFunzionale <> 'InLavorazione' then '1' else '0' end as SCADENZA_INVIO_OFFERTE
	 ,case when isnull( d.Caption , '' ) = '' and d.tipodoc = 'PDA_COMUNICAZIONE_GARA' then d.titolo else d.caption  end as Caption

	,case when b.statofunzionale = 'Revocato' then 'si' 
		 else 'no'
		 end as	BANDO_REVOCATO
	,d.FascicoloGenerale
	,d.URL_CLIENT
	,case when ISNULL(DIZ.DZT_ValueDef,'YES')='YES' then 'si' else 'no' end as Anagrafica_Master
	--,case when ISNULL(DIZ2.DZT_ValueDef,'YES')='YES' then 'si' else 'no' end as DISATTIVA_DATI_PARIX
	,case when ISNULL(DIZ2.DZT_ValueDef,'') = '' then 'si' else 'no' end as DISATTIVA_DATI_PARIX
	,ISNULL(numrisposte,0) as numrisposte
	,dbo.PARAMETRI('ATTIVA_MODULO','CONTROLLI_OE','ATTIVA','NO',-1)  as ATTIVA_MODULO_CONTROLLI_OE
	,ab.FreqControlli 
	,b1.PresenzaCatalogo
	

from CTL_DOC d with (nolock)
--	left outer join CTL_ApprovalSteps s on 
--						s.APS_Doc_Type = d.TipoDoc 
--						and s.APS_ID_DOC = d.id
--						and s.APS_State = 'InCharge'
--						and s.APS_IsOld = 0

    left outer join Document_Bando_Commissione  DC with (nolock) on d.id=DC.IdHeader and DC.RuoloCommissione=15550
    left outer join ctl_doc b with (nolock) on b.id = d.linkeddoc and ( left( b.tipodoc , 5 ) = 'BANDO' )
    left outer join document_bando b1 with (nolock)  on b1.idheader=d.id
    left outer join ctl_doc_value rup with (nolock) on d.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
    left outer join ctl_doc_value ds with (nolock) on d.id = ds.idHeader and  ds.dzt_name = 'DataScadenzaIstanza' and ds.dse_id = 'SCADENZA_ISTANZA'
    left outer join Document_Parametri_Abilitazioni ab with (nolock) on ab.deleted = 0 and 
				    (
					    ( ab.TipoDoc = 'SDA' and d.TipoDoc = 'BANDO_SDA'  and ab.idheader = d.id )
					    or
					    ( ab.TipoDoc = 'ALBO' and d.TipoDoc = 'BANDO' )
				    )

    left outer join  LIB_Dictionary DIZ with (nolock) on DIZ.DZT_Name='SYS_ANAGRAFICA_MASTER'
    --left outer join  LIB_Dictionary DIZ2 with (nolock) on DIZ2.DZT_Name='SYS_DISATTIVA_PARIX'
	left outer join  LIB_Dictionary DIZ2 with (nolock) on DIZ2.DZT_Name='SYS_CONNETTORE_AZIENDE_EXT'
	left join ( select count(*) as numrisposte,LinkedDoc  from CTL_DOC C where TipoDoc in ('COM_DPE_RISPOSTA','PDA_COMUNICAZIONE_RISP','PDA_COMUNICAZIONE_OFFERTA_RISP','VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') group by LinkedDoc) as L on L.LinkedDoc=d.id
GO
