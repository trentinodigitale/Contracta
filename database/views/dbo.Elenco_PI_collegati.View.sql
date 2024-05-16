USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Elenco_PI_collegati]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[Elenco_PI_collegati] as 

		select  -- PRENDO Gli utenti responsabili , per l'utente collegato
				distinct
				cast( a.attvalue as VARCHAR )   as  Responsabile    ,
				p.idpfu
			from  profiliutente p
				inner join  PROFILIUTENTEATTRIB a  on a.dztnome='pfuResponsabileUtente'  and a.idpfu = p.idpfu and rtrim( isnull( a.attvalue  , '' ) ) <> '' 

			where p.pfudeleted = 0 
GO
