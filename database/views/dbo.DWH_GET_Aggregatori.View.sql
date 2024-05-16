USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_GET_Aggregatori]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DWH_GET_Aggregatori] as 

select 
	A.azilog as CodiceAziendaAggregatore,
	isnull(A1.azilog,'ALL') as CodiceAzienda


	from ctl_doc F with (nolock)
		inner join aziende A  with (nolock) on A.idazi = F.azienda
		left join ctl_doc_value E with (nolock) on E.IdHeader = F.id and E.dse_id='ENTI' and E.dzt_name='IdAzi'
		inner join aziende A1 with (nolock) on A1.idazi = E.value
	where 
		F.tipodoc='ACCORDO_CREA_FABBISOGNI'
GO
