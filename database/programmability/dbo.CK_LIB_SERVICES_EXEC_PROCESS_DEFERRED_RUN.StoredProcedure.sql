USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_LIB_SERVICES_EXEC_PROCESS_DEFERRED_RUN]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[CK_LIB_SERVICES_EXEC_PROCESS_DEFERRED_RUN] 
as
begin

	SET NOCOUNT  ON
	declare @ret as nvarchar(max)
	
	declare @id_s int
	set @id_s = 0

	set @ret=''
	
	select 
		top 1 @id_s= id 

		from CTL_Schedule_Process A with(nolock)
			left outer join CTL_Relations B with(nolock) on B.REL_Type = 'PRIORITA_CTL_SCHEDULE_PROCESS' and B.REL_ValueInput = A.DPR_DOC_ID + '-' + A.DPR_ID
		where state='0' 
		and getdate() >= isnull( DataRequestExec , '2000-12-12T00:00:00' )		
	ORDER BY cast( isnull( REL_ValueOutput , '0' ) as int )  desc , id asc	

	
	--CI SONO PROCESSI SCHEDULATI
	IF @id_s > 0
	BEGIN
		--SE TROVO LO STESSO ID DA INVIARE DEL PASSAGGIO PRECEDENTE CI STA IL PROBLEMA
		IF EXISTS ( select ID from CTL_Counters where name='SRV_EXEC_PROCESS_DEFERRED_RUN' and Counter=@id_s )
		BEGIN
			set @ret='La coda dei processi differiti non sembra smaltirsi, collegarsi e verificare la situazione sul cliente'
		END
		ELSE
		BEGIN
			--CANCELLO LA PRECEDENTE SENTINELLA
			delete CTL_Counters where name='SRV_EXEC_PROCESS_DEFERRED_RUN'
			--INSERISCE LA SENTINELLA
			insert into CTL_Counters (Name,Counter) values ('SRV_EXEC_PROCESS_DEFERRED_RUN',@id_s)
				
		END
	END
	
	select @ret as sentinella 
end
GO
