USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_VERBALEGARA_CREATE_FROM_PDA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_VERBALEGARA_CREATE_FROM_PDA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	--@idDoc contieni ID del documento dal quale ho fatto crea verbale, può essere IDPDA o IDLOTTO
	--in CTL_IMPORT e' stato poggiato per utente id_template di partenza recuperato oppure scelto dall'utente
	SET NOCOUNT ON;
		
	declare @Id_template as INT	
	declare @Id as int
	declare @IdPDA as int
	declare @Errore as nvarchar(2000)	
	declare @JumpCheck as varchar(200)
	declare @numerolotto as varchar(100)
	declare @idrow as INT
	set @numerolotto=''

	declare @strTestata as nvarchar(max)	
	declare @strTestata2 as nvarchar(max)	
	declare @strPiePagina as nvarchar(max)	
	declare @Descrizioneestesa as nvarchar(max)		
	

	set @Errore = ''
	-- QUESTA MAKE DOC FROM VIENE INVOCATA CON IL PARAMETRO BUFFER, 
	-- MI TROVERO' QUINDI LE RIGHE  NELLA COLONNA 'A' DELLA CTL_IMPORT ID_TEMPLATE
	select @Id_template = A from CTL_Import with(nolock) where idPfu = @IdUser

	-- controllo lo stato dell'istanza
	if not exists( select * from CTL_DOC with(nolock) where id = @Id_template and Deleted=0 and StatoFunzionale in ( 'Pubblicato'))
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita il Verbale Template di partenza non è stato trovato' 
	end
	
	--CAPISCO SE E' STATA CHIAMATA DA UN LOTTO O DALLA PDA
	IF EXISTS ( select * from CTL_DOC with(nolock) where Id=@idDoc and TipoDoc='PDA_MICROLOTTI' and Deleted=0)
	BEGIN
		set @IdPDA=@idDoc
		--@idDoc lo setto con il primo ID della microlotti dettagli per rendere la struttura compatibile sia se chiamata da un lotto
		--oppure dalla PDA stesso
		select top 1 @idDoc=id from Document_MicroLotti_Dettagli with(nolock) where IdHeader=@IdPDA and TipoDoc='PDA_MICROLOTTI'
	END
	ELSE
	BEGIN
		select @IdPDA=idheader ,@numerolotto=' - Lotto N° ' + NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where Id=@idDoc
	END

	select @JumpCheck=tipoverbale from Document_VerbaleGara with(nolock) where IdHeader=@Id_template


	if @Errore = '' 
	begin
		
		--CREAZIONE TESTATA DOCUMENTO VERBALEGARA LEGATO ALLA SEDUTA
		insert into CTL_DOC ( idPfuInCharge,Titolo, IdDoc, JumpCheck , IdPfu, TipoDoc, Body, Azienda, StrutturaAziendale, ProtocolloRiferimento, Fascicolo, LinkedDoc  ) 
			select @iduser , 'Verbale - ' + @JumpCheck + @numerolotto ,@idDoc,@JumpCheck , @iduser ,'VERBALEGARA', C.Body,P.pfuIdAzi, C.StrutturaAziendale , C.ProtocolloRiferimento , C.Fascicolo,@IdPDA
				from CTL_DOC C  with(nolock)
					inner join ProfiliUtente P with(nolock)  on P.IdPfu=@IdUser
				where C.Id=@IdPDA 

		set @id=SCOPE_IDENTITY()

		--TRACCIO NELLA CTL_DOC_VALUE @id_template di partenza
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
			select @id,'STORICO_Id_template','Id_template',@Id_template

		select 
			@strTestata=dbo.CNV_ESTESA(Testata,'I'),
			@strTestata2=dbo.CNV_ESTESA(Testata2,'I'),
			@strPiePagina=dbo.CNV_ESTESA(PiePagina,'I')
		from ctl_doc with(nolock) 
			inner join document_VerbaleGara with(nolock)  on IdHeader=id
		where Id=@Id_template

		
		exec RISOLVE_VERBALEGARA @strTestata , @idDoc ,@JumpCheck, @strTestata output
		exec RISOLVE_VERBALEGARA @strTestata2 , @idDoc ,@JumpCheck, @strTestata2 output
		exec RISOLVE_VERBALEGARA @strPiePagina , @idDoc ,@JumpCheck, @strPiePagina output


		--INSERT TESTATA e PIEPAGINA PER IL DOCUMENTO VERBALEGARA
		insert into document_VerbaleGara ( IdHeader, ProceduraGara, CriterioAggiudicazioneGara, Testata, PiePagina , Testata2 , IdTipoVerbale , TipoVerbale, TipoSorgente ) 
			select @id , 'strTipoProcedura' , 'strCriterioDiAggiudicazione', @strTestata, @strPiePagina, @strTestata2, @Id_template , @JumpCheck , 2
				
		
		DECLARE curs1 CURSOR STATIC FOR
			select IdRow,DescrizioneEstesa 
				from document_VerbaleGara_Dettagli with(nolock)					
					where IdHeader=@Id_template order by Pos
		OPEN curs1
		FETCH NEXT FROM curs1 INTO @idrow,@DescrizioneEstesa

		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec RISOLVE_VERBALEGARA @DescrizioneEstesa , @idDoc ,@JumpCheck, @DescrizioneEstesa output
			
			insert into document_VerbaleGara_Dettagli ( IdHeader, Pos, SelRow , TitoloSezione, DescrizioneEstesa, Edit, CanEdit )
				select @id , Pos, SelRow , TitoloSezione, @DescrizioneEstesa, Edit, CanEdit 
					from document_VerbaleGara_Dettagli with(nolock)					
						where IdRow=@idrow

			FETCH NEXT FROM curs1 INTO @idrow,@DescrizioneEstesa
		END
	
	
		CLOSE curs1
		DEALLOCATE curs1

		
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
