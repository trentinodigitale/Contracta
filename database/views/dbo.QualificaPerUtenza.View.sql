USE [AFLink_TND]
GO
/****** Object:  View [dbo].[QualificaPerUtenza]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[QualificaPerUtenza] as 
	select f.DMV_Cod , idPfu 
		from dbo.LIB_DomainValues f with(nolock)
			inner join aziende a with(nolock) on charindex( substring( DMV_Father , 1 ,1 ) , aziprofili , 0 ) > 0 or ( charindex( substring( DMV_Father , 2 ,1 ) , aziprofili , 0 ) > 0 and len(  substring( DMV_Father , 2 ,1 ) ) <> 0 )
			inner join profiliutente p with(nolock) on  a.idazi = p.pfuidazi
		where DMV_DM_ID = 'pfuRuoloAziendale'
			--and DMV_COD not in ('LEGALE RAPPRESENTANTE','LEGALE RAPPRESENTANTE DI SOCIETA')




GO
