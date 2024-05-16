USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANALISI_DOMANDA_QUESTIONARIO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[ANALISI_DOMANDA_QUESTIONARIO]	( @idDocAnalisi int , @Row varchar(20)  )
AS
BEGIN
	SET NOCOUNT ON;


	declare @Domanda		varchar(1000)
	declare @idBando		int
	declare @idPfu			int
	declare @Keyriga		varchar(100)
	declare @idDomanda		int
	declare @NewDoc			int
	declare @RowSezione		int
	
	declare @Domanda_Tipologia	varchar(100)
	declare @Domanda_Natura		varchar(100)
	declare @Fabb_Operazioni	varchar(100)
	declare  @ModelloDomanda	varchar(1000)
	declare @Sezione nvarchar(max)
	

	declare @DSE_ID varchar(200)
	declare @SQL nvarchar(max)	

	-- recupero il codice della domanda
	select  @idBando = linkeddoc , @idPfu = idpfu  from ctl_doc where id = @idDocAnalisi
	select  @Domanda = value from CTL_DOC_Value where IdHeader = @idDocAnalisi and DSE_ID = 'VALORI' and Row = @Row and DZT_Name = 'Domanda_Elenco' 
	select  @Keyriga = value from CTL_DOC_Value where IdHeader = @idDocAnalisi and DSE_ID = 'VALORI' and Row = @Row and DZT_Name = 'KeyRiga' 
	
	select  @idDomanda = id from ctl_doc where cast( guid as varchar(1000))= replace( @Domanda , '_' , '-' ) 
	select @Domanda_Tipologia =  value  from CTL_DOC_Value where IdHeader = @idDomanda and DSE_ID = 'TIPOLOGIA' and DZT_Name = 'Domanda_Tipologia' 
	select @Domanda_Natura  = value from CTL_DOC_Value where IdHeader = @idDomanda and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'Domanda_Natura' 
	select @Fabb_Operazioni = value  from CTL_DOC_Value where IdHeader = @idDomanda and DSE_ID = 'ATTRIBUTO' and DZT_Name = 'Fabb_Operazioni' 

	-- recupero la descrizione della sezione - la prima riga inferiore alla domanda con la descrizione
	select @RowSezione = max( Row ) from CTL_DOC_Value where IdHeader = @idDocAnalisi and DSE_ID = 'VALORI' and DZT_Name = 'Descrizione' and Value <> '' and Row < @Row 
	select @Sezione = value from CTL_DOC_Value where IdHeader = @idDocAnalisi and DSE_ID = 'VALORI' and Row = @RowSezione and DZT_Name = 'KeyRiga' 
	select @Sezione = @Sezione  + ' - ' + value from CTL_DOC_Value where IdHeader = @idDocAnalisi and DSE_ID = 'VALORI' and Row = @RowSezione and DZT_Name = 'Descrizione' 

	
	set  @ModelloDomanda =  'QUESTIONARIO_DOMANDA_' + @Domanda


	-- verifico se il documento esiste, in questo caso lo cancello
	update CTL_DOC set deleted = 1 where linkeddoc = @idBando and TipoDoc = 'ANALISI_DOMANDA' and JumpCheck = @Domanda

	-- crea il documento relativo alla domanda
	insert into CTL_DOC ( IdPfu , TipoDoc , Data ,  LinkedDoc  , IdDoc , titolo , Body ,note , JumpCheck , Caption ) 
		select  @idPfu , 'ANALISI_DOMANDA' , getdate() ,  @idBando , @idDocAnalisi , left( @Keyriga , 150 ) , Body , Note, @Domanda , left( @Sezione , 255 )
			from CTL_DOC 
			where id = @idDomanda

	set @NewDoc = @@identity
	

	-- inserisco il collegamento nel documento di analisi per consentirne l'apertura
	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
		values( @idDocAnalisi , 'VALORI' , @Row ,  'VALORIGrid_ID_DOC', @NewDoc ) 

	
	-- associa il modello per la rappresentazione dei dati inputati
	INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
		SELECT @NewDoc , 'ORIGINE' , 'QUESTIONARIO_DOMANDA_' + @Domanda + '_ANALISI'
			

	------------------------------------------------------------------------
	-- riporta tutti i dati compilati per visualizzarli in un unica soluzione
	------------------------------------------------------------------------
	declare @ixRow INT
	declare @Azienda int 
	declare @iRow int 
	declare @CurAzienda int 
	declare @CurRow int 
	declare @DZT_Name varchar(1000)
	declare @Value varchar(max)	
	declare @CurValue varchar(max)

	set @CurAzienda =-1
	set @CurRow = -1
	set @ixRow = -1

	declare CurRiga Cursor static for 
		select r.Azienda , Row, DZT_Name, Value
		from ctl_doc B -- bando
			inner join document_bando ba on ba.idheader = b.id
			inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended' 
				
			inner join CTL_DOC_Value v on v.idheader = r.id and DSE_ID = 'SEZ_' + @Row --@Domanda

		where B.id = @idBando
		order by  v.Row, r.id  , DZT_Name

	open CurRiga

	FETCH NEXT FROM CurRiga INTO @Azienda , @iRow, @DZT_Name, @Value
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		if @Azienda <> @CurAzienda or @CurRow <> @iRow
		begin
			set @ixRow = @ixRow + 1

			-- inserisce il record per l'azienda
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values( @NewDoc , 'ORIGINE' , @ixRow ,  'Aziende', @Azienda )

		end
		set @CurAzienda =@Azienda
		set @CurRow = @iRow



		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			values( @NewDoc , 'ORIGINE' , @ixRow ,  @DZT_Name, @Value ) 
	             
		FETCH NEXT FROM CurRiga INTO @Azienda , @iRow, @DZT_Name, @Value
	END 
	CLOSE CurRiga
	DEALLOCATE CurRiga

	------------------------------------------------------------------------
	-- SVUOTA i dati ridondanti delle righe per rendere più leggibile i dati
	------------------------------------------------------------------------
	begin 
		select idRow , Value , Row
			into #TempDelete
				from CTL_DOC_Value 
				where IdHeader = @NewDoc and  DSE_ID = 'ORIGINE' and DZT_Name = 'Descrizione'
				order by  Row 

		declare CurRiga Cursor static for  select idRow , Value from #TempDelete order by Row
		open CurRiga

		FETCH NEXT FROM CurRiga INTO  @iRow, @Value
		set @CurValue = ''         

		WHILE @@FETCH_STATUS = 0
		BEGIN

			if @CurValue = @Value
				update CTL_DOC_Value set Value = '' where IdRow = @iRow
	     
			set @CurValue = @Value         
			FETCH NEXT FROM CurRiga INTO  @iRow, @Value
		END 
		CLOSE CurRiga
		DEALLOCATE CurRiga

	end



	------------------------------------------------------------------------
	-- effettuo i calcolo dell'analisi relativa
	------------------------------------------------------------------------
	if @Domanda_Natura = 'Numero'
	begin

	
		if @Domanda_Tipologia = 'Singola'
			set @DSE_ID = 'SINGOLA_NUMERO'
		else
			set @DSE_ID = 'MULTI_NUMERO'

		-- prendendo tutte le risposte ed applicando la formula
		set @SQL = ' insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select  ' + cast( @NewDoc as varchar(20)) + ' , ''' + @DSE_ID + ''' , isnull( Row  , 0 ) ,  ''CampoNumerico'' , ' +
						case 
						when @Fabb_Operazioni = 'min' then ' min( cast( v.Value as float ) ) as Value '
						when @Fabb_Operazioni = 'max' then ' max( cast( v.Value as float ) ) as Value '
						when @Fabb_Operazioni = 'media' then ' avg( cast( v.Value as float ) ) as Value '
						when @Fabb_Operazioni = 'somma' then ' sum( cast( v.Value as float ) ) as Value '
						end 
						+ 

					' from ctl_doc B -- bando
						inner join document_bando ba on ba.idheader = b.id
						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  ''Sended''
				
						inner join CTL_DOC_Value v on v.idheader = r.id and DSE_ID = ''SEZ_' + @Row + '''

					where B.id = ' + cast( @idBando as varchar(20)) + ' and dzt_name = ''DOMANDA_QUESTIONARIO_Numero_1'' 
					group by isnull( Row  , 0 ) , DZT_Name
