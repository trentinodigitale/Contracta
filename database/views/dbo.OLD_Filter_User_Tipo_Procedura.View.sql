USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Filter_User_Tipo_Procedura]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_Filter_User_Tipo_Procedura] as 

	select idpfu , tdrcodice  
	from tipidatirange
		inner join dizionarioattributi on dztidtid=tdridtid 
		cross join profiliutente --on 
						--(substring( pfufunzionalita , 4 , 1 ) = '1' and tdrcodice = '15476' )
						--or
						--(substring( pfufunzionalita , 22, 1 ) = '1' and tdrcodice = '15477' )
						--or
						--(substring( pfufunzionalita , 42, 1 ) = '1' and tdrcodice = '15478' )

	where dztnome='ProceduraGara'
		and tdrdeleted=0 
		and tdrcodice in ( '15478','15477','15476')



GO
