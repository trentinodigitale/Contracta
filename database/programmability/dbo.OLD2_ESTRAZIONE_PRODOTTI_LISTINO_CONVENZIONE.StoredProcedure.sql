USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ESTRAZIONE_PRODOTTI_LISTINO_CONVENZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD2_ESTRAZIONE_PRODOTTI_LISTINO_CONVENZIONE](@IdRow int)
as 
BEGIN
	
	--declare @IdRow int 

	--set @IdRow = 2752
	SET NOCOUNT ON;
	
	declare @Ambito as varchar(10)
	declare @TipoListino as varchar(50)
	declare @IdConv as int
	declare @ListColumn as nvarchar(max)
	declare @PresenzaListinoOrdini as varchar(10)
	declare @IdDoc_Estrazione as int
	declare @TipoDoc_Estrazione as varchar(100)
	declare @SqlEstract as nvarchar(max)
	declare @Table as varchar(500)
	declare @Lng as varchar(10) 
	declare @dm_id as nvarchar(500) 
    declare @dm_query as nvarchar(max) 
    declare @Sql_Insert_Dinamici  nvarchar(max)
    declare @FormatDinamici as varchar(100)
	declare @NomiColonneFrom as nvarchar(max)
    declare @LeftJoinDomain as nvarchar(max)
    declare @Cont as int
	declare @CodiceFiscale as varchar(20)
	declare @NomeConvenzione as nvarchar(500)
	declare @NumeroConvenzione as nvarchar(50)
	declare @PartitaIva as varchar(20)
	declare @RagioneSociale as nvarchar(1000)
	declare @DataInizioListino as varchar(20)
	declare @DataFineListino as varchar(20)
	declare @DataElaborazione as varchar(20)

	set @Lng ='I'
	set @Table = 'Document_Microlotti_Dettagli'

	-- la stored riceve in input IdRow della tabella [Document_Estrazione_ListiniConvenzioni]
	-- Estrae tutti i prodotti validi e li ritorna in un recordset le cui colonne sono chiamate come la rappresentazione a video


	-- da idrow ricavo id della convenzione memorizzata nel campo IdDoc
	-- e con questo navigando sul doc in elaborazione ricavo tipolistino e ambito
	select 
			@IdConv = D.IdDoc, 
			@TipoListino = E.Titolo,
			@Ambito = E.JumpCheck
		from 
			Document_Estrazione_ListiniConvenzioni D with (nolock) 
				inner join CTL_DOC E with (nolock) on E.Id = D.IdHeader
		where D.idrow = @IdRow

	-- RECUPERO UNA SERIE DI INFO PIATTE DELLA CONVENZIONE
	-- CHE VANNO RITORNATE NEI LISTINI
	select 
		@CodiceFiscale = vatValore_FT,
		@NomeConvenzione = C.Titolo,
		@NumeroConvenzione = DC.NumOrd,
		@PartitaIva = aziPartitaIVA,
		@RagioneSociale = aziRagioneSociale,
		@DataFineListino = Convert(varchar(10),DataFine , 103), -- italiano da chidere meglio se va bene
		@DataInizioListino = Convert(varchar(10),C.DataInvio , 103),  -- da chiedere meglio se va bene
		--select Convert(varchar(10),GETDATE() , 103)
		@PresenzaListinoOrdini = isnull(PresenzaListinoOrdini,'no')
			from 
				CTL_DOC C with (nolock)
					inner join Document_Convenzione DC with (nolock) on DC.id = C.id
					inner join DM_Attributi with (nolock) on lnk = Mandataria and dztNome = 'codicefiscale'
					inner join Aziende A with (nolock) on A.IdAzi = Mandataria 
			where
				C.ID = @idconv
	select 
		@Ambito as AMBITO, @CodiceFiscale as CODICEFISCALE, --@DataInizioListino as DATAINVIO,
		@DataFineListino as DATAFINE, @NomeConvenzione as TITOLO, 
		@NumeroConvenzione as NUMEROCONVENZIONE,@PartitaIva as PARTITAIVA, @RagioneSociale as RAGIONESOCIALE,
		@DataElaborazione as DATA_ELABORAZIONE
		into 
			#temp_info_convenzione
	
	set @DataElaborazione = Convert(varchar(10),GETDATE() , 103)
	
	set @IdDoc_Estrazione = -1 

	--se dobbiamo fare estrazione LISTINO ORDINI ALCUNE LOGIGHE CAMBIANO
	if @TipoListino = 'ordini' and @PresenzaListinoOrdini = 'si'
	BEGIN
		select @IdDoc_Estrazione = id
				from CTL_DOC with (nolock)
					where linkeddoc = @IdConv and TipoDoc='LISTINO_ORDINI' 
						and StatoFunzionale ='Confermato' and Deleted = 0	
				
		set @TipoDoc_Estrazione = 'LISTINO_ORDINI'
		

		-- estrae in modo diverso la DATAINVIO
		-- navigando la struttura delle possibili variazioni di prezzo subite o di add/upd prodotti
		select co.id as IdRiga,

			Convert(varchar(10), MAX (

			case when isnull(add1.TipoDoc,'') in ('CONVENZIONE_ADD_PRODOTTI','CONVENZIONE_UPD_PRODOTTI') then add1.datainvio
			
				when  isnull(P1.TipoDoc,'') in ('CONVENZIONE_PRZ_PRODOTTI') then 
					case  when P1.Value < getdate() then P1.value else   conv.DataInvio end

				when  isnull(P.TipoDoc,'') in ('CONVENZIONE_PRZ_PRODOTTI') then 
						case  when P.Value < getdate() then P.value else   conv.DataInvio end
			
			
			
				else conv.DataInvio 
			end ), 103) as DataInvio	

			into #temp_data_ini_convenzione_LISTINO_ORDINI

		from 
			CTL_DOC conv with (nolock)
	
			inner join  Document_MicroLotti_Dettagli co with (nolock) on co.IdHeader = conv.id and co.TipoDoc=@TipoDoc_Estrazione

			left join
					(
						select  p.linkeddoc , x.idHeaderLotto , x.id, P.DataInvio , P.tipodoc
							from ctl_doc P with (nolock)
							inner join Document_MicroLotti_Dettagli x with (nolock) on x.IdHeader = p.id 
												and x.tipodoc in ('CONVENZIONE_ADD_PRODOTTI','CONVENZIONE_UPD_PRODOTTI')					

								where 
											 P.TipoDoc in ('CONVENZIONE_ADD_PRODOTTI','CONVENZIONE_UPD_PRODOTTI')
											and P.StatoFunzionale = 'Inviato' 
											and P.deleted = 0 

					) add1 on add1.linkeddoc = conv.linkeddoc and co.idHeaderLotto = add1.Id		
		
			left join 
				( select  p.linkeddoc , prz.idHeaderLotto , dd.Value , prz.id, P.Id as iddoc,P.tipodoc
					from ctl_doc P with (nolock)
					inner join Document_PRZ_PRODOTTI_Dettagli prz with (nolock) on prz.IdHeader = p.id and prz.tipodoc = 'CONVENZIONE_PRZ_PRODOTTI'
					inner join CTL_DOC_Value  dd with (nolock) on dd.IdHeader = P.id
													and DSE_ID = 'PARAMETRI_VARIAZIONE' and DZT_Name = 'DataDecorrenza'

						where 
									 P.TipoDoc in ('CONVENZIONE_PRZ_PRODOTTI')
									 and ISNULL(p.jumpcheck,'')<>'LISTINO_ORDINI'
									and P.StatoFunzionale = 'Inviato' 
									and P.deleted = 0 
				) P on    P.idHeaderLotto = co.Id and P.LinkedDoc = conv.linkeddoc		

			left join -- caso del LISTINO_ORDINI_OE
				( select  p.linkeddoc , prz.idHeaderLotto , dd.Value , prz.id, P.Id as iddoc,P.tipodoc
					from ctl_doc P with (nolock)
					inner join Document_PRZ_PRODOTTI_Dettagli prz with (nolock) on prz.IdHeader = p.id and prz.tipodoc = 'CONVENZIONE_PRZ_PRODOTTI'
					inner join CTL_DOC_Value  dd with (nolock) on dd.IdHeader = P.id
													and DSE_ID = 'PARAMETRI_VARIAZIONE' and DZT_Name = 'DataDecorrenza'

						where 
									 P.TipoDoc in ('CONVENZIONE_PRZ_PRODOTTI')
									 --and ISNULL(p.jumpcheck,'')<>'LISTINO_ORDINI'
									and P.StatoFunzionale = 'Inviato' 
									and P.deleted = 0 
				) P1 on     P1.LinkedDoc = conv.linkeddoc	

			left join Document_MicroLotti_Dettagli list with (nolock) on list.Id = P1.idHeaderLotto 
																			and list.TipoDoc in ('LISTINO_ORDINI','LISTINO_ORDINI_OE')
																			and ISNULL(list.IdRigaRiferimento,'')<>''
																			and dbo.GetPos(list.IdRigaRiferimento,'-',1) = co.IdHeader
																			and dbo.GetPos(list.IdRigaRiferimento,'-',2) = co.NumeroRiga
		 

			where co.IdHeader = @IdDoc_Estrazione 

		group by co.id

	END
	ELSE
	BEGIN

		
		set @IdDoc_Estrazione = @IdConv
		set @TipoDoc_Estrazione = 'CONVENZIONE'	

		--se TipoListino='ordini' e il listino ordini non esiste
		--allora nella colonna [CODICE REGIONALE PRODOTTO/SERVIZIO LISTINO ORDINATIVI]  
		--restituisco [CODICEREGIONALE] della convenzione stessa
		if  @TipoListino = 'ordini'
			set @ListColumn = REPLACE (@ListColumn, '[IDRIGARIFERIMENTOCSV]' , '[CODICE_REGIONALE]' )

	

		-- estrae in modo diverso la DATAINVIO
		-- navigando la struttura delle possibili variazioni di prezzo subite o di add/upd prodotti
		select co.id as IdRiga,

			Convert(varchar(10), MAX (

			case when isnull(add1.TipoDoc,'') in ('CONVENZIONE_ADD_PRODOTTI','CONVENZIONE_UPD_PRODOTTI') then add1.datainvio
			
				when  isnull(P1.TipoDoc,'') in ('CONVENZIONE_PRZ_PRODOTTI') then 
					case  when P1.Value < getdate() then P1.value else   conv.DataInvio end

				when  isnull(P.TipoDoc,'') in ('CONVENZIONE_PRZ_PRODOTTI') then 
						case  when P.Value < getdate() then P.value else   conv.DataInvio end
			
			
			
				else conv.DataInvio 
			end ), 103) as DataInvio	

			into #temp_data_ini_convenzione_CONVENZIONE

		from 
			CTL_DOC conv with (nolock)
	
			inner join  Document_MicroLotti_Dettagli co with (nolock) on co.IdHeader = conv.id and co.TipoDoc=@TipoDoc_Estrazione

			left join
					(
						select  p.linkeddoc , x.idHeaderLotto , x.id, P.DataInvio , P.tipodoc
							from ctl_doc P with (nolock)
							inner join Document_MicroLotti_Dettagli x with (nolock) on x.IdHeader = p.id 
												and x.tipodoc in ('CONVENZIONE_ADD_PRODOTTI','CONVENZIONE_UPD_PRODOTTI')					

								where 
											 P.TipoDoc in ('CONVENZIONE_ADD_PRODOTTI','CONVENZIONE_UPD_PRODOTTI')
											and P.StatoFunzionale = 'Inviato' 
											and P.deleted = 0 

					) add1 on add1.linkeddoc = conv.id and co.idHeaderLotto = add1.Id		
		
			left join 
				( select  p.linkeddoc , prz.idHeaderLotto , dd.Value , prz.id, P.Id as iddoc,P.tipodoc
					from ctl_doc P with (nolock)
					inner join Document_PRZ_PRODOTTI_Dettagli prz with (nolock) on prz.IdHeader = p.id and prz.tipodoc = 'CONVENZIONE_PRZ_PRODOTTI'
					inner join CTL_DOC_Value  dd with (nolock) on dd.IdHeader = P.id
													and DSE_ID = 'PARAMETRI_VARIAZIONE' and DZT_Name = 'DataDecorrenza'

						where 
									 P.TipoDoc in ('CONVENZIONE_PRZ_PRODOTTI')
									 and ISNULL(p.jumpcheck,'')<>'LISTINO_ORDINI'
									and P.StatoFunzionale = 'Inviato' 
									and P.deleted = 0 
				) P on    P.idHeaderLotto = co.Id and P.LinkedDoc = conv.id		

			left join -- caso del LISTINO_ORDINI_OE
				( select  p.linkeddoc , prz.idHeaderLotto , dd.Value , prz.id, P.Id as iddoc,P.tipodoc
					from ctl_doc P with (nolock)
					inner join Document_PRZ_PRODOTTI_Dettagli prz with (nolock) on prz.IdHeader = p.id and prz.tipodoc = 'CONVENZIONE_PRZ_PRODOTTI'
					inner join CTL_DOC_Value  dd with (nolock) on dd.IdHeader = P.id
													and DSE_ID = 'PARAMETRI_VARIAZIONE' and DZT_Name = 'DataDecorrenza'

						where 
									 P.TipoDoc in ('CONVENZIONE_PRZ_PRODOTTI')
									 --and ISNULL(p.jumpcheck,'')<>'LISTINO_ORDINI'
									and P.StatoFunzionale = 'Inviato' 
									and P.deleted = 0 
				) P1 on     P1.LinkedDoc = conv.id	

			left join Document_MicroLotti_Dettagli list with (nolock) on list.Id = P1.idHeaderLotto 
																			and list.TipoDoc in ('LISTINO_ORDINI','LISTINO_ORDINI_OE')
																			and ISNULL(list.IdRigaRiferimento,'')<>''
																			and dbo.GetPos(list.IdRigaRiferimento,'-',1) = co.IdHeader
																			and dbo.GetPos(list.IdRigaRiferimento,'-',2) = co.NumeroRiga
		 

			where co.IdHeader = @idconv 

		group by co.id
	END
	


	
	-- DA UNA RELAZIONE RECUPERA LE COLONNE DA RESTITUIRE PER IL CSV
	-- RELAZIONE:
	-- Rel_Type = ESTRAZIONE_PRODOTTI_LISTINO_CONVENZIONE
	-- Rel_valueInput = [TipoListino]-[Ambito]
	-- Rel_ValueOutput = [Col1] as [Desc 1] , [Col2] as [Desc 2] , ....., [ColN] as [Desc N] 

	set @ListColumn = ''

	select 
		@ListColumn = Rel_ValueOutput
		from 
			CTL_Relations with (nolock)
		where 
			Rel_Type = 'ESTRAZIONE_PRODOTTI_LISTINO_CONVENZIONE' and Rel_valueInput = @TipoListino + '-' + @Ambito

	set @ListColumn=UPPER(@ListColumn)
