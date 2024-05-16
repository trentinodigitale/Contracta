USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AVCP_IMPORT_CSV_MAKE_GRUPPO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc  [dbo].[AVCP_IMPORT_CSV_MAKE_GRUPPO]( @IdOE int , @VersioneLotto int , @FascicoloLotto varchar(50)  , 
					@IdDoc int , @MinRowGruppo int , @MaxRowGruppo int ,  @IdUser int , @Azienda int )
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
	-- inserisco il nuovo gruppo
	------------------------------

	--DELETE FROM CTL_DOC WHERE tipodoc = 'AVCP_GRUPPO' and StatoFunzionale = 'Pubblicato' and LinkedDoc = @VersioneLotto and idpfu = @IdUser and azienda = @Azienda

	INSERT INTO ctl_doc ( tipodoc, statoFunzionale,  data, datainvio , PrevDoc,				LinkedDoc,  idpfu, Azienda , Fascicolo , Protocollo)
		values ( 'AVCP_GRUPPO' , 'Pubblicato' , getdate() , getdate() , isnull( @IdOE , 0) , @VersioneLotto , @IdUser , @Azienda , @FascicoloLotto , @Protocollo)


	SET @newid = SCOPE_IDENTITY()


	insert into document_AVCP_partecipanti ( Idheader, Ruolopartecipante, Estero, Codicefiscale, Ragionesociale, aggiudicatario )
		select @newid, Ruolopartecipante, Estero, Codicefiscale, Ragionesociale, aggiudicatario 
			from document_AVCP_Import_CSV 
			where idheader = @IdDoc and Idrow >= @MinRowGruppo and Idrow <= @MaxRowGruppo

	



	declare @Gruppo nvarchar(200)
	declare @aggiudicatario char(1)
	declare @aziIdDscFormaSoc varchar(50)
	
	-- Mi calcolo @aziIdDscFormaSoc
	
		-- controllo se la prima riga è mandataria allora è un RTI
		select @aziIdDscFormaSoc= case when Ruolopartecipante='02' then '845326' else '' end
			 from document_AVCP_partecipanti 
				where idheader = @newid and idrow=(Select MIN(IdRow) from document_AVCP_partecipanti where idheader = @newid )
		--se non è mandataria mi serve capire se tra le righe  ci sia una consorziata o un associazione
		IF (@aziIdDscFormaSoc='') 
		BEGIN
			--controllo se tra le righe ci sta un consorzio
			IF EXISTS (Select * from document_AVCP_partecipanti where idheader = @newid and RuoloPartecipante='05') 
			BEGIN
				set @aziIdDscFormaSoc='836418'
			END
			--controllo se tra le righe ci sta un'Associazione
			IF EXISTS (Select * from document_AVCP_partecipanti where idheader = @newid and RuoloPartecipante='03') 
			BEGIN
				set @aziIdDscFormaSoc='836420'
			END
		END


	SELECT @Aggiudicatario = Aggiudicatario , @Gruppo = Gruppo from document_AVCP_Import_CSV 
			where idheader = @IdDoc and Idrow = @MinRowGruppo 

	insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
		VALUES( @newid , 'TESTATA' , 0 , 'Aggiudicatario' , @Aggiudicatario )

	insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
		VALUES( @newid , 'TESTATA' , 0 , 'aziIdDscFormaSoc' , @aziIdDscFormaSoc )

	insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
		VALUES( @newid , 'TESTATA' , 0 , 'RagioneSociale' , @Gruppo )


END









GO
