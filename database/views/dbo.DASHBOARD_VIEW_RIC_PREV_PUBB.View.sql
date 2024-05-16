USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RIC_PREV_PUBB]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_RIC_PREV_PUBB]
AS
SELECT DISTINCT 
case when NumQuotReg + NumQuotNaz > 0 then 
			case  
			when  StatoRicPrevPubblic = 'PreRequestPubbBurcGuri' and RicPubDPE = '0' then 'Compiled'
			when  StatoRicPrevPubblic = 'PreRequestPubbBurcGuri' and RicPubDPE = '1' and StatoDataPubb='Sended' then 'PublishedQuotidiani'
			when  StatoRicPrevPubblic = 'PreRequestPubbBurcGuri' and RicPubDPE = '1' and StatoDataPubb='Saved' then 'PreRequestPubbQuotidiani'
			when  StatoRicPrevPubblic = 'PublishedBurcGuri' and RicPubDPE = '0'  then 'Compiled'		
			when  StatoRicPrevPubblic = 'PublishedBurcGuri' and RicPubDPE = '1' and exists (select * from document_ricpubblic where document_ricprevpubblic.id = idricprevpubblic and tipopubblic = 'ALTRI' and statoricpubblic = 'RequestPubb') then 'RequestPubb' 
			when  StatoRicPrevPubblic = 'PublishedBurcGuri' and RicPubDPE = '1' and exists (select * from document_ricpubblic where document_ricprevpubblic.id = idricprevpubblic and tipopubblic = 'ALTRI' and statoricpubblic = 'Saved') then 'PreRequestPubbQuotidiani'
			when  StatoRicPrevPubblic = 'RequestPubb' and RicPubDPE = '0'  then 'Compiled'
			when  StatoRicPrevPubblic = 'RequestPubb' and StatoDataPubb='Sended' then 'PublishedQuotidiani'
			when  StatoRicPrevPubblic = 'PreRequestPubb' then 'PreRequestPubbQuotidiani'
			else StatoRicPrevPubblic end
		 else 	'---' end as StatoQuot , 

	case when NumRigheGuri + NumRigheBollo > 0 then 
			case  
			when  StatoRicPrevPubblic = 'PreRequestPubbQuotidiani' and RicPubECO = '1' and StatoDataPubbBG='Sended' then 'PublishedBurcGuri'
			when  StatoRicPrevPubblic = 'PreRequestPubbQuotidiani' and RicPubECO = '1' and StatoDataPubbBG='Saved' then 'PreRequestPubbBurcGuri'
			when  StatoRicPrevPubblic = 'PreRequestPubbQuotidiani' and RicPubECO = '0' then 'Compiled'
			when  StatoRicPrevPubblic = 'PublishedQuotidiani' and RicPubECO = '0'  then 'Compiled'		
			when  StatoRicPrevPubblic = 'PublishedQuotidiani' and RicPubECO = '1' and exists (select * from document_ricpubblic where document_ricprevpubblic.id = idricprevpubblic and tipopubblic = 'BURCGURI' and statoricpubblic = 'RequestPubb') then 'RequestPubb'
			when  StatoRicPrevPubblic = 'PublishedQuotidiani' and RicPubECO = '1' and exists (select * from document_ricpubblic where document_ricprevpubblic.id = idricprevpubblic and tipopubblic = 'BURCGURI' and statoricpubblic = 'Saved') then 'PreRequestPubbBurcGuri'
			when  StatoRicPrevPubblic = 'RequestPubb' and StatoDataPubbBG='Sended' then 'PublishedBurcGuri'
			when  StatoRicPrevPubblic = 'RequestPubb' and RicPubECO = '0'  then 'Compiled'
			when  StatoRicPrevPubblic = 'PreRequestPubb' then 'PreRequestPubbBurcGuri'
			when  StatoRicPrevPubblic = 'AlProvv'  then 'AlEcon'		
			else StatoRicPrevPubblic end
		 else 	'---' end as StatoBG , 

                      id, StatoRicPrevPubblic, PEG, Protocol, Importo, FAX, NumQuotReg, NumQuotNaz, NumCaratteri, RigoLungo, NumRighe, Allegato, UserDirigente, 
                      DataInvio, Pratica, UserProvveditore, DataCompilazione, CAST(Oggetto AS nvarchar(200)) AS Sintesi, Deleted, SUBSTRING(PEG, 23, 2) AS PegCOD, 
                      TipoDocumento, Tipologia
FROM         dbo.Document_RicPrevPubblic
WHERE     (Storico = 0)



GO