--- Si richiede inoltre per i listini dell'ambito “farmaci” di valorizzare, se vuota,  
--  l’informazione “CODICE_BDR”  con l'informazione “CodiceAIC”.
	IF @Ambito='1'
		--set @ListColumn=REPLACE(@ListColumn,'[CODICE_BDR]', '[case when ISNULL(CODICE_BDR,'''')='''' then CodiceAIC else CODICE_BDR end as CODICE_BDR]')
		set @ListColumn=REPLACE(@ListColumn,'[CODICE_BDR]', 'case when ISNULL(CODICE_BDR,'''')='''' then CodiceAIC else CODICE_BDR end')


		--select top 10 CODICE_CPV, DESCRIZIONE_CODICE_CPV 
		--from Document_MicroLotti_Dettagli 
		--where CODICE_CPV is not null
	
	--select @ListColumn

	--da togliere appena ho risolto dove configurare
	--if @TipoListino = 'Ordinativi'
	--	set @ListColumn = ' [AMBITO] as [AMBITO] , [CODICEFISCALE] as [CODICE FISCALE OPERATORE ECONOMICO] , [DATAFINE] as [DATA FINE VALIDITÀ LISTINO] , [DATAINVIO] as [DATA INIZIO VALIDITÀ LISTINO] , [TITOLO] as [NOME CONVENZIONE] , [NUMEROCONVENZIONE] as [NUMERO CONVENZIONE] , [PARTITAIVA] as [PARTITA IVA OPERATORE ECONOMICO] , [RAGIONESOCIALE] as [RAGIONE SOCIALE OPERATORE ECONOMICO] , [ALTRE_CARATTERISTICHE] as [ALTRE CARATTERISTICHE] , [CODICEAIC] as [CODICE AIC] , [CIG] as [CODICE CIG] , [CODICE_REGIONALE] as [CODICE REGIONALE] , [NUMEROREPERTORIO] as [CODICE REPERTORIO] , [CODICE_ARTICOLO_FORNITORE] as [CODIFICA ARTICOLO OPERATORE ECONOMICO] , [CONTENUTO_DI_UM_CONFEZIONE] as [CONTENUTO DI UM PER CONFEZIONE] , [CODICE_CPV] as [CPV] , [DENOMINAZIONE_ARTICOLO_FORNITORE] as [DENOMINAZIONE ARTICOLO OPERATORE ECONOMICO] , [DESCRIZIONE_CODICE_REGIONALE] as [DESCRIZIONE CODICE REGIONALE] , [DESCRIZIONE] as [DESCRIZIONE LOTTO] , [FORMAFARMACEUTICA] as [FORMA FARMACEUTICA] , [ALIQUOTAIVA] as [IVA (%)] , [LIVELLO] as [LIVELLO] , [MONOUSO] as [MONOUSO] , [NOTELOTTO] as [NOTE AGENZIA] , [NUMEROLOTTO] as [NUMERO LOTTO] , [PREZZO_OFFERTO_PER_UM] as [PREZZO OFFERTO PER UM IVA ESCLUSA] , [PRINCIPIOATTIVO] as [PRINCIPIO ATTIVO] , [STERILE] as [STERILE] , [SUBORDINATO] as [SUBORDINATO] , [TIPO_REPERTORIO] as [TIPO REPERTORIO] , [UNITADIMISURA] as [UM OGGETTO INIZIATIVA] , [SOMMINISTRAZIONE] as [VIA DI SOMMINISTRAZIONE] , [ARTICOLIPRIMARI] as [ARTICOLI PRIMARI] , [VOCE] as [NUMERO VOCE] , [CODICE_CND] as [CND] '

	--if @TipoListino = 'Ordini'
	--	set @ListColumn = ' [AMBITO] as [AMBITO] , [CODICEFISCALE] as [CODICE FISCALE OPERATORE ECONOMICO] , [DATAFINE] as [DATA FINE VALIDITÀ LISTINO] , [DATAINVIO] as [DATA INIZIO VALIDITÀ LISTINO] , [TITOLO] as [NOME CONVENZIONE] , [NUMEROCONVENZIONE] as [NUMERO CONVENZIONE] , [PARTITAIVA] as [PARTITA IVA OPERATORE ECONOMICO] , [RAGIONESOCIALE] as [RAGIONE SOCIALE OPERATORE ECONOMICO] , [ALTRE_CARATTERISTICHE] as [ALTRE CARATTERISTICHE] , [CODICEAIC] as [CODICE AIC] , [CIG] as [CODICE CIG] , [CODICE_EAN] as [CODICE EAN/GTIN/UDI] , [CODICE_REGIONALE] as [CODICE REGIONALE] , [NUMEROREPERTORIO] as [CODICE REPERTORIO] , [CODICE_ARTICOLO_FORNITORE] as [CODIFICA ARTICOLO OPERATORE ECONOMICO] , [CONTENUTO_DI_UM_CONFEZIONE] as [CONTENUTO DI UM PER CONFEZIONE] , [DENOMINAZIONE_ARTICOLO_FORNITORE] as [DENOMINAZIONE ARTICOLO OPERATORE ECONOMICO] , [DESCRIZIONE_CODICE_REGIONALE] as [DESCRIZIONE CODICE REGIONALE] , [DESCRIZIONE] as [DESCRIZIONE LOTTO] , [DIMENSIONI_CONFEZIONE] as [DIMENSIONI CONFEZIONE] , [FORMAFARMACEUTICA] as [FORMA FARMACEUTICA] , [FTALATI_FREE] as [FTALATI FREE] , [INFIAMMABILE] as [INFIAMMABILE] , [ALIQUOTAIVA] as [IVA (%)] , [LATEX_FREE] as [LATEX FREE] , [LIVELLO] as [LIVELLO] , [MISURE] as [MISURE] , [MONOUSO] as [MONOUSO] , [NUMEROLOTTO] as [NUMERO LOTTO] , [PESO_CONFEZIONE] as [PESO CONFEZIONE] , [PREZZO_OFFERTO_PER_UM] as [PREZZO OFFERTO PER UM IVA ESCLUSA] , [PRINCIPIOATTIVO] as [PRINCIPIO ATTIVO] , [SCHEDA_DI_SICUREZZA] as [SCHEDA DI SICUREZZA] , [SCHEDA_PRODOTTO] as [SCHEDA PRODOTTO] , [SCHEDA_TECNICA_PRODOTTO] as [SCHEDA TECNICA/PRODOTTO] , [SOSTANZA_CORROSIVA] as [SOSTANZA CORROSIVA] , [SOSTANZA_TOSSICA] as [SOSTANZA TOSSICA] , [SOSTANZA_VELENOSA] as [SOSTANZA VELENOSA] , [STERILE] as [STERILE] , [SUBORDINATO] as [SUBORDINATO] , [TEMPERATURA_CONSERVAZIONE] as [TEMPERATURA DI CONSERVAZIONE] , [TIPO_REPERTORIO] as [TIPO REPERTORIO] , [UNITADIMISURA] as [UM OGGETTO INIZIATIVA] , [SOMMINISTRAZIONE] as [VIA DI SOMMINISTRAZIONE] , [VOLUME] as [VOLUME] , [ARTICOLIPRIMARI] as [ARTICOLI PRIMARI] , [VOCE] as [NUMERO VOCE] , [CODICE_CND] as [CND] '

	-- se sto trattando un listino ordini vedo se esite il listino ordini 
	-- associato alla convenzione  “Presenza Listino Ordini” = si
	-- se esite i prodotti sono quelli del listino ordini
	-- altrimenti i prodotti da recuperare sono sempre quelli della convenzione
	
	
	-- 22/06/2023
	-- questo ragionamento adesso va omesso perchè con l'estrazione precedente della data inizio listino
	-- in base alle modifiche subito non bisogna più usare il documento LISTINO_ORDINI nel filtro finale
	-- altrimenti non escono record
	-- OPPURE SE SI RIPRISTINA QUESTO RAGIONAMENTO BISOGNA AGGIUNGERE DENTRO L'IF come ultima istruzione
	-- L'UPDATE DI SOTTO [1] CHE CALCOLA GLI ID GIUSTI DELLA MICROLOTTI

	--if @TipoListino = 'ordini' and @PresenzaListinoOrdini = 'si'
	--begin
		
	--	select @IdDoc_Estrazione = id
	--			from CTL_DOC with (nolock)
	--				where linkeddoc = @IdConv and TipoDoc='LISTINO_ORDINI' 
	--					and StatoFunzionale ='Confermato' and Deleted = 0	
				
	--	set @TipoDoc_Estrazione = 'LISTINO_ORDINI'	
	--end

	--- INIZIO [1]

	--if @IdDoc_Estrazione > 0
	--	update #temp_data_ini_convenzione
	--		set IdRiga = c.id
	--		from #temp_data_ini_convenzione a
	--		inner join document_microlotti_dettagli b on a.IdRiga=b.id 
	--		inner join CTL_DOC d on d.LinkedDoc = b.IdHeader and d.Deleted = 0 and d.TipoDoc = 'LISTINO_ORDINI'
	--		inner join document_microlotti_dettagli c on c.TipoDoc = 'LISTINO_ORDINI'  and c.IdHeader = d.id
	--														and c.IdRigaRiferimento = cast(b.IdHeader as varchar(10)) + '-' + cast(b.NumeroRiga  as varchar(10))
	--		where b.tipodoc='convenzione'
	--		and b.StatoRiga in ('','saved','inserito','variato')  
	--		and c.StatoRiga in ('','saved','inserito','variato')  

	--- END [1]
	-- 22/06/2023
	
	
	

	--devo risolvere i domini chiusi (4,5,8)
	--creo tabella temporanea con i domini e con le codifiche dei codici
	CREATE TABLE #Codifiche_Codici_Dominio 
	(
		Dominio varchar(200) COLLATE database_default,
		codice varchar(600) COLLATE database_default,
		codifica nvarchar(max) COLLATE database_default
	)
	
	select column_name into #Column_Of_Table from information_schema.columns where table_name = @Table

	--creo un indice sulla tabella temporanea per dominio e codice
	CREATE INDEX IXTEMP ON #Codifiche_Codici_Dominio(Dominio,codice)

	--creo tabella temporanea con gli attributi da trattare
	CREATE TABLE #Model_Temp
	(
		MA_DZT_Name varchar(100) COLLATE database_default,
		Format_DZT_name varchar(500) COLLATE database_default
	)
	--popolo la tabella con gli attributi da trattare
	INSERT INTO #Model_Temp ( MA_DZT_Name, Format_DZT_name )
	select
		L.DZT_Name , isnull(L.DZT_Format,'') as DZT_Forma 
		from 
			dbo.Split( @ListColumn , ' , ' )  M
			inner join LIB_Dictionary L on  
					--ogni item è nella forma [Col1] as [Desc 1] la prima parte è l'attributo
					--L.DZT_Name = substring( ltrim(rtrim(M.items)) ,1 , charindex (' as ' , ltrim(rtrim(M.items))) )
					L.DZT_Name = replace ( replace( substring( ltrim(rtrim( M.items )) , 1 , charindex (' as ' , ltrim(rtrim(M.items)) ) ) , '[' ,'' ) , ']' , '')
			--inner join #Column_Of_Table with (nolock) on column_name = L.DZT_Name
	

	--select * from #Model_Temp
		
	--inserisco le codifiche dei domini senza query 
	--nella tabella temporanea #Codifiche_Codici_Dominio
	INSERT INTO #Codifiche_Codici_Dominio ( Dominio, codice, codifica )
		select 
			distinct 
			DV.DMV_DM_ID,	 DV.DMV_Cod ,
			case
				when Format_DZT_name = '' then isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 
				--solo il codice esterno
				when CHARINDEX( 'D', Format_DZT_name )=0 and CHARINDEX( 'C', Format_DZT_name ) > 0 then isnull(DMV_CodExt,'') 
				--solo la desc
				when CHARINDEX( 'D', Format_DZT_name )>0 and CHARINDEX( 'C', Format_DZT_name ) =0 then isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 
				--codice esterno e desc
				when CHARINDEX( 'D',Format_DZT_name ) >0 and CHARINDEX( 'C', Format_DZT_name ) > 0 then isnull(DMV_CodExt,'') + ' – ' + isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 
			 
				else
					isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 

			end as Codifica_Codice_Dominio

		from 
			#Model_Temp M with (nolock)
				inner join LIB_Dictionary L with (nolock) on L.DZT_Name = M.MA_DZT_Name and L.dzt_type in ( 4,5,8 )
				inner join LIB_Domain D  with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')=''	
				left join LIB_DomainValues DV  with (nolock)  on DV.DMV_DM_ID = D.DM_ID
				left outer join dbo.LIB_Multilinguismo mlg  with (nolock)  on DMV_DescML = ML_KEY and ML_LNG=@Lng


	--costruisco la insert dimanica per codificare i domini che hanno una query dinamica
	DECLARE crsDinamici CURSOR STATIC FOR 
 			
		select 
			dm_id,cast(dm_query as nvarchar(max)),Format_DZT_name
			from 
				#Model_Temp M with (nolock) 
					inner join LIB_Dictionary L  with (nolock) on L.DZT_Name = M.MA_DZT_Name and L.dzt_type in ( 4,5,8 )
					inner join LIB_Domain D  with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')<>''	

	OPEN crsDinamici

	FETCH NEXT FROM crsDinamici INTO @dm_id, @dm_query, @FormatDinamici
	WHILE @@FETCH_STATUS = 0
	BEGIN 
			 
		if charindex( ' order by' , @dm_query ) > 0 
		begin 
		set @dm_query = left( @dm_query , charindex( ' order by' , @dm_query ) )
		end

		if charindex( 'order by' , @dm_query ) > 0 
		begin 
		set @dm_query = left( @dm_query , charindex( 'order by' , @dm_query )-1 )
		end

		--sostutisco la lingua per avere le desc in lingua
		set @dm_query = replace(@dm_query,'#LNG#',@Lng)


		set @Sql_Insert_Dinamici = '

			INSERT INTO #Codifiche_Codici_Dominio ( Dominio, codice, codifica )
			
			select 
			
				''' + @dm_id + ''',	 DMV.DMV_Cod ,
				    
				case
					when ''' + @FormatDinamici + ''' ='''' then cast( DMV_DescML as nvarchar( max)) 
					--solo il codice esterno
					when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) = 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) > 0 then isnull(DMV_CodExt,'''') 
					--solo la desc
					when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) > 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) = 0 then cast( DMV_DescML as nvarchar( max)) 
					--codice esterno e desc
					when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) > 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) > 0 then isnull(DMV_CodExt,'''') + '' - '' + cast( DMV_DescML as nvarchar( max)) 
			 
					else
						cast( DMV_DescML as nvarchar( max)) 

				end as Codifica_Codice_Dominio

				from 
					( '  + @dm_query + ' ) as DMV
					left  outer join #Codifiche_Codici_Dominio CONTR with (nolock) on CONTR.Dominio=''' + @dm_id + '''
					where CONTR.Dominio IS NULL
					'
			    	
			--print  @Sql_Insert_Dinamici
    				
			exec(@Sql_Insert_Dinamici)

		FETCH NEXT FROM crsDinamici INTO @dm_id, @dm_query, @FormatDinamici

	END

	CLOSE crsDinamici 
	DEALLOCATE crsDinamici 


	--aggiusto dinamicamente le colonne per la select 
	--[Col1] as [Desc 1]
	--e costruisco le left join sulla tabella dei domini temporanea 
	--da aggiungere alla tabella base per ogni attributo a dominio
	
	set @Cont=0
	set @LeftJoinDomain=''
	set @NomiColonneFrom=@ListColumn 
		
	select 
				
		@NomiColonneFrom = REPLACE (
									@NomiColonneFrom , 
									'[' + Ma_DZT_Name + '] as [', 
									'isnull (Cod_' +  cast(@Cont as varchar) + '.codifica,' + Ma_DZT_Name + ') as [')
					
		, @LeftJoinDomain = @LeftJoinDomain +
								' left join #Codifiche_Codici_Dominio Cod_' +  cast(@Cont as varchar) 
													+ ' on  Cod_' +  cast(@Cont as varchar) + '.Dominio = ''' + L.DZT_DM_ID + ''' and Cod_' +  cast(@Cont as varchar) + '.Codice=' + MA.ma_dzt_name + char(13) + char(10)
				  
		, @Cont = @Cont +1
		  	 
		from 
			#Model_Temp MA	
				inner join LIB_Dictionary L with (nolock) on L.DZT_Name = MA.MA_DZT_Name and  L.DZT_Type in (4,5,8)

		order 
			by ma_dzt_name
	
	--sostituisco alla colonna IdRigaRiferimentoCSV  IdRigaRiferimento che è il nome della colonna sulla document_microlotti_dettagli
	set @NomiColonneFrom = REPLACE ( @NomiColonneFrom , 'IdRigaRiferimentoCSV' , 'IdRigaRiferimento')
	set @LeftJoinDomain = REPLACE ( @LeftJoinDomain , 'IdRigaRiferimentoCSV' , 'IdRigaRiferimento')

	--costruisco la query dinamica per estrarre i prodotti
	set @SqlEstract = 'SELECT 
							' + @NomiColonneFrom  + '
							FROM 
								#temp_info_convenzione
									cross join document_microlotti_dettagli with (nolock)
									' + @LeftJoinDomain + '
									inner join #temp_data_ini_convenzione_' + @TipoDoc_Estrazione + ' on IdRiga=document_microlotti_dettagli.id
							WHERE

								idheader = ' + CAST(@IdDoc_Estrazione as varchar (50)) + '
								and TipoDoc = ''' + @TipoDoc_Estrazione  + '''
								and StatoRiga in ('''',''saved'',''inserito'',''variato'')
							
							ORDER BY Cig, NumeroRiga '

	--select 		@SqlEstract		
	exec (@SqlEstract)					

	drop table #temp_info_convenzione
	drop table #Codifiche_Codici_Dominio
	drop table #Column_Of_Table
	drop table #Model_Temp
	
	IF OBJECT_ID(N'tempdb..##temp_data_ini_convenzione_LISTINO_ORDINI') IS NOT NULL
	BEGIN
		drop table #temp_data_ini_convenzione_LISTINO_ORDINI
	END

	IF OBJECT_ID(N'tempdb..#temp_data_ini_convenzione_CONVENZIONE') IS NOT NULL
	BEGIN
		drop table #temp_data_ini_convenzione_CONVENZIONE
	END

	--select * from #Model_Temp

END
GO
