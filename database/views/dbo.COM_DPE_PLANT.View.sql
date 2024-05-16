USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_PLANT]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[COM_DPE_PLANT] AS 

/*
select distinct  CodProgramma pegcod,'35152001#\0000\0000\00' + CodProgramma  as plant from peg
*/
select  idStrutt as  pegcod, cast ( idaz as varchar ) + '#' + Path as plant  from dbo.AZ_STRUTTURA 
	inner join marketplace mp on mpidazimaster  = idaz 
	where len( Path ) = 15

GO
