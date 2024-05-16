USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AZI_VIEW_DOCUMENTAZIONE_UPD]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_AZI_VIEW_DOCUMENTAZIONE_UPD] as
--select  
--	 Id,
--	 IdPfu,
--	 A.TipoDoc,
--	 Data,
--	 Azienda as idazi,
--	 Protocollo,
--	 A.TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,
--	 id AS DETTAGLIGrid_ID_DOC,Descrizione,
--	 Allegato,
--	 Data as aziDatacreazione,
--	 DataEmissione,
--	 StatoDocumentazione,
--	 A.deleted,
--	 A.idChainDocStory
 
--from CTL_DOC
----inner join dbo.CTL_DOC_ALLEGATI on idHeader=id
--inner join Aziende AZ on Azienda=AZ.IdAzi
--inner join dbo.Aziende_Documentazione A on A.idazi= AZ.IdAzi and A.deleted=0 ---and CTL_DOC.Id=A.LinkedDoc
--where CTL_DOC.TipoDoc='AZI_UPD_DOCUMENTAZIONE' and A.Deleted=0 and CTL_DOC.Deleted=0


select  
	 IdRow as Id,
	 --IdPfu,
	 A.TipoDoc,
	 DataInserimento,
	 idazi,
	-- Protocollo,
	 A.TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,
	 IdRow AS DETTAGLIGrid_ID_DOC,
	 Descrizione,
	 A.Allegato,
	 DataInserimento as aziDatacreazione,
	 DataInserimento as Data,
	 DataEmissione,
	 StatoDocumentazione,
	 A.deleted,
	 idChainDocStory,
	 DA.Scadenza,
	 case when Scadenza='1' 
		  then DATEADD(month,DA.NumMesiVal,DataEmissione)
		  else NULLIF ( a.DataScadenza  , '1900-01-01 00:00:00.000' )
	end as DataScadenza
 
from Aziende_Documentazione A with(nolock)
	left join ctl_doc C with(nolock) on A.AnagDoc=C.Titolo and C.TipoDoc='ANAG_DOCUMENTAZIONE' and C.Deleted=0
	left join Document_Anag_documentazione  DA with(nolock) on DA.idheader=C.id
where A.Deleted=0 


GO
