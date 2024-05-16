USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CTL_DOC_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select top 1000 * from [CTL_DOC_VIEW] 


CREATE  view [dbo].[OLD2_CTL_DOC_VIEW] as

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
	
	case
		when --d.datascadenza is null 
				ds.value is null
				and d.StatoFunzionale in ( 'Confermato','ConfermatoParz' ) --then 'si'
				--tipodoc istanza compatibile con tipobando
				and d.TipoDoc = 'ISTANZA_' + isnull(b1.TipoBando,'' ) then 'si'
		when (
				dateadd( month , isnull( ab.NumMaxPerConferma , 0 ) , /*d.datascadenza*/ cast(  ds.value as datetime )   ) >= getdate() 
				or 
				DATEDIFF(day,getDate(),dateadd( day,1,cast(  ds.value as datetime ))) > 0
			 )
			 and d.StatoFunzionale in ( 'Confermato','ConfermatoParz' )  --then 'si'
			 --tipodoc istanza compatibile con tipobando
			 and d.TipoDoc = 'ISTANZA_' + isnull(b1.TipoBando,'' ) then 'si'

		else 'no'

	end as CAN_CONFERMA	,

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
	--PER LE COMUNICAZIONE_RICHIESTA_STIPULA_CONTRATTO RECUPERO IL VALORE DEL PARAMETRO
	--PER LE ALTRE FISSO A NO
	,case  
		when Right(d.JumpCheck,27) = 'RICHIESTA_STIPULA_CONTRATTO' then	dbo.PARAMETRI('COMUNICAZIONE_RICHIESTA_STIPULA_CONTRATTO','AREA_FIRMA','ATTIVA','NO',-1) 
		else 'NO'
	  end as VISUALIZZA_AREA_FIRMA	

	, isnull(b1.classeiscriz,'') as ClassiBando

from CTL_DOC d with (nolock)
--	left outer join CTL_ApprovalSteps s on 
--						s.APS_Doc_Type = d.TipoDoc 
--						and s.APS_ID_DOC = d.id
--						and s.APS_State = 'InCharge'
--						and s.APS_IsOld = 0

    left outer join Document_Bando_Commissione  DC with (nolock) on d.id=DC.IdHeader and DC.RuoloCommissione=15550
    left outer join ctl_doc b with (nolock) on b.id = d.linkeddoc and ( left( b.tipodoc , 5 ) = 'BANDO' )
    left outer join document_bando b1 with (nolock)  on b1.idheader=b.id
    left outer join ctl_doc_value rup with (nolock) on d.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
    left outer join ctl_doc_value ds with (nolock) on d.id = ds.idHeader and  ds.dzt_name = 'DataScadenzaIstanza' and ds.dse_id = 'SCADENZA_ISTANZA'
    left outer join Document_Parametri_Abilitazioni ab with (nolock) on ab.deleted = 0 and 
				    (
					    ( ab.TipoDoc = 'SDA' and b.TipoDoc = 'BANDO_SDA' and ab.idheader = b.id )
					    or
					    ( ab.TipoDoc = 'ALBO' and b.TipoDoc = 'BANDO' )
				    )

    left outer join  LIB_Dictionary DIZ with (nolock) on DIZ.DZT_Name='SYS_ANAGRAFICA_MASTER'
    --left outer join  LIB_Dictionary DIZ2 with (nolock) on DIZ2.DZT_Name='SYS_DISATTIVA_PARIX'
	left outer join  LIB_Dictionary DIZ2 with (nolock) on DIZ2.DZT_Name='SYS_CONNETTORE_AZIENDE_EXT'
	left join ( select count(*) as numrisposte,LinkedDoc  from CTL_DOC C where TipoDoc in ('COM_DPE_RISPOSTA','PDA_COMUNICAZIONE_RISP','PDA_COMUNICAZIONE_OFFERTA_RISP','VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') group by LinkedDoc) as L on L.LinkedDoc=d.id


GO
