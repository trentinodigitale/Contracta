USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SEDUTA_SDA_VIEW_COMUNICAZIONI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[OLD_SEDUTA_SDA_VIEW_COMUNICAZIONI] as
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

	from CTL_DOC 
		inner join CTL_DOC_Value on id = Value and  DSE_ID = 'COMUNICAZIONI'
		inner join aziende on Destinatario_Azi=IdAzi 
		
	where deleted = 0 





GO
