USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AGGIORNA_CODIFICHE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[MAIL_AGGIORNA_CODIFICHE]
as 
select 
		idpfu as IdDoc,
		lngSuffisso as LNG, 
		dbo.Get_NumeroProdotti_Obsoleti_Per_Ambito( idpfu ) as GrigliaProdotti
	from 

		profiliutente 
		cross join Lingue with(nolock) 
	where pfudeleted=0 and pfuVenditore = 0

	 


GO
