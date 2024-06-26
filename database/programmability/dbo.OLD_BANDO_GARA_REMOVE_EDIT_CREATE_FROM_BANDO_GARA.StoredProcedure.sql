USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_GARA_REMOVE_EDIT_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD_BANDO_GARA_REMOVE_EDIT_CREATE_FROM_BANDO_GARA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @TipoBando varchar(500)	
	declare @IdPfu as INT
	set @Errore=''
	--CONTROLLA SE LA PROCEDURA E' GIà EDITABLE
	IF EXISTS ( select id from DASHBOARD_VIEW_GARE_IN_RETTIFICA where Id=@idDoc and ISNULL(bando_gara_Edit,'no')='no' )
	BEGIN
		set @Errore='La procedura risulta non editabile'
	END

	if @Errore=''
	BEGIN

		--controlla se esiste già un documento in bando_gara_edit in lavorazione
		IF EXISTS ( select id from CTL_DOC with(nolock) 
						where LinkedDoc = @idDoc and TipoDoc = 'BANDO_GARA_EDIT' 
							and StatoFunzionale = 'InLavorazione' 
				   )
		begin
			select @id = Id 
				from CTL_DOC with(nolock) 
					where LinkedDoc = @idDoc and TipoDoc = 'BANDO_GARA_EDIT' 
						and StatoFunzionale = 'InLavorazione'
		end
		else
		begin
				-- genero il record per il nuovo documento
			INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , titolo, LinkedDoc,Fascicolo)
				select 
							@IdUser ,
							'BANDO_GARA_EDIT',
							Azienda ,
							'Senza Titolo', @idDoc, Fascicolo 
						from CTL_DOC 
						WHERE @idDoc = Id
	
			set @id=SCOPE_IDENTITY()
		end	
	END
	    
	if @Errore = ''
	begin
		-- rirorna l'id del documento da aprire
		select @Id as id ,'BANDO_GARA_EDIT' TYPE_TO
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
	
	
END

GO
