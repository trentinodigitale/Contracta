USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_LIB_SERVICES_EXEC_NUOVA_GESTIONE_ALLEGATI_RUN]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[OLD2_CK_LIB_SERVICES_EXEC_NUOVA_GESTIONE_ALLEGATI_RUN] 
as
begin

	SET NOCOUNT  ON
	declare @ret as nvarchar(max)
	
	declare @id_s int
	set @id_s = 0

	set @ret=''
	
	--SE ATTIVA LA NUOVA GESTIONE ALLEGATI
	IF EXISTS ( select * from lib_dictionary with(nolock) where dzt_name = 'SYS_ATTIVA_ATTACH_64' and dzt_Valuedef='YES' )
	BEGIN
		IF EXISTS(select 	* from   sysobjects  as t where t.name='AfCommon_WorkerQueueEntryModelType')
		BEGIN
			--select per vedere se il servizio degli allegati è fermo
			IF EXISTS(select * 
						from AfCommon_WorkerQueueEntryModelType with(nolock)
							where datediff( MINUTE, creationdate, getdate()) > 10 
								and esit is null 
					   )
				BEGIN
					set @ret='Nuova gestione degli allegati: ci sono elementi della coda in attesa di essere lavorati da più di 10 minuti. ATTENZIONE E'' UN LIB_SERVICES FITTIZIO, CONTROLLARE IL SERVIZIO DEDICATO AGLI ALLEGATI'
				END
		END
	END		

	
	select @ret as sentinella
END
GO
