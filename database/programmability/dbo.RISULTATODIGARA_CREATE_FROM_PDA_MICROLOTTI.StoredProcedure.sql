USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RISULTATODIGARA_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RISULTATODIGARA_CREATE_FROM_PDA_MICROLOTTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT

	declare @IdMsgBando as int
	declare @body as nvarchar(4000)
	declare @tipobando as varchar(100)
	declare @GuidDoc as varchar(500)
	declare @JumpCheck as varchar(100) 
	
	--set @idDoc=3572
	
	--recupero idmsg del bando
	select @IdMsgBando=linkeddoc ,@body =body,@JumpCheck=JumpCheck from ctl_doc where tipodoc='PDA_MICROLOTTI' and id=@idDoc 		

	if 	@JumpCheck is null
		set @JumpCheck=''
	else
		set @IdMsgBando=@IdMsgBando*-1

	-- verifica l'esistenza di un documento salvato
	set @id = 0
	select @id=ID  from Document_RisultatoDiGara where ID_MSG_BANDO =@IdMsgBando and isnull(Tipodoc_src,'')=@JumpCheck	
	
	if isnull( @id , 0 ) = 0
	begin
		
		--solo per risultati legati a documenti generici
		if @JumpCheck=''
		begin
			--se non è un invito associo il risultato di gara al doc 168 pubblico(-10)
			select @tipobando=Tipobando,@GuidDoc=IdDoc from tab_messaggi_fields where idmsg=@IdMsgBando
			
			if @tipobando <> '3' 
			begin	
				select 
					@IdMsgBando=Idmsg 
				from 
					tab_messaggi_fields, tab_utenti_messaggi 
				where 
					Iddoc=@GuidDoc
					and idmsg=umidmsg
					and umidpfu=-10
					and umstato = 0
					and iType =55	
					and iSubType =168
			end
		end

		
		---Insert nella document_chiarimenti per creare la nuova risposta
		insert into Document_RisultatoDiGara ( ID_MSG_BANDO , Oggetto ,Tipodoc_src    )
										values ( @IdMsgBando , @body , @JumpCheck)
			
		set @Id = @@identity	

   end
	--print @IdMsgBando
	
	-- ritorna l'id della nuovo quesito appena creato
	select @Id as id

END

GO
