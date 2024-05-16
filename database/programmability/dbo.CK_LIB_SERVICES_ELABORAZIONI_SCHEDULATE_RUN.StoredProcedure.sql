USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_LIB_SERVICES_ELABORAZIONI_SCHEDULATE_RUN]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CK_LIB_SERVICES_ELABORAZIONI_SCHEDULATE_RUN] 
as
begin

	SET NOCOUNT  ON
	declare @ret as nvarchar(max)	
	declare @dataUltimaElaborazione as datetime

	declare @id_s int
	set @id_s = 0

	set @ret=''
	
	select 
		top 1 @id_s= id ,@dataUltimaElaborazione=dataUltimaElaborazione
		from CTL_ELABORAZIONI_SCHEDULATE with (nolock)
			where deleted=0 and getdate() >= DataInizio
			ORDER BY dataUltimaElaborazione 

	
	--CI SONO PROCESSI SCHEDULATI
	IF @id_s > 0
	BEGIN
		--SE TROVO LO STESSO ID DEL PASSAGGIO PRECEDENTE CI STA IL PROBLEMA
		IF EXISTS ( select ID from CTL_Counters where name='SRV_ELABORAZIONI_SCHEDULATE_RUN' and Counter=@id_s and Altro=CONVERT(varchar(19),@dataUltimaElaborazione,121) )
		BEGIN
			set @ret='La coda delle elaborazioni schedulate non sembra smaltirsi, collegarsi e verificare la situazione sul cliente'
		END
		ELSE
		BEGIN
			--CANCELLO LA PRECEDENTE SENTINELLA
			delete CTL_Counters where name='SRV_ELABORAZIONI_SCHEDULATE_RUN'
			--INSERISCE LA SENTINELLA
			insert into CTL_Counters (Name,Counter,Altro) values ('SRV_ELABORAZIONI_SCHEDULATE_RUN',@id_s,CONVERT(varchar(19),@dataUltimaElaborazione,121))
				
		END
	END
	
	select @ret as sentinella 
end
GO
