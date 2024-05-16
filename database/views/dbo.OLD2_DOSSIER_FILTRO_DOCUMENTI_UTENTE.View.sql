USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DOSSIER_FILTRO_DOCUMENTI_UTENTE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD2_DOSSIER_FILTRO_DOCUMENTI_UTENTE] as 
select idpfu , IdDcm  from Document 
					cross join profiliutente
	where 
(
   CHARINDEX ( substring( pfuProfili , 1 , 1 )  , dcmDetail ) > 0 
or CHARINDEX ( substring( pfuProfili , 2 , 1 )  , dcmDetail ) > 0 
or CHARINDEX ( substring( pfuProfili , 3 , 1 )  , dcmDetail ) > 0 
or CHARINDEX ( substring( pfuProfili , 4 , 1 )  , dcmDetail ) > 0 
)
GO
