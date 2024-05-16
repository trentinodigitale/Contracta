USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_CONSULTAZIONE_DATI_PUBBLICAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[BANDO_CONSULTAZIONE_DATI_PUBBLICAZIONE] as
select
	c.id as IDDOC,
    convert( VARCHAR(50) , d.DataTermineQuesiti, 126) as DataTermineQuesiti,
	convert( VARCHAR(50) , d.DataScadenzaOfferta, 126) as DataPresentazioneRisposte,
	convert( VARCHAR(50) , d.DataAperturaOfferte, 126) as DataAperturaOfferte,
	v.value as OLD_DataTermineQuesiti,
	v2.value as OLD_DataPresentazioneRisposte,
	v3.value as OLD_DataAperturaOfferte,
	case when ISNULL(cast(c2.id as varchar(10)),'no') = 'no' then 'no' else 'si' end as PresenzaProroga,
	case when ISNULL(cast(c3.id as varchar(10)),'no') = 'no' then 'no' else 'si' end as PresenzaRettifica,
	case when ISNULL(cast(c2.id as varchar(10)),'no') = 'no' then '' else dbo.GetXMLALLEGATIBandoCONSULTAZIONE(c.id,'PROROGA_BANDO_CONSULTAZIONE') end as ALLEGATI_PROROGA,
	case when ISNULL(cast(c3.id as varchar(10)),'no') = 'no' then '' else dbo.GetXMLALLEGATIBandoCONSULTAZIONE(c.id,'RETTIFICA_BANDO_CONSULTAZIONE') end as ALLEGATI_RETTIFICA,
	isnull( SA.value ,'NO' )  as MAX_SOGLIA_ALLEGATI_SUPERATA

from 
ctl_doc c
	inner join Document_Bando d with (nolock) on d.idheader=c.id 
	left join ctl_doc c2  with (nolock) on c2.linkedDoc=c.id and c2.tipodoc='PROROGA_CONSULTAZIONE' and c2.id=(Select min(id) from ctl_doc where linkedDoc=c.id and Tipodoc='PROROGA_CONSULTAZIONE' and StatoFunzionale = 'Inviato' )
	left join ctl_doc c4  with (nolock) on c4.linkedDoc=c.id and c4.tipodoc in ('RETTIFICA_CONSULTAZIONE','PROROGA_CONSULTAZIONE') and c4.id=(Select min(id) from ctl_doc where linkedDoc=c.id and Tipodoc in ('RETTIFICA_CONSULTAZIONE','PROROGA_CONSULTAZIONE' ) and StatoFunzionale = 'Inviato' )
	left join ctl_doc_value v  with (nolock) on v.idheader=c4.id and v.DSE_ID='TESTATA' and v.Dzt_name='OLD_DataTermineQuesiti'
	left join ctl_doc_value v2  with (nolock) on v2.idheader=c4.id and v2.DSE_ID='TESTATA' and v2.Dzt_name='OLD_DataPresentazioneRisposte'
	left join ctl_doc_value v3  with (nolock) on v3.idheader=c4.id and v3.DSE_ID='TESTATA' and v3.Dzt_name='OLD_DataSeduta'
	left join ctl_doc c3  with (nolock) on c3.linkedDoc=c.id and c3.tipodoc='RETTIFICA_CONSULTAZIONE' and c3.id=(Select min(id) from ctl_doc where linkedDoc=c.id and Tipodoc='RETTIFICA_CONSULTAZIONE' and StatoFunzionale = 'Inviato')
	left join ctl_doc_value SA  with (nolock) on SA.idheader=c.id and SA.dse_id='SOGLIA_ALLEGATI' and SA.DZT_NAME='MAX_SOGLIA_ALLEGATI_SUPERATA' and SA.value='YES'


where c.tipodoc in ('BANDO_CONSULTAZIONE') and c.StatoFunzionale <> 'InLavorazione'







GO
