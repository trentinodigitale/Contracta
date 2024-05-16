USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_QualificaPerUtenza]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_QualificaPerUtenza] as 
select f.DMV_Cod , idPfu 
	from dbo.LIB_DomainValues f
		inner join aziende a on charindex( DMV_Father , aziprofili , 0 ) > 0 
		inner join profiliutente p on  a.idazi = p.pfuidazi
	where DMV_DM_ID = 'pfuRuoloAziendale'
			--and DMV_COD not in ('LEGALE RAPPRESENTANTE','LEGALE RAPPRESENTANTE DI SOCIETA')



GO
