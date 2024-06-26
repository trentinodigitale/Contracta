USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ISTANZA_AlboOperaEco_qf_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_ISTANZA_AlboOperaEco_qf_VIEW] as

	select   d.*,DSE_ID='DISPLAY_FIRMA',d.id as idheader
			,SIGN_ATTACH as Attach,d.azienda as idazi, v.idquest , isnull(yyy.IsTestata,0) as istestata

		from CTL_DOC_VIEW d

			left outer join (
								select idazienda,max(idquest) as idquest
									from Document_EMAS
										where  statoquest='Sended' and deleted=0
											group by idazienda
							) v on v.IdAzienda = d.azienda

			left outer join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi yyy on yyy.idHeader = d.id





GO
