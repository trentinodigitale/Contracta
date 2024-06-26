USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CERCA_PRODOTTI_CONVENZIONE_K2]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CERCA_PRODOTTI_CONVENZIONE_K2] ( @idDoc int , @IdUser int, @daContratto int = 0  )
AS
BEGIN

	SET NOCOUNT ON
	
	declare @idModProd		as int
	declare @linkedDoc	as int
	declare @idFornitore	as int


	declare @Ambito			as varchar(100)
	declare @tipodoc        as varchar(200)
	declare @CodiceMod		as varchar(1000)
	declare @CodiceModListino		as varchar(1000)
	declare @SQL_COND		as varchar(max)
	declare @SQL			as varchar(max)
	declare @SQL_TRAVASA	as varchar(max)

	select  @linkedDoc = linkedDoc , 
			@idFornitore = Destinatario_Azi,
			@tipodoc=TipoDoc 
		from ctl_doc with(nolock)
		where id = @iddoc

	-- Se ci troviamo nel giro convenzione / listino
	if @daContratto = 0
	begin
		IF @tipodoc = 'CONVENZIONE'
		BEGIN

			declare @tmpIdForn int

			select  @Ambito = ambito,
					@tmpIdForn = Mandataria
				from document_convenzione with(nolock) 
				where id = @iddoc

			-- kpf 203277
			if isnull(@idFornitore,0) = 0
			begin
				set @idFornitore = @tmpIdForn
			end
			-- fine kpf 203277

		END
		ELSE
		BEGIN
			select @Ambito = ambito 
			from document_convenzione with(nolock) 
			where id = @linkedDoc
		END
		

	end
	else
	begin

		-- se ci troviamo nel giro contratto_gara
		select @Ambito = vals.[Value]
				from CTL_DOC pdaCom with(nolock)
						inner join CTL_DOC pda with(nolock) on pda.Id = pdaCom.LinkedDoc
						inner join CTL_DOC_Value vals with(nolock) on vals.IdHeader = pda.LinkedDoc and vals.DSE_ID = 'TESTATA_PRODOTTI' and vals.DZT_Name = 'Ambito'
				where pdacom.Id = @linkedDoc

	end

	-- ricerca il modello di codifica dedicato
	set @idModProd = null

	select  @idModProd = d.id , 
			@CodiceMod = 'MODELLO_BASE_CODIFICA_PRODOTTI_' +  Titolo + '_MOD_Prodotto'
		from ctl_doc d with(nolock)
			inner join ctl_doc_value v with(nolock) on  d.id = v.idheader and DZT_Name = 'MacroAreaMerc'
		where tipodoc = 'CONFIG_MODELLI' and jumpcheck = 'CODIFICA_PRODOTTI' and deleted = 0  and StatoFunzionale = 'Pubblicato' and Value = @Ambito


	-- recupera il modello di attributi
	IF @daContratto = 0
		select @CodiceModListino = MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where [IdHeader] = @iddoc and DSE_ID = 'PRODOTTI'
	ELSE
		select @CodiceModListino = MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where [IdHeader] = @iddoc and DSE_ID = 'BENI'


	-- recupero gli attributi chiave per il confronto
	set @SQL_COND = ''

	--select @SQL_COND = @SQL_COND  + ' ISNULL( S.' + v1.Value + ' , '''' ) = ISNULL( D.' + v1.Value + ' ,'''' )AND '
	select @SQL_COND = @SQL_COND  + ' ISNULL( S.' + v1.Value + ' , '''' ) = ISNULL( D.' + v1.Value + ' ,'''' ) AND ISNULL( D.' + v1.Value + ' ,'''' ) <> '''' AND '
		from ctl_doc d with(nolock)
				inner join CTL_DOC_VALUE v1 with(nolock)  on v1.IdHeader = d.id and v1.DSE_ID = 'MODELLI' and v1.DZT_Name = 'DZT_Name'
				inner join CTL_DOC_VALUE v2 with(nolock)  on v2.IdHeader = d.id and v2.DSE_ID = 'MODELLI' and v2.DZT_Name = 'MOD_Prodotto' and v1.Row = v2.Row
		where d.id = @idModProd and v2.Value = 'Chiave'

	-- recupero tutti gli attributi da travasare fra la codifica dei prodotti ed il listino
	set @SQL_TRAVASA = ''

	select @SQL_TRAVASA = @SQL_TRAVASA + ' D.' + A.MA_DZT_Name + ' = case when isnull( S.' + A.MA_DZT_Name + ' , '''' ) = '''' then  D.' + A.MA_DZT_Name + ' else  S.' + A.MA_DZT_Name + ' end , '
		from CTL_ModelAttributes A  with(nolock)
				inner join CTL_ModelAttributes B  with(nolock) on A.MA_DZT_Name = B.MA_DZT_Name and B.MA_MOD_ID = @CodiceModListino
		where A.MA_MOD_ID = @CodiceMod
				and A.MA_DZT_Name not in ( 'Id', 'IdHeader', 'FNZ_DEL','TipoDoc', 'Graduatoria', 'Sorteggio', 'Posizione', 'Aggiudicata', 'Exequo', 'StatoRiga', 'EsitoRiga', 'NumeroLotto' , 'NumeroRiga' , 'Voce' )

		--print 'SQL_COND:' + @SQL_COND
		--print 'SQL_TRAVASA:' + @SQL_TRAVASA

	if @SQL_COND <> '' and @SQL_TRAVASA <> ''
	begin

		declare @RAGIONE_SOCIALE_FORNITORE				nvarchar(1000)
		declare @CODICE_FISCALE_OPERATORE_ECONOMICO		varchar(1000)
		declare @PARTITA_IVA_FORNITORE					varchar(1000)

		-- prima di fare il confronto riporto sul listino del fornitore i dati recuperandoli dalla testata
		select @RAGIONE_SOCIALE_FORNITORE = aziRagioneSociale , @CODICE_FISCALE_OPERATORE_ECONOMICO = d.vatValore_FV , @PARTITA_IVA_FORNITORE = a.aziPartitaIVA
			from aziende a  with(nolock)
					inner join DM_Attributi D  with(nolock) on d.lnk = IdAzi and D.idApp = 1 AND D.dztNome = 'CODICEFISCALE' 
			where idazi = @idFornitore

		update Document_microlotti_dettagli
			set RAGIONE_SOCIALE_FORNITORE = @RAGIONE_SOCIALE_FORNITORE ,
				CODICE_FISCALE_OPERATORE_ECONOMICO = @CODICE_FISCALE_OPERATORE_ECONOMICO ,
				PARTITA_IVA_FORNITORE = @PARTITA_IVA_FORNITORE
			where idheader = @idDoc and TipoDoc = @tipodoc


		set @SQL_COND = left( @SQL_COND , len( @SQL_COND) - 3 )
		set @SQL_TRAVASA = left( @SQL_TRAVASA , len( @SQL_TRAVASA ) - 2 )

		-- tolgo la presenza di eventuali codici recuperati in precedenzaa
		update  Document_MicroLotti_Dettagli set CODICE_REGIONALE = '' where IdHeader=@iddoc and TipoDoc = @tipodoc

		-- compongo la query di confronto
		set @SQL = ' update D
						SET D.CODICE_REGIONALE = S.CODICE_REGIONALE , D.DESCRIZIONE_CODICE_REGIONALE = S.DESCRIZIONE_CODICE_REGIONALE , ' + @SQL_TRAVASA + '

						from Document_microlotti_dettagli D
							inner join Document_microlotti_dettagli S on  S.TipoDoc = ''PRODOTTO'' AND ' + @SQL_COND + ' 
						where  D.idHeader = ' + cast( @iddoc as varchar(20)) + ' AND D.TipoDoc = '''+ @tipodoc +'''  and S.Posizione = ''' + @Ambito + ''' 
						
							'
		--PRINT @SQL

		exec(  @SQL ) 

	end	

end		


GO
