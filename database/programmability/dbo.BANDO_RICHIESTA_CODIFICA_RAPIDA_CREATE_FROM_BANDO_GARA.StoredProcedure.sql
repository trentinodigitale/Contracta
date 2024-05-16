USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_RICHIESTA_CODIFICA_RAPIDA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[BANDO_RICHIESTA_CODIFICA_RAPIDA_CREATE_FROM_BANDO_GARA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	
	SET NOCOUNT ON

	declare @Id as INT
	
	declare @ModelloGara  as int
	declare @modellocodifica varchar(500)
	declare @ambito as varchar(500)
	--declare @ColonneModelloAmbito as varchar(max)
	declare @ConditionObblig as varchar(MAX)
	declare @modellobando varchar(500)
	declare @divisione_lotti as varchar(1)
	declare @tipodoc as varchar(500)
	declare @Cod varchar(500)
	declare @Filter as varchar(MAX)
	declare @sql as nvarchar(MAX)

	declare @SqlRCInCorso  as nvarchar(max)
	declare @DestListField as varchar(max)


	declare @Errore as nvarchar(2000)
	set @Errore = ''

	select 
		@divisione_lotti=Divisione_lotti ,@tipodoc=tipodoc,@Cod = TipoBando
    from 
		ctl_doc with (nolock)
			inner join Document_Bando with (nolock) on idHeader=id
	where id=@iddoc

	--recupero modello bando associato
	select @modellobando=modellobando + '_LOTTI' from Document_Modelli_MicroLotti where codice=@Cod


	--Verifica se l'utente ha confermato il modello associato, altrimenti non ha a disposizione i modelli per funzionare bene
	select @ModelloGara=value 
		from 
			ctl_doc_value with (nolock)
		where 
			idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello'

	if exists (
			Select IdRow 
				from ctl_doc_value with (nolock)
				where idheader=@ModelloGara
						and DSE_ID='STATO_MODELLO' and DZT_Name='Stato_Modello_Gara' 
						and ISNULL(value,'')='ERRORE'
			)
	begin
		set @Errore ='Prima di utilizzare la funzione effettuare una "Conferma" del modello associato alla gara'
	end

	if @Errore=''
	begin
		-- cerco una versione in lavorazione del documento 
		set @id = null
		
		select @id = id 
			from 
				CTL_DOC with (nolock) 
			where 
				LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'BANDO_RICHIESTA_CODIFICA_RAPIDA' ) 
				and statofunzionale in ( 'InLavorazione')

	end
	-- se non esiste lo creo
	if @id is null and @Errore=''
	begin
			
			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, 
				Titolo,LinkedDoc,ProtocolloRiferimento,Fascicolo,azienda )
				select 
					@IdUser as idpfu , 'BANDO_RICHIESTA_CODIFICA_RAPIDA' as TipoDoc ,  
					 Titolo,@idDoc as LinkedDoc,Protocollo,Fascicolo,azienda			
					from 
						 ctl_doc with (nolock) 
					where id = @idDoc


			set @id = @@identity
			

			--inserisco campo per esito verifica informazioni
			insert into ctl_doc_value
				(IdHeader,dse_id,row,DZT_Name,value)
				values
				(@id,'TESTATA_PRODOTTI',0,'EsitoRiga','')

			
			--copio le righe della gara non ancora codificate

			Select @ambito=value
				from CTL_DOC_Value  with (nolock)
				where IdHeader=@iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='Ambito'

			--recupero modello codifica per ambito
			select 
					@modellocodifica='MODELLO_BASE_CODIFICA_PRODOTTI_' + titolo + '_MOD_Macro_Prodotto' 
				from 
					ctl_doc with (nolock)
						inner join CTL_DOC_Value with (nolock) on id=IdHeader and DSE_ID='AMBITO' and DZT_Name='MacroAreaMerc' and value=@ambito
		
				where tipodoc='CONFIG_MODELLI' and Deleted=0 and JumpCheck='CODIFICA_PRODOTTI' and StatoFunzionale='Pubblicato'

			--set @ColonneModelloAmbito=''
			set @ConditionObblig=''

			--recupero l'elenco delle colonne in comune tra il modello bando 
			--e modello codifica inserito un numero random per evitare falsi positivi 
			--quando sia sul bando che sulla richiesta non sono compilati i campi
			select 	
				@ConditionObblig = @ConditionObblig + '( isnull(A.' + c1.MA_DZT_Name +','''') = isnull(B.' + c2.MA_DZT_Name + ','''') ) and '
				--, @ColonneModelloAmbito = @ColonneModelloAmbito +  c1.MA_DZT_Name + ','
				from 
					ctl_ModelAttributes c1 with (nolock) ,ctl_ModelAttributes c2 with (nolock)
				where		
					c1.MA_MOD_ID=@modellobando
					and c2.MA_MOD_ID=@modellocodifica
					and c1.MA_DZT_Name not in ( 'EsitoRiga' ,'FNZ_DEL','TipoDoc','CODICE_REGIONALE', 'NotEditable' )  
					and c1.MA_DZT_Name=c2.MA_DZT_Name

			declare @Colonne_Da_Escludere as varchar(max)
			set @Colonne_Da_Escludere = 'Id,IdHeader,TipoDoc,idHeaderLotto,Posizione,EsitoRiga'

			--rimuovo la and finale
			if @ConditionObblig <> ''
				set @ConditionObblig = SUBSTRING ( @ConditionObblig , 0 , len(@ConditionObblig)-3 ) 
	
			set @Colonne_Da_Escludere = ' ' + @Colonne_Da_Escludere + ' '

			set @sql = ''
			--considero le righe del bando che hanno codice regionale vuoto
			set @sql = @sql + 'select 
						distinct b.id as IdRow1 
							from 
								Document_MicroLotti_Dettagli b with (nolock)	
							where b.idheader=' + cast(@iddoc as varchar(50)) + ' and b.tipodoc =''' + @tipodoc +''' and ISNULL(ltrim(rtrim(b.CODICE_REGIONALE)),'''')='''' ' 


			--se non a lotti 
			if ( @divisione_lotti = '0')
			begin

				set @Filter = ''

				--se ci sono alte righe oltre alla riga 0 allora la riga 0 non la porto altrimenti si
				if exists (select id from  Document_MicroLotti_Dettagli with (nolock) where idheader=@iddoc and tipodoc=@tipodoc and isnull(numeroriga,0)<>0 )
					set @Filter = ' and isnull(b.numeroriga,0)<>0 '

				set @sql= @sql +  + @Filter
			end 

			--se a lotti multivoce non considero la voce 0
			if ( @divisione_lotti = '1')
			begin
				set @sql=@sql + ' and b.voce > 0 '
			end 

			--filtrate di quelle che sono presenti in richieste in corso
			set @SqlRCInCorso = 'select 
							distinct b.id as IdRow1 
								from Document_MicroLotti_Dettagli b	with (nolock)
									inner join ctl_doc C with (nolock) on C.linkeddoc=' + cast(@iddoc as varchar(50)) + ' and C.tipodoc=''RICHIESTA_CODIFICA_PRODOTTI'' and C.statofunzionale in (''InLavorazione'',''Inviato'')	
									inner join Document_MicroLotti_Dettagli A with (nolock) on a.statoriga <> ''Rifiutato'' and a.IdHeader=C.id and a.TipoDoc=c.TipoDoc	and ( ' + @ConditionObblig +' )		
								where b.idheader=' + cast(@iddoc as varchar(50)) + ' and b.tipodoc =''' + @tipodoc+''' and ISNULL(b.CODICE_REGIONALE,'''')='''' ' 

			
			set @sql = @sql + '  and b.Id not in ( ' + @SqlRCInCorso + ')'



			set @Filter = ' id in ( ' + @sql + ' )'


			set @DestListField = ' ''BANDO_RICHIESTA_CODIFICA_RAPIDA'' as TipoDoc, id as idHeaderLotto, ''' + @ambito + ''' as Posizione, '''' as EsitoRiga '
	

			exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @id, 'IdHeader'
						, @Colonne_Da_Escludere
						, @Filter 
						, ' TipoDoc, idHeaderLotto, Posizione, EsitoRiga '
						, @DestListField
						, ' id '

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

SET NOCOUNT OFF
END
		
		
















GO
