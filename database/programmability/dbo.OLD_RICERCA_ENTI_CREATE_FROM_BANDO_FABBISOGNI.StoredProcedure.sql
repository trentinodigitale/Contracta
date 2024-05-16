USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RICERCA_ENTI_CREATE_FROM_BANDO_FABBISOGNI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_RICERCA_ENTI_CREATE_FROM_BANDO_FABBISOGNI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;



	declare @Id as INT
	declare @Iddoccopy as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @Jumpcheck as varchar(100)	
	
--	declare @Provenienza as varchar(100)
--	set @Provenienza='DOCUMENTOGENERICO'
--	declare @idDoc as int
--	set @idDoc=102455

	set @Errore = ''
	
	set @Jumpcheck=''	
	

	if @Errore = '' 
	begin
		
		-- se lo stato del bando è diverso da inlavorazione allora apro il documento di ricerca pubblicato
		IF EXISTS (	select id from ctl_doc where id=@idDoc and StatoFunzionale <> 'InLavorazione' )
		BEGIN
			--recupero id della ricerca associata al bando
			select @id=id from ctl_doc where linkedDoc=@idDoc and deleted=0 and TipoDoc in ( 'RICERCA_ENTI' ) and statoFunzionale in ( 'Pubblicato' ) 
		END
		
		ELSE
		
		BEGIN		
			-- cerco una versione precedente del documento se esiste
			set @id = null
			select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RICERCA_ENTI' ) and statoFunzionale in ( 'InLavorazione' ) 
			select @Iddoccopy = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RICERCA_ENTI' ) and statoFunzionale in ( 'Pubblicato' )

			if @id is null and @Iddoccopy is null
			begin
				   -- altrimenti lo creo
					INSERT into CTL_DOC (
						IdPfu,  TipoDoc, 
						LinkedDoc ,jumpcheck )
					VALUES (@IdUser  , 'RICERCA_ENTI'  ,  @idDoc , @Jumpcheck )

					set @id = @@identity	
					
					--Inserisco la riga nella  sezione dei criteri
					 insert into CTL_DOC_VALUE
					 (IdHeader, DSE_ID, Row, DZT_Name, Value)
					  values
					 ( @id, 'CRITERI', 0 , 'Sort', '1')
					  
					
			end
			--se esiste un documento pubblicato faccio una copia di quest'ultimo
			if @Iddoccopy > 0 and  @id is null
			begin
				   -- altrimenti lo creo
					INSERT into CTL_DOC (
						IdPfu,  TipoDoc, 
						LinkedDoc,PrevDoc,Jumpcheck
						 )
					select 
						@IdUser as idpfu , 'RICERCA_ENTI' as TipoDoc ,  
						LinkedDoc, @Iddoccopy ,@Jumpcheck
					
					from CTL_DOC
					where id = @Iddoccopy

					set @id = @@identity


					 insert into CTL_DOC_VALUE
					 (IdHeader, DSE_ID, Row, DZT_Name, Value)
					  select 
					   @id, DSE_ID, Row, DZT_Name, Value
					   from
						CTL_DOC_VALUE
					   where 
						idheader=@Iddoccopy and DSE_ID='CRITERI'
					

			end
		END
	end
	if @Errore = '' and ISNULL(@id,'') <> ''
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		if  ISNULL(@id,'') = '' and @Errore = ''
		BEGIN
			set @Errore='Non e'' stato trovato un documento di Ricerca Enti nel sistema.'
		END
		select 'Errore' as id , @Errore as Errore
	end
END















GO
