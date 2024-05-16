USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA_CREATE_FROM_OFFERTA] ( @iddoc as int , @iduser as int )
as
BEGIN	
	declare @Id as INT
	declare @IdAZI as INT
	declare @Errore as nvarchar(2000)
	set @Errore=''
	
	set nocount on;
	set @id=0
	--@iddoc è id della richiesta compilazione dgue
	if ISNULL(@iddoc ,0) = 0 
	BEGIN
		set @Errore='Non presente il documento di Richiesta'
	END
	--VERIFICA SE PRESENTE UNA RISPOSTA
	if  @Errore='' and ISNULL(@iddoc ,0) > 0
	BEGIN
		IF NOT EXISTS ( 
						Select * 
							from ctl_doc C
								 inner  join ctl_doc C2 on C2.LinkedDoc=C.id and C2.TipoDoc='RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA' and C2.StatoFunzionale='Inviato'
							where C.id=@iddoc
						
						)
		BEGIN
			set @Errore='Non presente il documento di risposta sulla richiesta'		
		END
		ELSE
		BEGIN
			Select @id=C2.id
							from ctl_doc C
								 inner  join ctl_doc C2 on C2.LinkedDoc=C.id and C2.TipoDoc='RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA' and C2.StatoFunzionale='Inviato'
							where C.id=@iddoc
		END

	END


	if @Errore = ''
	begin
		-- rirorna l'id del doc appena creato
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
	

END



GO
