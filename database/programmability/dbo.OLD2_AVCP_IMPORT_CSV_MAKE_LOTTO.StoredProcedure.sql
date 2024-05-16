USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AVCP_IMPORT_CSV_MAKE_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD2_AVCP_IMPORT_CSV_MAKE_LOTTO] 
	( @Idrow int , @idDoc int , @idDocLottoPrev int output , @VersioneLotto int output, @FascicoloLotto varchar(50) output , @LinkedDocLotto int output )
--( @DOC varchar(30) , @Plant VARCHAR(200)  , @Prot as varchar(50) output )
--RETURNS VARCHAR(200)
AS
BEGIN 
 	set nocount on

	declare @Protocollo varchar(50)
	declare @newid int
	declare @IdRiga int
	declare @FineCiclo int 
	declare @Tot float
	declare @ImportoAggiudicazione  float
	declare @DataInizio datetime
	declare @Datafine   datetime
	declare @ImportoSommeLiquidate float
	declare @LastDatafine datetime
	declare @Cig nvarchar(200)

	set @FineCiclo = 1
	set @Tot = 0
	set @LastDatafine = null
	
	EXEC ctl_GetNewProtocol 'ANAC' , '', @Protocollo output

	------------------------------
	-- inserisco il nuovo lotto
	------------------------------
	INSERT INTO ctl_doc (	tipodoc, statoFunzionale, data , datainvio , PrevDoc
				,Fascicolo        , Versione       , LinkedDoc,		   idpfu , Azienda , Protocollo)
		select 'AVCP_LOTTO' , 'Pubblicato' , getdate() , getdate() , isnull( @idDocLottoPrev , 0 ) 
				, @FascicoloLotto , @VersioneLotto , @LinkedDocLotto , idpfu , Azienda  ,@Protocollo
			from CTL_DOC with(nolock) where id = @idDoc

	SET @newid = SCOPE_IDENTITY()

	--inserisce il riferimento al nuovo lotto nella table #TEMP_LOTTI_NEW per fare i controlli successivamente
	insert into #TEMP_LOTTI_NEW ( Id_Lotto ) values ( @newid)

	------------------------------
	-- se non esisteva una versione precedente allora la generiamo ed aggiorniamo
	------------------------------
	if isnull( @VersioneLotto , 0 ) = 0 
	begin
        set @VersioneLotto = @newid
        SET @FascicoloLotto = 'AVCP-' + cast(@newid as varchar ) 

		UPDATE ctl_doc SET  versione = @VersioneLotto , Fascicolo = @FascicoloLotto
			WHERE id = @newid 		
	end 
	

	------------------------------
	-- carico gli importi
	------------------------------
	declare CurImportCSV_importi Cursor static for  
		select Idrow, Cig,  ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate
			from document_AVCP_Import_CSV with(nolock)
			where idheader = @idDoc and isnull( cast( warning as varchar (4000)), '' ) = '' and Idrow >= @Idrow
			order by Idrow
	
	open CurImportCSV_importi

	-- prendo il primo record
	FETCH NEXT FROM CurImportCSV_importi  INTO @idRiga, @Cig, @ImportoAggiudicazione, @DataInizio, @Datafine, @ImportoSommeLiquidate

	-- ciclo su tutti  i record finche ci sono
	WHILE @@FETCH_STATUS = 0 and @FineCiclo = 1
	BEGIN
	
		if ( @DataInizio is not null or @Datafine is not null or  @ImportoSommeLiquidate is not null ) 
			and ( @IdRiga = @Idrow or isnull( @Cig , '' ) = '' )
		begin

			insert into document_AVCP_Importi ( IdHeader, DataInizio, DataFine, DataLiquidazione, Importo )
				values( @newid , @DataInizio, @Datafine , @Datafine , @ImportoSommeLiquidate ) 
				
			set @Tot = @Tot + isnull( @ImportoSommeLiquidate , 0 ) 
			set @LastDatafine = @Datafine
				
		end
		else
			set @FineCiclo = 0

		-- fine ciclo
		FETCH NEXT FROM CurImportCSV_importi  INTO @idRiga, @Cig, @ImportoAggiudicazione, @DataInizio, @Datafine, @ImportoSommeLiquidate

	END
	 
	CLOSE CurImportCSV_importi
	DEALLOCATE CurImportCSV_importi


	
	------------------------------
	-- carichiamo document_AVCP_lotti
	------------------------------
	INSERT INTO Document_AVCP_Lotti( idheader, Anno, Cig, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate, Oggetto, DataPubblicazione )
		select @newid, Anno, Cig, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, @LastDatafine, @Tot, Oggetto, DataPubblicazione 	
			from document_AVCP_Import_CSV with(nolock)
			where Idrow = @Idrow
	
	

END








GO
