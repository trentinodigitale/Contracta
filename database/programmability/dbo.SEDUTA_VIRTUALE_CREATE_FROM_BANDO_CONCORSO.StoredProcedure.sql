USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SEDUTA_VIRTUALE_CREATE_FROM_BANDO_CONCORSO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[SEDUTA_VIRTUALE_CREATE_FROM_BANDO_CONCORSO]( @idOrigin as int, @idPfu as int = -20 ) 
AS
BEGIN
	SET NOCOUNT ON
	
	declare @Id as INT
	declare @pfuIdAzi as INT
	declare @Errore as nvarchar(2000)
	
	
	SET @Errore=''


	--controllo se seduta virtuale in corso
	CREATE TABLE #TempCheck(
						[bp_Read] [varchar](200) collate DATABASE_DEFAULT NULL,
						[bp_write] [varchar](200) collate DATABASE_DEFAULT NULL
					) 

	insert into #TempCheck
	EXEC SEDUTA_VIRTUALE_VERIFICA_ACCESSO @idPfu, @idOrigin


	if exists (select * from #TempCheck)
	begin
		select  @pfuIdAzi=[pfuIdAzi] FROM [ProfiliUtente] where IdPfu = @idPfu

		-- controllo se esiste una modifica in corso
		select @Id=id from CTL_DOC where linkedDoc = @idOrigin and Tipodoc='SEDUTA_VIRTUALE_CONCORSO' and StatoFunzionale = 'InLavorazione' and deleted=0 and Azienda=@pfuIdAzi
	
		if ( @id IS NULL or @id=0 )
		begin 

			insert into CTL_DOC ( idpfu, Titolo,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,protocolloRiferimento,idPfuInCharge, Azienda, Body)
				select @idPfu, 'Seduta Virtuale Concorso', 'SEDUTA_VIRTUALE_CONCORSO', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted
						,Fascicolo, @idOrigin, Protocollo,@idPfu, @pfuIdAzi, Body from CTL_DOC where id=@idOrigin

	

			set @Id = SCOPE_IDENTITY()
		end

		-- se è presente la seduta virtuale per l'OE
		if isnull ( @id , 0 ) > 0 
		begin

			-- recupero la PDA associata alla gara per avere il riferimento della chat room
			declare @idRoom int
			select @idRoom = id from CTL_DOC with(nolock ) where tipodoc = 'PDA_CONCORSO' and linkeddoc = @idOrigin and deleted = 0 
		
			exec CHAT_ROOM_ENTRY  @idPfu , @idRoom 

			exec CHAT_ROOM_IN_OUT_USER @idPfu , @idRoom, 'IN'

		end

	end
	else
	begin
		SET @Errore='Impossibile Partecipare Seduta Virtuale Chiusa'
	end

	drop table #TempCheck	

	if @Errore = ''
    begin
	   -- rirorna l'id della nuova comunicazione appena creata
	   select @Id as id
		
    end
    else
    begin
	   -- rirorna l'errore
	   select 'Errore' as id , @Errore as Errore
    end
	   

END


GO
