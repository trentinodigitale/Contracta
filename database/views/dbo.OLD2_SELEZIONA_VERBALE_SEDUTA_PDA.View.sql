USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SELEZIONA_VERBALE_SEDUTA_PDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_SELEZIONA_VERBALE_SEDUTA_PDA] as
select
	id,
	id as idRow,
	Titolo as Descrizione,
	LinkedDoc,
	Id as IndRow,
	' Descrizione Allegato ' as NotEditable,
	'VERBALEGARA' as OPEN_DOC_NAME,
	SIGN_ATTACH as Allegato,
	JumpCheck,
	CASE 
		WHEN JumpCheck = 'Amministrativo' then 'Amministrativa'
		WHEN JumpCheck = 'Tecnico' then 'Tecnica'
		WHEN JumpCheck = 'Economico' then 'Economica'
	END AS FaseSeduta 

	from ctl_doc with(nolock)	
		--RECUPERO I VERBALI DI GARA PRESENTI IN UNA SEDUTA
		left join (
					select  Value as id_Verbale 
						from CTL_DOC with(nolock)
							inner join CTL_DOC_Value with(nolock)on IdHeader=id and DSE_ID='ELENCO_VERBALI' and DZT_Name='idRow' and ISNULL(Value,'') <> ''
					where TipoDoc='SEDUTA_PDA' and StatoFunzionale <> 'Variato'
				  ) as W on id_Verbale=id
	where TipoDoc='VERBALEGARA' and Deleted=0 and StatoFunzionale in ('Archiviato')
			and W.id_Verbale is null
GO
