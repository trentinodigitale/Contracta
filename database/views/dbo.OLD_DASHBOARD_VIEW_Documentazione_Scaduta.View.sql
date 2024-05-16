USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_Documentazione_Scaduta]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_Documentazione_Scaduta] as

				select  
					 IdRow as Id,
					 --IdPfu,
					 a.TipoDoc,
					 DataInserimento,
					 a.idazi,
					-- Protocollo,
					 a.TipoDoc AS DETTAGLIGrid_OPEN_DOC_NAME,
					 IdRow AS DETTAGLIGrid_ID_DOC,
					 --Descrizione,
					case isnull(cast(c.body as varchar(255)),'') when '' then a.Descrizione else c.body end as Descrizione ,
					 A.Allegato,
					 DataInserimento as aziDatacreazione,
					 DataInserimento as Data,
					 DataEmissione,
					 a.StatoDocumentazione,
					 A.deleted,
					 idChainDocStory,
					 DA.Scadenza,
					 c.titolo,
					-- case when Scadenza='1' 
					--	  then DATEADD(month,DA.NumMesiVal,DataEmissione)
					--	  else NULLIF ( a.DataScadenza  , '1900-01-01 00:00:00.000' )
					--end as DataScadenza

					case when a.DataScadenza IS Not null
						  then a.DataScadenza
						  else  '1900-01-01 00:00:00.000' 
					end as DataScadenza,

					a.DataScadenza as DataScadenza2,
					aziRagioneSociale ,
					aziPartitaIVA ,
					ProfiliUtente.idpfu,
					a.idazi as idazi2
 
				from Aziende_Documentazione A with (nolock)

						left join ctl_doc C with (nolock) on A.AnagDoc=C.Titolo and C.TipoDoc='ANAG_DOCUMENTAZIONE' and C.Deleted=0
						left join Document_Anag_documentazione  DA with (nolock) on DA.idheader=C.id
						inner join aziende azi with (nolock) on azi.idazi = a.idazi
						cross join ProfiliUtente  

				where A.Deleted=0 and C.Deleted = 0 and C.StatoFunzionale = 'Pubblicato'
						and pfuidazi=35152002
						and a.DataScadenza is not null
						and a.DataScadenza < getdate()







GO
