USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Fascicolo_Normalizza_NomeFile]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











--Versione=1&data=2022-05-17&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[Fascicolo_Normalizza_NomeFile] ( @IdDoc as int )
AS

BEGIN
	
	declare @Path as nvarchar(1000)
	declare @NomeFile as nvarchar(1000)

	--metto in uan temp tutti gli allegati che hanno lo stesso nome
	select 
		path, nomefile,count(*) as Num 
			into #t

		from 

			Document_Fascicolo_Gara_Allegati with (nolock)
	
		where 
			idheader = @IdDoc
			group by path, nomefile 
			having count(*) >1
	

	--per ogni nome allegato che si ripete normalizzo il nome aggiungendo il progressivo tra []
	DECLARE crsAllegato CURSOR STATIC FOR 
	
		select path, nomefile from #t 

	OPEN crsAllegato

	FETCH NEXT FROM crsAllegato INTO @Path, @NomeFile
	WHILE @@FETCH_STATUS = 0
	BEGIN
		

		Exec Fascicolo_Normalizza_NomeFile_PerPath @IdDoc, @Path, @NomeFile

		FETCH NEXT FROM crsAllegato INTO @Path, @NomeFile
	END

	CLOSE crsAllegato 
	DEALLOCATE crsAllegato 



END -- Fine stored









GO
