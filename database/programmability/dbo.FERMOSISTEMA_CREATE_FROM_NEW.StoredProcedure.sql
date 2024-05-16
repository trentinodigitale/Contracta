USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[FERMOSISTEMA_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[FERMOSISTEMA_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;


	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @Azienda as int
	set @Errore = ''
	
	
	if @Errore = '' 
	begin
	
		--recupero azienda utente collegato
		select @Azienda = pfuidazi from profiliutente  with (nolock) WHERE idpfu = @IdUser

		-- genero il record per il nuovo documento, cancellato logicamente per evitare che sia visibile se non finalizza le operazioni	
		INSERT into CTL_DOC 
				( IdPfu,  TipoDoc, Azienda ,   statofunzionale)
				values
				( @IdUser  ,  'FERMOSISTEMA' , @Azienda ,  'InLavorazione' )
				
		set @Id = SCOPE_IDENTITY()


		--inserisco la riga nella tabella document_fermo_sistema
		insert into Document_FermoSistema
			( [idHeader], [DataInizio], [DataFine], [DataComunicazione], [DataAnnullamento], [DataSysMsgDA], [DataAvvisoDal], [DataAvvisoAl], [Fermo_Avviso])
			values
			( @Id, null, null, null, null, null, null, null, null)
		
			

		
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
