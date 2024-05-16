USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Esito_PREVQUOT]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Document_Esito_PREVQUOT] as
select *,Quotidiani as CopiaQuotidiani ,
case 
	when isnull(StatoEsitoRow,'')='' or StatoEsitoRow = 'Saved' then ''
	when StatoEsitoRow = 'Booked'  then ' NumMod , Importo '
	else ' NumMod , Importo , NumeroImpegni ' 
end
as NotEditable
from document_esito_pubblicazioni 
where tipo='QUOTIDIANI'

GO
