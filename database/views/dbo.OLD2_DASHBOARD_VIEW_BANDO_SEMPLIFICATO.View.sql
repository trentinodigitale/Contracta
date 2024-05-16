USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD2_DASHBOARD_VIEW_BANDO_SEMPLIFICATO] as
select 
	case d.statofunzionale
		when 'ProntoPerInviti' then 'BANDO_SEMPLIFICATO_IN_APPROVE'
		else d.TipoDoc
	end as OPEN_DOC_NAME,
	d.id,
	d.idpfu,
	d.iddoc,
	d.TipoDoc,
	d.StatoDoc,
	TipoBando,
	d.Data,
	d.Protocollo,
	d.PrevDoc,
	d.Deleted,
	d.Titolo,
	cast( d.Body as nvarchar(4000)) as Body,
	d.Azienda,
	d.StrutturaAziendale,
	d.DataInvio,
	d.DataScadenza,
	d.ProtocolloGenerale,
	d.ProtocolloRiferimento,
	d.Fascicolo,
	cast( d.Note as nvarchar(4000)) as Note,
	d.DataProtocolloGenerale,
	d.LinkedDoc,
	d.StatoFunzionale,
	d.Destinatario_User,
	d.Destinatario_Azi ,
  --  case 
		--				when VisualizzaNotifiche = '0'and getdate() < DataAperturaOfferte then null  --dataprimaseduta
		--				when VisualizzaNotifiche = '1'and getdate() < DataScadenzaOffIndicativa then null  --termine presentazioni offerte
		--				else RecivedIstanze
	 --end as RecivedIstanze ,
	 case 
				when VisualizzaNotifiche = '0' and getdate() < DataScadenzaOfferta then null  ---termine presentazioni offerte presente sul bando		
				else RecivedIstanze
			end as RecivedIstanze ,
	ProtocolloBando,
	value as UserRUP,
	ISNULL(Appalto_Verde,'no') as Appalto_Verde,
	ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale ,
	case 
		when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
		when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
		when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
	end as Bando_Verde_Sociale
	, SDA.Titolo as TitoloSDA
	
from CTL_DOC  d  with(nolock) 
	inner join CTL_DOC SDA  with(nolock) on d.LinkedDoc = SDA.id
	inner join dbo.Document_Bando  with(nolock) on d.id = idheader
	left outer join CTL_DOC_Value v2  with(nolock) on v2.idheader=d.id and dzt_name = 'UserRUP' and DSE_ID = 'InfoTec_comune'
where d.deleted = 0 and d.TipoDoc in ( 'BANDO_SEMPLIFICATO' )

union all

---PER DARE LA VISIBILITA' DEL DOCUMENTO AL RUP
select 
	case d.statofunzionale
		when 'ProntoPerInviti' then 'BANDO_SEMPLIFICATO_IN_APPROVE'
		else d.TipoDoc
	end as OPEN_DOC_NAME,
	d.id,
	value as idpfu,
	d.iddoc,
	d.TipoDoc,
	d.StatoDoc,
	TipoBando,
	d.Data,
	d.Protocollo,
	d.PrevDoc,
	d.Deleted,
	d.Titolo,
	cast( d.Body as nvarchar(4000)) as Body,
	d.Azienda,
	d.StrutturaAziendale,
	d.DataInvio,
	d.DataScadenza,
	d.ProtocolloGenerale,
	d.ProtocolloRiferimento,
	d.Fascicolo,
	cast( d.Note as nvarchar(4000)) as Note,
	d.DataProtocolloGenerale,
	d.LinkedDoc,
	d.StatoFunzionale,
	d.Destinatario_User,
	d.Destinatario_Azi ,
  --  case 
		--				when VisualizzaNotifiche = '0'and getdate() < DataAperturaOfferte then null  --dataprimaseduta
		--				when VisualizzaNotifiche = '1'and getdate() < DataScadenzaOffIndicativa then null  --termine presentazioni offerte
		--				else RecivedIstanze
	 --end as RecivedIstanze ,
	 case 
			when VisualizzaNotifiche = '0' and getdate() < DataScadenzaOfferta then null  ---termine presentazioni offerte presente sul bando		
			else RecivedIstanze
	end as RecivedIstanze ,
	ProtocolloBando,
	value as UserRUP,
	ISNULL(Appalto_Verde,'no') as Appalto_Verde,
	ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale ,
	case 
		when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
		when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
		when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
	end as Bando_Verde_Sociale
	, SDA.Titolo as TitoloSDA
	
from 

	CTL_DOC  d with(nolock) 
		inner join CTL_DOC SDA  with(nolock) on d.LinkedDoc = SDA.id
		inner join dbo.Document_Bando  with(nolock) on d.id = idheader
		inner join CTL_DOC_Value v2  with(nolock) on v2.idheader=d.id and dzt_name = 'UserRUP' and DSE_ID = 'InfoTec_comune' 
														and isnull( v2.Value , 0 ) <> cast( d.IdPfu as varchar(20) )
where 
	d.deleted = 0 and d.TipoDoc in ( 'BANDO_SEMPLIFICATO' ) 










GO
