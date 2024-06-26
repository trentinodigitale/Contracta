USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SEDUTA_PDA_FROM_PDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[OLD_SEDUTA_PDA_FROM_PDA] as 

select 
		d.id as ID_From 
		, d.ID AS LinkedDoc
		, Fascicolo
		, ProtocolloRiferimento
		, isnull( NumeroSeduta , 0 ) + 1  as NumeroSeduta
		, isnull( NumeroSeduta , 0 ) + 1  as NumeroDocumento
		,StrutturaAziendale
		,Azienda
	from 
		CTL_DOC d with (nolock)
			left outer join (
					SELECT MAX( NumeroSeduta ) AS NumeroSeduta , id
						from dbo.Document_PDA_Sedute with (nolock) 
							inner join CTL_DOC with (nolock) on id = idheader
						group by id 
				) as a on a.id = d.id
		where d.tipodoc = 'PDA_MICROLOTTI'

GO
