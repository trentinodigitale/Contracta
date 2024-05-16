USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PROFILO_FROM_PROFILO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[PROFILO_FROM_PROFILO] as 
	select 
			id as ID_FROM , Codice as Titolo , aziPRofilo as aziProfili , TipoProfilo as Tipo , Descrizione as DescrizioneEstesa
			,id as LinkedDoc ,  ' Titolo ' as Note
		from Profili_Funzionalita
GO
