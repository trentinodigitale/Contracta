USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_GARA_DATI_PUBBLICAZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD2_BANDO_GARA_DATI_PUBBLICAZIONE] as

select
	c.id as IDDOC,
    convert( VARCHAR(50) , d.DataTermineQuesiti, 126) as DataTermineQuesiti,
	convert( VARCHAR(50) , d.DataScadenzaOfferta, 126) as DataPresentazioneRisposte,
	convert( VARCHAR(50) , d.DataAperturaOfferte, 126) as DataAperturaOfferte,
	v.value as OLD_DataTermineQuesiti,
	v2.value as OLD_DataPresentazioneRisposte,
	v3.value as OLD_DataAperturaOfferte,
	case when isnull(v1.linkeddoc,0) > 0 and V1.TipoModifica = 'PROROGA_GARA' then 'si' else 'no' end  as PresenzaProroga,
	--case when ISNULL(cast(c2.id as varchar(10)),'no') = 'no' then 'no' else 'si' end as PresenzaProroga,
	case when isnull(v1.linkeddoc,0) > 0 and V1.TipoModifica = 'RETTIFICA_GARA' then 'si' else 'no' end  as PresenzaRettifica,
	--case when ISNULL(cast(c3.id as varchar(10)),'no') = 'no' then 'no' else 'si' end as PresenzaRettifica,
	case when isnull(v1.linkeddoc,0) > 0 and V1.TipoModifica = 'RIPRISTINO_GARA' then 'si' else 'no' end  as PresenzaRipristino,
	
	case when ISNULL(cast(c2.id as varchar(10)),'no') = 'no' then '' else dbo.GetXMLALLEGATIBandoGara(c.id,'PROROGA_BANDO_GARA') end as ALLEGATI_PROROGA,
	case when ISNULL(cast(c3.id as varchar(10)),'no') = 'no' then '' else dbo.GetXMLALLEGATIBandoGara(c.id,'RETTIFICA_BANDO_GARA') end as ALLEGATI_RETTIFICA,
	case when ISNULL(cast(c7.id as varchar(10)),'no') = 'no' then '' else dbo.GetXMLALLEGATIBandoGara(c.id,'RIPRISTINO_GARA') end as ALLEGATI_RIPRISTINO,		
	case when ISNULL(cast(c8.id as varchar(10)),'no') = 'no' then '' else dbo.GetXMLALLEGATIBandoGara(c.id,'SOSPENSIONE_GARA') end as ALLEGATI_SOSPENSIONE,
	case when c.StatoFunzionale <> 'Revocato' then '' else dbo.GetXMLALLEGATIBandoGara(c.id,'REVOCA_BANDO_GARA') end as ALLEGATI_REVOCA	
	
 
	, isnull( SA.value ,'NO' )  as MAX_SOGLIA_ALLEGATI_SUPERATA

