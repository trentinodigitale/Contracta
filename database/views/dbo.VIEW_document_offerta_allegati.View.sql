USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_document_offerta_allegati]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_document_offerta_allegati] AS
	select [IdRow], [Idheader], [SectionName], [Attach_Hash], [Attach_attOrderFile], [Attach_Name], [Attach_Description], [Attach_Signers], [Attach_Signers_CF], [RapLegInSigners], [Elaborato], [Obbligatorio], [RichiediFirma], [numeroLotto],
				case when statoFirma = 'SIGN_PENDING' then statoFirma 
					 else NULL 
				end as statoFirma
		from document_offerta_allegati with(nolock) 
GO
