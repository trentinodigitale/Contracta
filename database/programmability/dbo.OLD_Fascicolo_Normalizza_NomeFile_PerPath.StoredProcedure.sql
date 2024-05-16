USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Fascicolo_Normalizza_NomeFile_PerPath]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











--Versione=1&data=2022-05-17&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[OLD_Fascicolo_Normalizza_NomeFile_PerPath] ( @IdDoc as int, @Path as nvarchar(1000), @NomeFile as nvarchar(100) )
AS

BEGIN
	
	--metto in una temp idrow con i nuovi nomi file 
	select 
		
		idrow,nomefile,ROW_NUMBER() OVER(ORDER BY idrow) as Prog
		into #temp
	from 	
		Document_Fascicolo_Gara_Allegati 
	where 
		idheader = @IdDoc and path=@Path and nomefile=@NomeFile

	
	--aggiorno i nomi file prendendoli dalla tabella precedente
	update 
		A 
		set NomeFile = replace ( A.NomeFile , dbo.Split_Ext( A.NomeFile,'.',1) ,  dbo.Split_Ext( A.NomeFile,'.',1) + '[' + cast(Prog as varchar(10)) + ']' ) 
		from
			Document_Fascicolo_Gara_Allegati A
				inner join  #temp on #temp.idrow  = A.IdRow
	



END -- Fine stored









GO
