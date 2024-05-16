USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AZI_VIEW_SCHEDA_ANAGRAFICA_ABILITAZIONI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE view [dbo].[OLD2_AZI_VIEW_SCHEDA_ANAGRAFICA_ABILITAZIONI] as
		select
			D.idazi,
			D.idrow as id,
			D.StatoIscrizione,
			D.DataScadenzaIscrizione,
			C.titolo,
			C.protocollo,
			C.protocollogenerale,
			case 
				when C.tipodoc = 'BANDO' and isnull(jumpcheck,'')='' then 'ME' 
				when C.tipodoc = 'BANDO' and isnull(jumpcheck,'')='BANDO_ALBO_LAVORI' then 'BANDO_ALBO_LAVORI' 
				when C.tipodoc = 'BANDO_SDA' then 'SDA' 
			end as Abilitazione,
			'CANCELLA_ISCRIZIONE' as MAKE_DOC_NAME,
			'BANDO' as OPEN_DOC_NAME

		from CTL_DOC_Destinatari D   with (nolock)
			 inner join ctl_doc C   with (nolock) on D.idheader=C.id 
		where C.StatoFunzionale <> 'InLavorazione' and c.tipodoc in ('BANDO','BANDO_SDA') and ISNULL(D.StatoIscrizione,'')<>''
		and C.Deleted=0



GO
