USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ELENCO_RESPONSABILI]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[ELENCO_RESPONSABILI] as 

select * 
	from (
		select  -- prendo l'utetne se PO
				8 as DMV_DM_ID ,  
				cast( p.Idpfu as VARCHAR )   as  DMV_Cod   ,
				' ' as DMV_Father      ,
				0 as DMV_Level   ,
				Pfunome as DMV_DescML   ,
				' ' as DMV_Image   ,
				0 as DMV_Sort  ,
				' 'as DMV_CodExt , 
				p.idpfu ,
				0 as DMV_Deleted
				, attvalue as RUOLO

			from  profiliutente p
				inner join  PROFILIUTENTEATTRIB a on attvalue in ( 'PO' , 'RUP' , 'RUP_PDG' )  	and dztnome='UserRole'  and a.idpfu = p.idpfu
			where pfudeleted = 0 

		union 

		select  -- PRENDO Gli utenti responsabili , per l'utente collegato
				8 as DMV_DM_ID ,  
				cast( a.attvalue as VARCHAR )   as  DMV_Cod   ,
				' ' as DMV_Father      ,
				0 as DMV_Level   ,
				P1.Pfunome as DMV_DescML   ,
				' ' as DMV_Image   ,
				0 as DMV_Sort  ,
				' 'as DMV_CodExt , p.idpfu,
				0 as DMV_Deleted
				, r.attvalue as RUOLO
			from  profiliutente p
				inner join  PROFILIUTENTEATTRIB a  on a.dztnome='pfuResponsabileUtente'  and a.idpfu = p.idpfu
				inner join profiliutente P1 on P1.idpfu=a.attvalue
				inner join  PROFILIUTENTEATTRIB r on r.attvalue in ( 'PO' , 'RUP' , 'RUP_PDG' )  	and r.dztnome='UserRole'  and r.idpfu = p1.idpfu

			where p.pfudeleted = 0 



		
		) as a  



GO
