USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_LIB_SERVICES_PROT_GEN_FINALIZZA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_CK_LIB_SERVICES_PROT_GEN_FINALIZZA] 
as
begin

	SET NOCOUNT  ON
	declare @ret as nvarchar(max)
	declare @id_s int
	set @id_s = 0	

	set @ret=''

	IF EXISTS ( select id from lib_dictionary where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES' ) 
	BEGIN
		select 
			top 1 @id_s= id
						
			from v_protgen with(nolock) 
					where prot_acquisito = 4 and flag_annullato = 0
			order by id asc

			--CI SONO PROTOCOLLI
			IF @id_s > 0
			BEGIN
				--SE TROVO LO STESSO ID DA INVIARE DEL PASSAGGIO PRECEDENTE CI STA IL PROBLEMA
				IF EXISTS ( select ID from CTL_Counters where name='SRV_PROT_GEN_FINALIZZA' and Counter=@id_s )
				BEGIN
					set @ret='La coda del procotollo durante la Fase ''finalizza'' non sembra smaltirsi, collegarsi e verificare la situazione sul cliente'
				END
				ELSE
				BEGIN
					--CANCELLO LA PRECEDENTE SENTINELLA
					delete CTL_Counters where name='SRV_PROT_GEN_FINALIZZA'
					--INSERISCE LA SENTINELLA
					insert into CTL_Counters (Name,Counter) values ('SRV_PROT_GEN_FINALIZZA',@id_s)
				
				END
			END
	END


	select @ret as sentinella 
end
GO
