USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DocumentazioneForn]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_DocumentazioneForn] as

		select [Document_Documentazione].Id, Owner, Name, DataCreazione, Protocollo, StatoDoc, DataScadenza, Nome, 
				Note, TipoDocumentazione, VisibilitaDoc, Deleted,
				'Documentazione' as open_doc_name,h.idpfu,
				case when l.DOC_NAME is not null then '0' else '1'end as bRead 

					from [dbo].[Document_Documentazione] with(NOLOCK)

						cross join ProfiliUtente h with(NOLOCK)

						left outer join CTL_DOC_READ as l  with(NOLOCK) on 
											h.idpfu=l.idpfu 
											and [Document_Documentazione].id=l.id_Doc 
											and l.DOC_NAME = 'Documentazione'

							where deleted=0 
									and VisibilitaDoc = 'Fornitori' 
									and StatoDoc = 'Sended'
									and h.pfuVenditore = 1 
									and h.pfuAcquirente = 0



GO
