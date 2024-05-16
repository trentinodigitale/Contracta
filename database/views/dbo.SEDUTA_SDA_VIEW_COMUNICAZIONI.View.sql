USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SEDUTA_SDA_VIEW_COMUNICAZIONI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[SEDUTA_SDA_VIEW_COMUNICAZIONI] as
	select  * , id as ELENCOGrid_ID_DOC , TipoDoc +'_INAPPROVE' as ELENCOGrid_OPEN_DOC_NAME,TipoDoc+'_INAPPROVE' as OPEN_DOC_NAME,

		case	
			when isnull(SIGN_HASH,'') = '' and ISNULL(SIGN_ATTACH,'') = ''
				then 'da_generare'
			when isnull(SIGN_HASH,'') <> '' and ISNULL(SIGN_ATTACH,'') = ''
				then 'da_firmare'
			when isnull(SIGN_HASH,'') <> '' and ISNULL(SIGN_ATTACH,'') <> ''
				then 'firmato'
			else
				'errori'
		end as StatoFirmaRiga

	from CTL_DOC with (nolock)
		inner join CTL_DOC_Value  with (nolock) on id = Value and  DSE_ID = 'COMUNICAZIONI'
		inner join aziende with (nolock) on Destinatario_Azi=IdAzi 
		
	where deleted = 0 





GO
