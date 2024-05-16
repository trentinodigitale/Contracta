USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERBALEGARA_CREATE_FROM_DOCUMENT]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[VERBALEGARA_CREATE_FROM_DOCUMENT] 
	( @idDoc int , @IdUser int  , @Contesto as varchar (50))
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
	declare @Caption as nvarchar(100)
	declare @Titolo as nvarchar(500)
	declare @strutturaaziendale as varchar(150)
	set @Caption=''

	set @Errore = ''
	-- QUESTA MAKE DOC FROM VIENE INVOCATA CON IL PARAMETRO BUFFER, 
	-- MI TROVERO' QUINDI LE RIGHE  NELLA COLONNA 'A' DELLA CTL_IMPORT ID_TEMPLATE
	select @Id_template = A from CTL_Import with(nolock) where idPfu = @IdUser

	-- controllo lo stato dell'istanza
	if not exists( select id from CTL_DOC with(nolock) where id = @Id_template and Deleted=0 and StatoFunzionale in ( 'Pubblicato') ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita il Verbale Template di partenza non è stato trovato' 
	end
	
	--CAPISCO SE E' STATA CHIAMATA DA UN LOTTO O DALLA PDA o DAL CONTRATTO GARA
	--IF EXISTS ( select * from CTL_DOC with(nolock) where Id=@idDoc and TipoDoc='PDA_MICROLOTTI' and Deleted=0)

	if @Errore =''
	begin
		
		select @JumpCheck=tipoverbale from Document_VerbaleGara with(nolock) where IdHeader=@Id_template

		if @Contesto='MONOLOTTO'  
		begin
			set @IdPDA=@idDoc
			--@idDoc lo setto con il primo ID della microlotti dettagli per rendere la struttura compatibile sia se chiamata da un lotto
			--oppure dalla PDA stesso
			select top 1 @idDoc=id from Document_MicroLotti_Dettagli with(nolock) where IdHeader=@IdPDA and TipoDoc='PDA_MICROLOTTI' order by id
		
			set @Titolo = 'Verbale - ' + @JumpCheck 

		end
		else 
		if @Contesto='CONTRATTO_GARA'  
		begin
		
			set @IdPDA=@idDoc
			set @numerolotto = ''
			select  @numerolotto  =  @numerolotto +  NumeroLotto + ',' from Document_MicroLotti_Dettagli with(nolock)
			 where IdHeader=@idDoc and tipodoc='CONTRATTO_GARA' and voce=0
			
			--salgo sulla gara per recuperare la strutturaaziendale
			select @strutturaaziendale=g.StrutturaAziendale 
				from CTL_DOC C with(nolock)
					inner join ctl_doc g with(nolock) on c.ProtocolloRiferimento=g.Protocollo and g.Deleted=0 and g.tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				where c.id=@IdPDA


			if @numerolotto <>''
				set @numerolotto = left(@numerolotto,len(@numerolotto)-1)
		
		
			set @Caption ='Modello Contratto'

			set @Titolo = 'Modello Contratto Lotti N°: ' + @numerolotto
		end
		else
		begin

			select @IdPDA=idheader ,@numerolotto=' - Lotto N° ' + NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where Id=@idDoc
			set @Titolo = 'Verbale - ' + @JumpCheck + @numerolotto

		end
	end

	

	--if @Contesto = 'MONOLOTTO'
	--BEGIN
	--	set @IdPDA=@idDoc
	--	--@idDoc lo setto con il primo ID della microlotti dettagli per rendere la struttura compatibile sia se chiamata da un lotto
	--	--oppure dalla PDA stesso
	--	select top 1 @idDoc=id from Document_MicroLotti_Dettagli with(nolock) where IdHeader=@IdPDA and TipoDoc='PDA_MICROLOTTI' order by id
	--END
	--ELSE
	--BEGIN
	--	select @IdPDA=idheader ,@numerolotto=' - Lotto N° ' + NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where Id=@idDoc
	--END
	
	--set @Titolo = 'Verbale - ' + @JumpCheck + @numerolotto

	----se sto creando STIPULA CONTRATTO dal CONTRATTO_GARA
	--if @Contesto = 'CONTRATTO_GARA'
	--BEGIN
	--	set @IdPDA=@idDoc
	--	set @numerolotto = ''
	--	select  @numerolotto  =  @numerolotto + NumeroLotto + ',' from Document_MicroLotti_Dettagli with(nolock) where IdHeader=@idDoc and tipodoc='CONTRATTO_GARA'
		
	--	if @numerolotto <>''
	--		set @numerolotto = left(@numerolotto,len(@numerolotto)-1)
		
		
	--	set @Caption ='Stipula Contratto'

	--	set @Titolo = 'Verbale di Stipula Contratto Lotti N°: ' + @numerolotto
	--END

	


	if @Errore = '' 
	begin
		
		--CREAZIONE TESTATA DOCUMENTO VERBALEGARA LEGATO ALLA SEDUTA
		insert into CTL_DOC ( idPfuInCharge,Titolo, IdDoc, JumpCheck , IdPfu, TipoDoc, Body, Azienda, StrutturaAziendale, ProtocolloRiferimento, Fascicolo, LinkedDoc, Caption  ) 
			select @iduser ,  @Titolo ,@idDoc,@JumpCheck , @iduser ,'VERBALEGARA', C.Body,P.pfuIdAzi, isnull(@strutturaaziendale,C.StrutturaAziendale) , C.ProtocolloRiferimento , C.Fascicolo,@IdPDA, @Caption
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

		
		exec RISOLVE_TEMPLATE @strTestata , @idDoc ,@JumpCheck, @strTestata output
		exec RISOLVE_TEMPLATE @strTestata2 , @idDoc ,@JumpCheck, @strTestata2 output
		exec RISOLVE_TEMPLATE @strPiePagina , @idDoc ,@JumpCheck, @strPiePagina output


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
			exec RISOLVE_TEMPLATE @DescrizioneEstesa , @idDoc ,@JumpCheck, @DescrizioneEstesa output
			
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
