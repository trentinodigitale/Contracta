USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CARICA_MACROPRODOTTI_CREATE_FROM_AMBITO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[CARICA_MACROPRODOTTI_CREATE_FROM_AMBITO] ( @IdDoc int  , @idUser int )
AS
BEGIN
	--@IdDoc è ambito

	SET NOCOUNT ON;	

	
	declare @id as int 
	declare @IdAzi as int
	declare @attrib as varchar(500)
	declare @ModelloGriglia as varchar(500)
	declare @DescAmbito as nvarchar(500)

	select @IdAzi = pfuidazi from ProfiliUtente  where IdPfu = @idUser
		
	set @Id=0
		
	--Se e' presente una richiesta salvata dallo stesso utente la riapro
	select @id=id from ctl_doc where tipodoc='CARICA_MACROPRODOTTI' 
		and IdPfu=@idUser and statofunzionale='InLavorazione' and deleted=0 and jumpcheck = cast(@IdDoc as varchar(100))
	
	--recupero desc dal codice ambito
	set @DescAmbito = dbo.Get_DescMulti_Dom('Ambito', cast(@IdDoc as varchar(100)), 'I')
	
	if @id=0
	BEGIN
			
		--inserisco nella ctl_doc		
		insert into CTL_DOC (
					IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,  
						ProtocolloRiferimento,  Fascicolo, StatoFunzionale, jumpcheck)
			values	
					( @idUser, 'CARICA_MACROPRODOTTI', 'Saved' , 'Carica Macroprodotti Ambito "' + @DescAmbito  + '"', '' , @IdAzi 
						,''  , '' , 'InLavorazione',  @IdDoc)
						

		set @Id = SCOPE_IDENTITY()		

		--'ELENCO_CODIFICHE_META_PRODOTTI_' + ambito + '_MOD_Griglia'
		--a seconda dell'ambito metto nella ctl_doc_section_model il modello per la griglia
		set @ModelloGriglia = 'ELENCO_CODIFICHE_META_PRODOTTI_' + cast(@IdDoc as varchar(100)) + '_MOD_Griglia'
		
		
		insert into CTL_DOC_SECTION_MODEL
			(IdHeader , dse_id, MOD_Name )
			values
				(@Id , 'PRODOTTI', @ModelloGriglia )
		
		

	
	END
			
	

	
	--if @Errore=''
		-- rirorna id odc creato
	select @Id as id , '' as Errore
	--else
	--begin
		-- rirorna l'errore
	--	select 'Errore' as id , @Errore as Errore
	--end
		
	
	

END


GO
