USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_PDA_Sedute_view]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_Document_PDA_Sedute_view] as 


			select 
				 [idRow], Document_PDA_Sedute.[idHeader], 
				 [NumeroSeduta], [TipoSeduta], 
				 [Descrizione], [DataInizio], 
				 [DataFine], [idPdA], [idVerbale], 
				 [idSeduta], [FaseSeduta]
				, idSeduta	 as SEDUTEGrid_ID_DOC
				, 'SEDUTA_PDA' as SEDUTEGrid_OPEN_DOC_NAME
				, StatoFunzionale as StatoFilter
				,case 
					when num_allegato = 1 then w.Allegato
					when num_allegato > 1 then 'DOWNLOAD_ZIP@@@' + w.Allegato
					else''
				 end  as Allegato

			from Document_PDA_Sedute with (nolock)
				 inner join CTL_DOC with (nolock) on Id = idseduta 
				 left join ( select IdHeader,COUNT(*) as num_allegato,max(value) as Allegato from CTL_DOC_Value where DSE_ID='ELENCO_VERBALI' and DZT_Name='Allegato'  and value <> '' group by IdHeader) as  W on w.IdHeader=idseduta
GO
