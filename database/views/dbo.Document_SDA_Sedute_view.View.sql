USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SDA_Sedute_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Document_SDA_Sedute_view] as 
select 
	[idRow], [idHeader], [NumeroSeduta], [TipoSeduta], 
	[Descrizione], [DataInizio], 
	case when convert(varchar(10),[DataFine],121)= '1900-01-01' then NULL else [DataFine] end as [DataFine],	
	[idPdA], [idVerbale], 
	[idSeduta], [Allegato], [FaseSeduta]
	, idSeduta	 as SEDUTEGrid_ID_DOC
	, 'SEDUTA_SDA' as SEDUTEGrid_OPEN_DOC_NAME
from Document_PDA_Sedute with(nolock)
GO