'

		exec ( @SQL )

		-- inserisco la descrizione della riga se presente
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select   @NewDoc , @DSE_ID , min( Row ) ,  dzt_name , Value
				from CTL_DOC_VALUE 
				where idheader = @idDomanda and DSE_ID = 'RIGHE' and dzt_name = 'Descrizione' 
				group by dzt_name , Value



		-- inserisco la formula
		 insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select  @NewDoc , @DSE_ID , 0 ,  'Fabb_Operazioni' , @Fabb_Operazioni


	end

	if @Domanda_Natura = 'Dominio'
	begin


		if @Domanda_Tipologia = 'Singola'
			set @DSE_ID = 'SINGOLA_DOMINIO'
		else
			set @DSE_ID = 'MULTI_DOMINIO'



		declare @NumElem int

		-- determina il numero di elementi del dominio
		select @NumElem = max( row ) + 1 from CTL_DOC_Value where  IdHeader = @idDomanda and DZT_Name = 'Descrizione'  and DSE_ID = 'VALORI'
		-- se la domanda prevede altro
		if exists( select * from CTL_DOC_Value where IdHeader = @idDomanda and DZT_Name = 'Dominio_Altro'  and DSE_ID = 'ATTRIBUTO' and Value = '1' )
			set @NumElem  = @NumElem  + 1 


		-- se il dominio non è a lista
		if exists( select * from CTL_DOC_Value where IdHeader = @idDomanda and DZT_Name = 'Domanda_Dom_Visual'  and DSE_ID = 'ATTRIBUTO' and Value <> 'List' ) 
		begin

			
			------------------------
			-- determino la somma
			------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select 

					 @NewDoc ,@DSE_ID , isnull( el.row , @NumElem - 1 ) + ( v.row * @NumElem ) as [Row] ,   'CampoNumerico_2' as DZT_Name ,  sum( case when v.Value <> '' and v.Value <> '0' then 1 else 0 end ) as Value  


					from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi

						left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
						left outer join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI' and el.value = m.MA_DescML -- determino la presenza dei valori del dominio per posizionare i dati

						inner join ctl_doc B on B.id = @idBando -- bando
						inner join document_bando ba on ba.idheader = b.id -- il bando serve per raccogliere le risposte

						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended'
						inner join CTL_DOC_Value v on v.idheader = r.id and v.DSE_ID =  'SEZ_' + @Row and m.MA_DZT_Name = v.DZT_Name and v.Row = isnull( rw.Row , 0 )   -- dalla risposta solo la sezione relativa alla domanda per la colonna del modello

					where m.MA_DZT_Name <> 'Descrizione' and m.MA_MOD_ID = @ModelloDomanda

					group by v.Row    , v.DZT_Name	, el.row  
					order by   isnull( el.row , @NumElem - 1 ) + ( v.row * @NumElem )



			------------------------
			-- determino la %
			------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select 

					 @NewDoc ,@DSE_ID , isnull( el.row , @NumElem - 1 ) + ( v.row * @NumElem ) as [Row] ,   'CampoNumerico_1' as DZT_Name ,  ( cast( sum( case when v.Value <> '' and v.Value <> '0' then 1.0 else 0.0 end ) as float)  / cast( count (*) as float )  ) * 100.0 as Value  


					from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi

						left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
						left outer join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI' and el.value = m.MA_DescML -- determino la presenza dei valori del dominio per posizionare i dati

						inner join ctl_doc B on B.id = @idBando -- bando
						inner join document_bando ba on ba.idheader = b.id -- il bando serve per raccogliere le risposte

						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended'
						inner join CTL_DOC_Value v on v.idheader = r.id and v.DSE_ID = 'SEZ_' +  @Row and m.MA_DZT_Name = v.DZT_Name and v.Row = isnull( rw.Row , 0 )   -- dalla risposta solo la sezione relativa alla domanda per la colonna del modello

					where m.MA_DZT_Name <> 'Descrizione' and m.MA_MOD_ID = @ModelloDomanda

					group by v.Row    , v.DZT_Name	, el.row  
					order by   isnull( el.row , @NumElem - 1 ) + ( v.row * @NumElem )


			--------------------------
			---- aggiungo i valori per descrivere i dati sia di righe che di colonne
			--------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select 

					@NewDoc ,@DSE_ID , isnull( el.row , @NumElem - 1 ) + ( isnull( rw.row , 0 )  * @NumElem ) as [Row] ,   'Elemento_Dominio' as DZT_Name , isnull( el.Value , 'Altro' ) as Value 


				from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi

					left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
					left outer join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI' and el.value = m.MA_DescML -- determino la presenza dei valori del dominio per posizionare i dati


				where m.MA_DZT_Name <> 'Descrizione' and m.MA_MOD_ID = @ModelloDomanda
				order by   isnull( el.row , @NumElem - 1 ) + ( rw.row * @NumElem )

			---- descrizione della riga
			--insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			--select @NewDoc ,@DSE_ID , /*isnull( el.row , @NumElem - 1 ) +*/ ( rw.row * @NumElem ) as [Row] ,   'Descrizione' as DZT_Name , rw.Value  
			--	from CTL_DOC_Value rw 
			--	WHERE rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
			--	order by   ( rw.row * @NumElem )

		END
		else -- quando il dominio si presenta a lista
		begin

			--print 'set @ModelloDomanda = ''' + @ModelloDomanda + ''''
			--print ' set @NumElem = ' + cast( @NumElem as varchar ) 
			--print ' set @DSE_ID = ''' +  @DSE_ID + ''''
			--print 'set @idDomanda = ' + cast ( @idDomanda as varchar) 
			--print 'set @idBando = ' + cast ( @idBando as varchar) 

			------------------------
			-- determino la somma
			------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select  

					 @NewDoc ,@DSE_ID , isnull( el.row , @NumElem - 1 ) + (isnull( rw.row , 0 ) * @NumElem ) as [Row] ,   'CampoNumerico_2' as DZT_Name ,  sum( case when isnull( v.Value , '' ) <> '' and v.Value <> '0' then 1 else 0 end ) as Value  

					from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi in questo caso il solo dominio

						left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
						inner join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI'  -- determino la riga del valore selezionato per incasellarlo

						inner join ctl_doc B on B.id = @idBando -- bando
						inner join document_bando ba on ba.idheader = b.id -- il bando serve per raccogliere le risposte

						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended'
						left outer join CTL_DOC_Value v on v.idheader = r.id and v.DSE_ID = 'SEZ_' +  @Row and m.MA_DZT_Name = v.DZT_Name and v.Row = isnull( rw.Row , 0 )   and  v.Value = @Domanda + '_' + cast( el.row as varchar(20))-- dalla risposta solo la sezione relativa alla domanda per la colonna del modello



					where m.MA_DZT_Name = 'DOMANDA_QUESTIONARIO_Dominio_1' and m.MA_MOD_ID = @ModelloDomanda

					group by isnull( rw.row , 0 )    , v.DZT_Name	, el.row  
					order by   isnull( el.row , @NumElem - 1 ) + (  isnull( rw.row , 0 )* @NumElem )




			------------------------
			-- determino la %
			------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select 

					 @NewDoc ,@DSE_ID , isnull( el.row , @NumElem - 1 ) + (isnull( rw.row , 0 ) * @NumElem ) as [Row] ,   'CampoNumerico_1' as DZT_Name ,  ( cast( sum( case when isnull( v.Value , '' ) <> '' and v.Value <> '0' then 1.0 else 0.0 end ) as float)  / cast( count (*) as float )  ) * 100.0 as Value  


					from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi in questo caso il solo dominio

						left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
						inner join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI'  -- determino la riga del valore selezionato per incasellarlo

						inner join ctl_doc B on B.id = @idBando -- bando
						inner join document_bando ba on ba.idheader = b.id -- il bando serve per raccogliere le risposte

						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended'
						left outer join CTL_DOC_Value v on v.idheader = r.id and v.DSE_ID = 'SEZ_' +  @Row and m.MA_DZT_Name = v.DZT_Name and v.Row = isnull( rw.Row , 0 )   and  v.Value = @Domanda + '_' + cast( el.row as varchar(20))-- dalla risposta solo la sezione relativa alla domanda per la colonna del modello



					where m.MA_DZT_Name = 'DOMANDA_QUESTIONARIO_Dominio_1' and m.MA_MOD_ID = @ModelloDomanda

					group by isnull( rw.row , 0 )    , v.DZT_Name	, el.row  
					order by   isnull( el.row , @NumElem - 1 ) + (  isnull( rw.row , 0 )* @NumElem )


			------------------------
			-- determino la somma per ALTRO
			------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select  

					 @NewDoc ,@DSE_ID ,  @NumElem - 1  + (isnull( rw.row , 0 ) * @NumElem ) as [Row] ,   'CampoNumerico_2' as DZT_Name ,  sum( case when isnull( v.Value , '' ) <> ''  then 1 else 0 end ) as Value  

					from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi in questo caso il solo dominio

						left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
						--inner join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI'  -- determino la riga del valore selezionato per incasellarlo

						inner join ctl_doc B on B.id = @idBando -- bando
						inner join document_bando ba on ba.idheader = b.id -- il bando serve per raccogliere le risposte

						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended'
						left outer join CTL_DOC_Value v on v.idheader = r.id and v.DSE_ID = 'SEZ_' +  @Row and m.MA_DZT_Name = v.DZT_Name and v.Row = isnull( rw.Row , 0 )   -- dalla risposta solo la sezione relativa alla domanda per la colonna del modello



					where m.MA_DZT_Name = 'DOMANDA_QUESTIONARIO_ALTRO_1' and m.MA_MOD_ID = @ModelloDomanda

					group by isnull( rw.row , 0 )    , v.DZT_Name	
					order by  @NumElem - 1 + (  isnull( rw.row , 0 )* @NumElem )

			------------------------
			-- determino la % per ALTRO
			------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select  

					 @NewDoc ,@DSE_ID ,  @NumElem - 1  + (isnull( rw.row , 0 ) * @NumElem ) as [Row] ,   'CampoNumerico_1' as DZT_Name ,  ( cast( sum( case when isnull( v.Value , '' ) <> ''  then 1.0 else 0.0 end ) as float)  / cast( count (*) as float )  ) * 100.0 as Value  

					from CTL_ModelAttributes m -- dal modello si recuperano gli attributi elemento di analisi in questo caso il solo dominio

						left outer join CTL_DOC_Value rw on rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
						--inner join CTL_DOC_Value el on el.IdHeader = @idDomanda and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI'  -- determino la riga del valore selezionato per incasellarlo

						inner join ctl_doc B on B.id = @idBando -- bando
						inner join document_bando ba on ba.idheader = b.id -- il bando serve per raccogliere le risposte

						inner join CTL_DOC r on r.linkeddoc = B.id and r.TipoDoc = ba.TipoBando and r.statodoc =  'Sended'
						left outer join CTL_DOC_Value v on v.idheader = r.id and v.DSE_ID = 'SEZ_' +  @Row and m.MA_DZT_Name = v.DZT_Name and v.Row = isnull( rw.Row , 0 )   -- dalla risposta solo la sezione relativa alla domanda per la colonna del modello



					where m.MA_DZT_Name = 'DOMANDA_QUESTIONARIO_ALTRO_1' and m.MA_MOD_ID = @ModelloDomanda

					group by isnull( rw.row , 0 )    , v.DZT_Name	
					order by  @NumElem - 1 + (  isnull( rw.row , 0 )* @NumElem )


			--------------------------
			---- aggiungo i valori per descrivere i dati sia di righe che di colonne
			--------------------------
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @NewDoc ,@DSE_ID , isnull( el.row , @NumElem - 1 ) + ( isnull( rw.row , 0 )  * @NumElem ) as [Row] ,   'Elemento_Dominio' as DZT_Name , isnull( el.Value , 'Altro' ) as Value 
				from CTL_DOC d
					left outer join CTL_DOC_Value rw on rw.IdHeader = d.id and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE'  -- determino la presenza di righe nella domanda
					left outer join CTL_DOC_Value el on el.IdHeader = d.id and el.DZT_Name = 'Descrizione'  and el.DSE_ID = 'VALORI' -- determino la presenza dei valori del dominio per posizionare i dati
				where d.id = @idDomanda
				order by   isnull( el.row , @NumElem - 1 ) + ( rw.row * @NumElem )


			-- aggiungo la descrizione di altro se presente
			if exists( select * from CTL_DOC_Value where IdHeader = @idDomanda and DZT_Name = 'Dominio_Altro'  and DSE_ID = 'ATTRIBUTO' and Value = '1' )
				insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select @NewDoc ,@DSE_ID , @NumElem - 1  + ( isnull( rw.row , 0 )  * @NumElem ) as [Row] ,   'Elemento_Dominio' as DZT_Name ,  'Altro'  as Value 
					from CTL_DOC d
						left outer join CTL_DOC_Value rw on rw.IdHeader = d.id and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE'  -- 
					where d.id = @idDomanda
					order by   @NumElem - 1  + ( isnull( rw.row , 0 ) * @NumElem )


		END




		-- descrizione della riga
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
		select @NewDoc ,@DSE_ID , /*isnull( el.row , @NumElem - 1 ) +*/ ( rw.row * @NumElem ) as [Row] ,   'Descrizione' as DZT_Name , rw.Value  
			from CTL_DOC_Value rw 
			WHERE rw.IdHeader = @idDomanda and rw.DZT_Name = 'Descrizione'  and rw.DSE_ID = 'RIGHE' -- determino la presenza di righe nella domanda
			order by   ( rw.row * @NumElem )




	END

	-- conservo per il documento la tipologia di visualizzazione corretta
	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
	select @NewDoc , 'VISUALIZZAZIONE' , 0 , 'FOLDER' , @DSE_ID 


END



GO
