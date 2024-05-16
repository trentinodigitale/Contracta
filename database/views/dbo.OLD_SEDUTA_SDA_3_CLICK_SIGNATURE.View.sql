USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SEDUTA_SDA_3_CLICK_SIGNATURE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_SEDUTA_SDA_3_CLICK_SIGNATURE] AS
	select  docVal.idheader as ID_FROM, 
			doc.id as ID_DOC, 
			doc.TipoDoc + '_INAPPROVE' as TIPO_DOC, 
				
			case when doc.TipoDoc in ('CONFERMA_ISCRIZIONE','CONFERMA_ISCRIZIONE_SDA','CONFERMA_ISCRIZIONE_LAVORI') then 'Conferma_' + cast(doc.id as varchar(50))
					when doc.TipoDoc in ('INTEGRA_ISCRIZIONE','INTEGRA_ISCRIZIONE_SDA') then 'Integra_' + cast(doc.id as varchar(50))
					when doc.TipoDoc in ('SCARTO_ISCRIZIONE','SCARTO_ISCRIZIONE_SDA','SCARTO_ISCRIZIONE_LAVORI') then 'Rifiuto_' + cast(doc.id as varchar(50))
					else 'Documento' + cast(doc.id as varchar(50))
			end as NOME_FILE

		from CTL_DOC doc with (nolock)
			inner join CTL_DOC_Value docVal with (nolock) on doc.id = docVal.Value and docVal.DSE_ID = 'COMUNICAZIONI'
			inner join aziende azi with (nolock) on doc.Destinatario_Azi = azi.IdAzi 

		where doc.deleted = 0  and isnull(doc.SIGN_ATTACH,'') = ''

GO
