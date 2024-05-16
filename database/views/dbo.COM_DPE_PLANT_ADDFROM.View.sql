USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_PLANT_ADDFROM]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[COM_DPE_PLANT_ADDFROM]
AS
/*
	select distinct CodProgramma  AS IndRow ,
		 '35152001#\0000\0000\00' + CodProgramma as plant 
		,'Da Confermare' as StatoComDir 
		,'' as DataAccettazioneDir 

	from peg
*/
select  
		idStrutt as   IndRow 
		,cast ( idaz as varchar ) + '#' + Path as plant  
		,'Da Confermare' as StatoComDir 
		,'' as DataAccettazioneDir 
	from dbo.AZ_STRUTTURA 
		inner join marketplace mp on mpidazimaster  = idaz 

GO
