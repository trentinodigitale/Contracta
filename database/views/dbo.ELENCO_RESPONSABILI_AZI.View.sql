USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ELENCO_RESPONSABILI_AZI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ELENCO_RESPONSABILI_AZI] as 


		select  -- PRENDO Gli utenti responsabili , per l'utente collegato
				8 as DMV_DM_ID ,  
				cast( P1.idpfu as VARCHAR )   as  DMV_Cod   ,
				' ' as DMV_Father      ,
				0 as DMV_Level   ,
				P1.Pfunome as DMV_DescML   ,
				' ' as DMV_Image   ,
				0 as DMV_Sort  ,
				' 'as DMV_CodExt 
				, p.idpfu,
				0 as DMV_Deleted
				, r.attvalue as RUOLO
			from  profiliutente p
				inner join profiliutente P1 on P1.pfuidazi = p.pfuIdAzi
				inner join  PROFILIUTENTEATTRIB r on r.attvalue in ( 'PO' , 'RUP' , 'RUP_PDG' )  	and r.dztnome='UserRole'  and r.idpfu = p1.idpfu

			where p1.pfudeleted = 0 

		




GO
