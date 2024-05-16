USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GARBAGE_COLLECTOR]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD2_GARBAGE_COLLECTOR] ( @chiamante as varchar(100),  @params as nvarchar(max) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- AL MOMENTO QUESTA STORED VIENE CHIAMATA DAL METODO fx_do_purgefiles() nella classe BlobManager presente nel progetto StorageManager degli allegati a 64 bit
	-- VIENE INVOCATA OGNI 15 MINUTI ( CONFIGURABILE DA appsettings.config )
	-- E SERVE PER RIPULIRE LE TABELLE DI LAVORO ( la tabella AfCommon_WorkerQueueEntryModelType dopo 2/3 settimane si "saturava" portando ad un blocco nel caricamento dei file )

	IF @chiamante = 'ATTACH_64'
	BEGIN

		DECLARE @purgeInterval INT -- numero di giorni dopo i quali i record si cancellano
		set @purgeInterval = 1

		INSERT INTO AfCommon_BackupWorkerQueue( [id], [creationdate], [action], [esit], [message], [displayonform], [stacktrace], [operation], [idpfu], [sessionid] )
			select [id], [creationdate], [action], [esit], [message], [displayonform], [stacktrace], [operation], [idpfu], [sessionid]
			from AfCommon_WorkerQueueEntryModelType with(nolock)
			where DATEDIFF(day,creationdate, getdate()) > @purgeInterval

		DELETE FROM AfCommon_WorkerQueueEntryModelType where DATEDIFF(day,creationdate, getdate()) > @purgeInterval
		DELETE FROM AfCommon_MainWorkerQueueEntryModelType where DATEDIFF(day,creationdate, getdate()) > @purgeInterval
		DELETE FROM AfCommon_NotificationsMailQueueModelType where DATEDIFF(day,creationdate, getdate()) > @purgeInterval
		DELETE FROM AfCommon_OperationLogEntryModelType where DATEDIFF(day,creationdate, getdate()) > @purgeInterval
		DELETE FROM AfCommon_ProxyRequestModelType where DATEDIFF(day,creationdate, getdate()) > @purgeInterval

	END

END
GO
