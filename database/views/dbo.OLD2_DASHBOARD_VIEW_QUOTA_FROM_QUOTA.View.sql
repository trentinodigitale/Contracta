USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_QUOTA_FROM_QUOTA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_QUOTA_FROM_QUOTA] AS
SELECT     
	 C.id,
	 C.IdPfu,
	 C.TipoDoc,
	-- C.StatoDoc,
	 --C.DataInvio,
	-- C.Protocollo,
	 --C.PrevDoc,
	 C.id as PrevDoc,
	 C.Deleted,
	 C.Titolo,
	 DC.Doc_Name as BodyContratto,
	 C.Azienda,
	 DC.Protocol as ProtocolloRiferimento,
	 C.LinkedDoc,
	 C.StatoFunzionale,
	 C.ID as ID_FROM,
	 C.ID as IdHeader,
	 Descrizione,
	 CTL_DOC_ALLEGATI.Allegato,
	 Document_Convenzione_Quote.importo,
	 C.Body,
	 DC.NumOrd,
	 DC.Total,
	 --Document_Convenzione_Quote.Value_tec__Azi,
	 C.Azienda as Value_tec__Azi,
	(DC.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote ,
	 Document_Convenzione_Quote.importo as Importo_Allocato_Prec

FROM ctl_doc  C
		inner join Aziende on Azienda=IdAzi
		inner join document_convenzione DC on C.LinkedDoc=DC.ID
		inner join Document_Convenzione_Quote on Document_Convenzione_Quote.idHeader=C.id
		left join CTL_DOC_ALLEGATI on CTL_DOC_ALLEGATI.idHeader=C.id

		left join (
			select  ctl_doc.linkeddoc, isnull(sum(importo),0) as totQ 
				from Document_Convenzione_Quote,ctl_doc 
					where tipodoc='QUOTA' and idheader=id and statodoc='Sended' 
				group by linkeddoc ) S on S.linkeddoc= C.LinkedDoc

		where TipoDoc='QUOTA'


GO
