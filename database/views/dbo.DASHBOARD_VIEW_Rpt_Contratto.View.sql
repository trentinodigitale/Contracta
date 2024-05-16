USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Contratto]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--
---------------------------------------------------------------

CREATE  view [dbo].[DASHBOARD_VIEW_Rpt_Contratto] as
select  
ID, 
DOC_Owner, 
DOC_Name, 
DataCreazione, 
Protocol, 
DescrizioneEstesa, 
StatoConvenzione, 
AZI_Dest, 
NumOrd, 
Total, 
ProtocolloBando, 
DataInizio, 
DataFine, 
Merceologia, 
TotaleOrdinato, 
IVA, 
NewTotal, 
TipoImporto, 
 ID as LinkedDoc, 
 isnull( Total , 0 ) - isnull( TotaleOrdinato , 0 ) as BDG_TOT_Residuo
,isnull( Total , 0 ) - ISNULL(AL2.ImportoAllocabile,0) as ImportoAllocabile
  from Document_Convenzione 
left outer join (
			Select sum(Importo) as ImportoAllocabile,LinkedDoc
			from 
				CTL_DOC 
				inner join Document_Convenzione_Quote on id = idheader
			where 
				StatoDoc = 'Sended' and TipoDoc='QUOTA' 
				group by (LinkedDoc)
			) as AL2 on AL2.LinkedDoc = id
--where Deleted = 0
--and StatoConvenzione = 'Pubblicato'
--and id =15	-- SOLO PER TEST!!!


GO
