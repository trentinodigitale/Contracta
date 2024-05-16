USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA_CREATE_FROM_RICHIESTA_COMPILAZIONE_DGUE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA_CREATE_FROM_RICHIESTA_COMPILAZIONE_DGUE] ( @iddoc as int , @iduser as int )
as
BEGIN	
	declare @Id as INT
	declare @IdAZI as INT
	declare @Errore as nvarchar(2000)
	set @Errore=''
	
	set nocount on;

	set @id=0
	--- se il documento esiste riapre quello corrente se l’idpfu incharge coincide 
	select @Id = id 
		from CTL_DOC 
		where TipoDoc = 'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA' and Deleted = 0 and LinkedDoc=@iddoc 
		
	
	--se esiste verifica che sia in charge all'untente collegato
	if @Id > 0
	begin
		IF NOT EXISTS ( select * from ctl_doc where id=@Id and idPfuInCharge=@iduser )
		BEGIN
			set @Errore = 'Per aprire la risposta devi essere utente in carico' 
		END
		
	end
	--,Avvalimento,Consorzio 
	--genera per l’azienda indicata un documento di RICHIESTA_COMPILAZIONE_DGUE
	if @Id = 0 and @Errore=''
	BEGIN
		select @IdAZI=pfuidazi from ProfiliUtente where idpfu=@iduser
		-- CREO IL DOCUMENTO
		INSERT into CTL_DOC (IdPfu,idPfuInCharge,LinkedDoc, titolo, TipoDoc,Destinatario_Azi ,Body,JumpCheck,StatoFunzionale,Azienda,Fascicolo,ProtocolloRiferimento,Destinatario_User)
			select  @IdUser,@IdUser,@iddoc,Replace(titolo,'Richiesta','Risposta'),'RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA' ,Azienda,body,JumpCheck,'InLavorazione',@IdAZI,Fascicolo,ProtocolloRiferimento,IdPfu
				from ctl_doc
				where id=@iddoc

		set @Id = SCOPE_IDENTITY()	

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