from 
ctl_doc c with (nolock)
	
	inner join Document_Bando d with (nolock) on d.idheader=c.id 
	
	--left join ctl_doc c2  with (nolock) on c2.linkedDoc=c.id and c2.tipodoc='PROROGA_GARA' and c2.id=(Select min(id) from ctl_doc with (nolock) where linkedDoc=c.id and Tipodoc='PROROGA_GARA' and StatoFunzionale = 'Inviato' )

	left join
		( 
			Select min(id) as id ,linkeddoc
			 from 
					ctl_doc with(nolock) where 
					tipodoc='PROROGA_GARA' 
					and StatoFunzionale = 'Inviato' 
				group by linkeddoc

		) c2 on c2.linkeddoc = c.id

	--left join ctl_doc c4  with (nolock) on c4.linkedDoc=c.id and c4.tipodoc in ('RETTIFICA_GARA','PROROGA_GARA','RIPRISTINO_GARA') and c4.id=(Select min(id) from ctl_doc with (nolock) where linkedDoc=c.id and Tipodoc in ('RETTIFICA_GARA','PROROGA_GARA','RIPRISTINO_GARA' ) and StatoFunzionale = 'Inviato' )

	left join
		( 
			Select min(id) as id ,linkeddoc
			 from 
					ctl_doc with(nolock) where 
					tipodoc in ('RETTIFICA_GARA','PROROGA_GARA','RIPRISTINO_GARA')
					and StatoFunzionale = 'Inviato' 
				group by linkeddoc

		) c4 on c4.linkeddoc = c.id


	left join ctl_doc_value v  with (nolock) on v.idheader=c4.id and v.DSE_ID='TESTATA' and v.Dzt_name='OLD_DataTermineQuesiti'
	left join ctl_doc_value v2  with (nolock) on v2.idheader=c4.id and v2.DSE_ID='TESTATA' and v2.Dzt_name='OLD_DataPresentazioneRisposte'
	left join ctl_doc_value v3  with (nolock) on v3.idheader=c4.id and v3.DSE_ID='TESTATA' and v3.Dzt_name='OLD_DataSeduta'
	
	--left join ctl_doc c3  with (nolock) on c3.linkedDoc=c.id and c3.tipodoc='RETTIFICA_GARA' and c3.id=(Select min(id) from ctl_doc where linkedDoc=c.id and Tipodoc='RETTIFICA_GARA' and StatoFunzionale = 'Inviato')
	left join
		( 
			Select min(id) as id ,linkeddoc
			 from 
					ctl_doc with(nolock) where 
					tipodoc='RETTIFICA_GARA' 
					and StatoFunzionale = 'Inviato' 
				group by linkeddoc

		) c3 on c3.linkeddoc = c.id

	left join ctl_doc_value SA  with (nolock) on SA.idheader=c.id and SA.dse_id='SOGLIA_ALLEGATI' and SA.DZT_NAME='MAX_SOGLIA_ALLEGATI_SUPERATA' and SA.value='YES'
	
	--left  join (
			
	--		select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
	--			inner join ( 
	--							Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and Statodoc ='Sended' group by linkedDoc  
	--							) as M on M.id_DOC = d.id
			
	--		) V1 on V1.LinkedDoc=c.id
	left join
		(
			select SUBV1.linkeddoc, tipodoc as TipoModifica from 
				ctl_doc d with(nolock) 
					inner join ( 
							Select max(id) as id ,linkeddoc
							 from 
									ctl_doc with(nolock) where 
									tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA') 
									and Statodoc ='Sended'
								group by  linkeddoc

							) SUBV1 on SUBV1.id = d.id

		) V1 on V1.linkeddoc = c.id
	--left join ctl_doc c7  with (nolock) on c7.linkedDoc=c.id and c7.tipodoc='RIPRISTINO_GARA' and c7.id=(Select min(id) from ctl_doc with(nolock) where linkedDoc=c.id and Tipodoc='RIPRISTINO_GARA' and StatoFunzionale = 'Inviato' )
	
	left join
		( 
			Select min(id) as id ,linkeddoc
			 from 
					ctl_doc with(nolock) where 
					tipodoc='RIPRISTINO_GARA' 
					and StatoFunzionale = 'Inviato' 
				group by linkeddoc

		) c7 on c7.linkeddoc = c.id

	--left join ctl_doc c8  with (nolock) on c8.linkedDoc=c.id and c8.tipodoc='PDA_COMUNICAZIONE_GENERICA' and c8.JumpCheck = '0-SOSPENSIONE_GARA' 
	
		--and c8.id=(
	left join
		( 
			Select min(id) as id ,linkeddoc
			 from 
					ctl_doc with(nolock) where 
					tipodoc='PDA_COMUNICAZIONE_GENERICA' 
					and JumpCheck = '0-SOSPENSIONE_GARA' and StatoFunzionale = 'Inviato' 
				group by linkeddoc

		) c8 on c8.linkeddoc = c.id

where c.tipodoc in ('BANDO_GARA','BANDO_SDA','BANDO_SEMPLIFICATO') and c.StatoFunzionale <> 'InLavorazione'






GO
