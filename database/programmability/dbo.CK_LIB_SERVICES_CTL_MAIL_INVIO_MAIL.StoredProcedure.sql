USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_LIB_SERVICES_CTL_MAIL_INVIO_MAIL]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[CK_LIB_SERVICES_CTL_MAIL_INVIO_MAIL] 
as
begin

	SET NOCOUNT  ON
	declare @ret as nvarchar(max)
	
	declare @id_s int
	set @id_s = 0

	set @ret=''
	
	select 
		top 1 @id_s= id 
		 from ctl_mail where state='0'

	
	--CI SONO MAIL DA FARE
	IF @id_s > 0
	BEGIN
		--SE TROVO LO STESSO ID DA INVIARE DEL PASSAGGIO PRECEDENTE CI STA IL PROBLEMA
		IF EXISTS ( select ID from CTL_Counters where name='SRV_CTL_MAIL_INVIO_MAIL' and Counter=@id_s )
		BEGIN
			set @ret='La coda nella ctl_mail per generare le mail non sembra smaltirsi, collegarsi e verificare la situazione sul cliente'
		END
		ELSE
		BEGIN
			--CANCELLO LA PRECEDENTE SENTINELLA
			delete CTL_Counters where name='SRV_CTL_MAIL_INVIO_MAIL'
			--INSERISCE LA SENTINELLA
			insert into CTL_Counters (Name,Counter) values ('SRV_CTL_MAIL_INVIO_MAIL',@id_s)
				
		END
	END
	
	select @ret as sentinella 
end
GO
