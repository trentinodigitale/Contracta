USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_NOTIER_LISTA_MDN]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_NOTIER_LISTA_MDN] AS
		SELECT  doc.id as iddoc,
				'I' as LNG,
				a.aziRagioneSociale,
				CONVERT(VARCHAR(10),doc.DataInvio,103) as DataInvioVisual,
				doc.Titolo,
				doc.Note as descrizioneErrore,
				case TipoDoc 
					when  'NOTIER_DDT'     then 'DDT' 
					when  'NOTIER_ORDINE'  then 'ORDINE' 
					when  'NOTIER_INVOICE' then 'FATTURA' 
					when  'NOTIER_CREDIT_NOTE' then 'NOTA DI CREDITO' 
					else 'PEPPOL' 
				end as TipoDocumento
		FROM CTL_DOC doc with(nolock)
				inner join aziende a with(nolock) on a.idazi = doc.Azienda
		WHERE doc.TipoDoc IN ( 'NOTIER_DDT', 'NOTIER_ORDINE', 'NOTIER_INVOICE', 'NOTIER_CREDIT_NOTE' )
GO
