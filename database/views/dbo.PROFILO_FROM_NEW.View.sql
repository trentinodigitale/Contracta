USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PROFILO_FROM_NEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[PROFILO_FROM_NEW] as 
	select 
			-1 as ID_FROM , '' as Titolo , '' as aziProfili , '' as Tipo , '' as DescrizioneEstesa
			,0 as LinkedDoc ,  '' as Note
GO
