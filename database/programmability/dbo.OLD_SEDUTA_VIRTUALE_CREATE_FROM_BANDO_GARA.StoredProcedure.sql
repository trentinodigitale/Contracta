USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SEDUTA_VIRTUALE_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_SEDUTA_VIRTUALE_CREATE_FROM_BANDO_GARA]( @idOrigin as int, @idPfu as int = -20 ) 
AS
BEGIN
	SET NOCOUNT ON
	
	declare @Id as INT
	declare @pfuIdAzi as INT
	declare @Errore as nvarchar(2000)
	SET @Errore=''

	select  @pfuIdAzi=[pfuIdAzi] FROM [ProfiliUtente] where IdPfu = @idPfu

	-- controllo se esiste una modifica in corso
	select @Id=id from CTL_DOC where linkedDoc = @idOrigin and Tipodoc='SEDUTA_VIRTUALE' and StatoFunzionale = 'InLavorazione' and deleted=0 and Azienda=@pfuIdAzi
	
	if ( @id IS NULL or @id=0 )
	begin 

		insert into CTL_DOC ( idpfu, Titolo,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,protocolloRiferimento,idPfuInCharge, Azienda, Body)
			select @idPfu, 'Seduta Virtuale', 'SEDUTA_VIRTUALE', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted
					,Fascicolo, @idOrigin, Protocollo,@idPfu, @pfuIdAzi, Body from CTL_DOC where id=@idOrigin

	

		set @Id = SCOPE_IDENTITY()
	end

	-- se è presente la seduta virtuale per l'OE
	if isnull ( @id , 0 ) > 0 
	begin

		-- recupero la PDA associata alla gara per avere il riferimento della chat room
		declare @idRoom int
		select @idRoom = id from CTL_DOC with(nolock ) where tipodoc = 'PDA_MICROLOTTI' and linkeddoc = @idOrigin and deleted = 0 
		
		exec CHAT_ROOM_ENTRY  @idPfu , @idRoom 

	end


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
