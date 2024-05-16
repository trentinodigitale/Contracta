USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CERTIFICATO_UTENTE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_CERTIFICATO_UTENTE_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @TipoBando varchar(500)	
	declare @IdPfu as INT
	set @errore=''
	SET @id=0

	--controlla se esiste già un documento in bando_gara_edit in lavorazione
		select @id = Id 
			from CTL_DOC with(nolock) 
				where  TipoDoc = 'CERTIFICATO_UTENTE' and StatoFunzionale = 'InLavorazione'

	if  isnull(@id,0)=0
	begin
			
		INSERT into CTL_DOC ( IdPfu,  TipoDoc)
					values
						(@IdUser, 'CERTIFICATO_UTENTE')
						
		set @id=SCOPE_IDENTITY()
	end	

	    
	if @Errore = ''
	begin
		-- rirorna l'id del documento da aprire
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
	
	
END




GO
