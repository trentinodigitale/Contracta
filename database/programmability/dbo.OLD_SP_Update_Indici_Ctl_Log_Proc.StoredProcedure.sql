USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_Update_Indici_Ctl_Log_Proc]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_SP_Update_Indici_Ctl_Log_Proc]
as
BEGIN
	
	--cancello indici non utili se esistono
	IF  EXISTS ( SELECT * FROM sys.indexes WHERE name='IX_ctl_log_proc_id' AND object_id = OBJECT_ID('CTL_LOG_PROC') )	
	BEGIN
		DROP INDEX [IX_ctl_log_proc_id] ON [dbo].[CTL_LOG_PROC]
	END

	IF  EXISTS ( SELECT * FROM sys.indexes WHERE name='IX_ASMNT_01' AND object_id = OBJECT_ID('CTL_LOG_PROC') )	
	BEGIN
		DROP INDEX [IX_ASMNT_01] ON [dbo].[CTL_LOG_PROC]
	END

	IF  EXISTS ( SELECT * FROM sys.indexes WHERE name='IX_02' AND object_id = OBJECT_ID('CTL_LOG_PROC') )	
	BEGIN
		DROP INDEX [IX_02] ON [dbo].[CTL_LOG_PROC]
	END

	IF  EXISTS ( SELECT * FROM sys.indexes WHERE name='IX_01' AND object_id = OBJECT_ID('CTL_LOG_PROC') )	
	BEGIN
		DROP INDEX [IX_01] ON [dbo].[CTL_LOG_PROC]
	END

	
	--creo gli indici di piattaforma come sono su IC
	IF NOT EXISTS ( SELECT * FROM sys.indexes WHERE name='IX_ctl_log_proc_id' AND object_id = OBJECT_ID('CTL_LOG_PROC') )
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_ctl_log_proc_id] ON [dbo].[CTL_LOG_PROC]
		(
			[id] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
				
	END

	IF NOT EXISTS ( SELECT * FROM sys.indexes WHERE name='IX_ctl_log_proc_doc_name' AND object_id = OBJECT_ID('CTL_LOG_PROC') )
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_ctl_log_proc_doc_name] ON [dbo].[CTL_LOG_PROC]
		(
			[DOC_NAME] ASC
		)
		INCLUDE ( 	[Parametri]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
				
	END




END
GO
