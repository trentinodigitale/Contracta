USE [AFLink_TND]
GO
/****** Object:  View [dbo].[STRUTTURA_APPARTENENZA_ADD_IPA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[STRUTTURA_APPARTENENZA_ADD_IPA]
as
	select plant as indrow,Cod_Uni_OU as CodiceIPA  
		from 
			AZIENDE_CODICI_IPA with (nolock)
		where 
			isnull(Cod_Uni_OU,'')<>'' and isnull(plant,'')<>''
GO
