USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONTROLLI_OE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_CONTROLLI_OE]
as
	select 
		
			d.idpfu,
			a.id,
			a.[idPfuInCharge],
			c.Titolo ,
			azi.aziRagioneSociale ,
			azi.aziPartitaIVA ,
			cf.vatvalore_ft as azicodicefiscale,
			a.data,
			a.data as dataA,
			case when a.StatoDoc='Saved' then '' else a.StatoDoc end as Statodoc, -- esito controllo
			--a.StatoDoc,
			a.DataScadenza ,
			c.Protocollo ,
			c.id as ListaAlbi,
			a.TipoDoc as OPEN_DOC_NAME,
			a.id as iddoc,
			a.JumpCheck 


		from ctl_doc a with (nolock)
	
			inner join ctl_doc b with (nolock) on a.LinkedDoc = b.id and b.TipoDoc = 'OE_DA_CONTROLLARE'
			inner join ctl_doc c with (nolock) on b.LinkedDoc = c.id 
			inner join Document_Bando_Riferimenti d with (nolock) on d.idHeader = c.id
			inner join aziende azi with (nolock) on idazi=a.Destinatario_Azi 
			left outer join dm_attributi cf with(nolock) on cf.idapp=1 and cf.lnk=azi.idazi and cf.dztnome='codicefiscale'

				where a.tipodoc = 'CONTROLLI_OE'
						and a.deleted=0 
						and b.Deleted=0 
						and c.Deleted = 0 
						and RuoloRiferimenti = 'Istanze'
						and a.StatoFunzionale <> 'Annullato'

--select * from ctl_doc where tipodoc = 'CONTROLLI_OE' and deleted=0
--select * from Document_Controlli_OE_Controlli
--select * from DASHBOARD_VIEW_BANDO
GO
