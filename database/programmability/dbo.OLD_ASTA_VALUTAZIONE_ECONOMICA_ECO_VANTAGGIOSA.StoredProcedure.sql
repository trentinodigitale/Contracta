USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ASTA_VALUTAZIONE_ECONOMICA_ECO_VANTAGGIOSA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_ASTA_VALUTAZIONE_ECONOMICA_ECO_VANTAGGIOSA] ( @idDoc int ) as
begin

	declare @IdLotto as Int 
	--declare @IdPFU as Int 
	declare @IdPDA as Int 
	declare @IdCom as Int 
	declare @pfuIdLng as Int 
	declare @Allegato as Varchar(255) 
	declare @StatoRiga as Varchar(255) 
	declare @NumeroLotto as Varchar(255) 

	--declare @idDoc int
	declare @idBando int
	declare @Criterio as varchar(100)
	declare @TipoDoc as varchar(100)
	declare @Fascicolo as varchar(100)

	declare @ListaModelliMicrolotti as varchar(500)
	declare @FormulaEconomica as nvarchar (4000)
	declare @strSql as nvarchar (4000)
	declare @strSqlExec as nvarchar (4000)

	declare @FormulaEcoSDA as nvarchar (4000)
	declare @MAX_PunteggioTecnico		float
	declare @MAX_PunteggioEconomico		float
	declare @ValoreEconomico			float
	declare @OffertaMigliore			float
	declare @PunteggioTecMin			float
	declare @Coefficiente_X				float
	declare @alfa						float

	declare @NumeroDecimali				varchar(20)
	declare @FieldBaseAsta				varchar(200)
	declare @FieldQuantita				varchar(200)


	declare @Valore_Offerta				float
	declare @Media_Valori_Offerti		float
	declare @Massimo_Valore_Offerta		float
	declare @Minimo_Valore_Offerta		float

	declare @Media_Sconti_Offerti		float
	declare @Massimo_Sconto_Offerta		float
	declare @Minimo_Sconto_Offerta		float
	declare @ScontoMigliore				float	
	declare @ScontoOfferto				float


	declare @Media_Ribassi_Offerti		float
	declare @Massimo_Ribasso_Offerta	float
	declare @Minimo_Ribasso_Offerta		float
	declare @ValoreEconomicoBaseAsta	float

					
	declare @idOfferta					int
	declare @idHeaderLotto				int
	 
	declare @MultiVoce					int

	--set @IdDoc=<ID_DOC> --47998--48294--
	--set @IdPFU=<ID_USER> --35774--

	--select @IdPDA = idheader , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli where id = @IdDoc
	
	-- determino se il lotto è a voci multiple
	--set @MultiVoce = 0
	--if exists( select id from Document_MicroLotti_Dettagli where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 )
		set @MultiVoce = 1


	-- determino il criterio di calcolo economico definito sulla gara
	select  @TipoDoc = o.TipoDoc , @Criterio = b.criterioformulazioneofferte , @ListaModelliMicrolotti = b.TipoBando
			, @MAX_PunteggioEconomico = v1.Value
			, @MAX_PunteggioTecnico   = v2.Value
			, @FormulaEcoSDA          = v3.Value
			, @PunteggioTecMin		  = v4.Value
			, @Coefficiente_X		  = v5.Value
			, @NumeroDecimali		  = isnull( b.NumDec , 5 )
			--, @IdPDA = p.idheader
			, @idBando = o.LinkedDoc

			, @alfa					  = isnull(v6.value,0)

		FROM --Document_MicroLotti_Dettagli P
			--inner join ctl_doc o on p.idheader = o.id
			ctl_doc o 
				inner join dbo.Document_Bando b on o.LinkedDoc = b.idHeader
				inner join CTL_DOC_VALUE  v1 on v1.idheader = b.idHeader and v1.DSE_ID = 'CRITERI_ECO' and  v1.DZT_Name = 'PunteggioEconomico'
				inner join CTL_DOC_VALUE  v2 on v2.idheader = b.idHeader and v2.DSE_ID = 'CRITERI_ECO' and  v2.DZT_Name = 'PunteggioTecnico'
				inner join CTL_DOC_VALUE  v3 on v3.idheader = b.idHeader and v3.DSE_ID = 'CRITERI_ECO' and  v3.DZT_Name = 'FormulaEcoSDA'
				inner join CTL_DOC_VALUE  v4 on v4.idheader = b.idHeader and v4.DSE_ID = 'CRITERI_ECO' and  v4.DZT_Name = 'PunteggioTecMin'
				inner join CTL_DOC_VALUE  v5 on v5.idheader = b.idHeader and v5.DSE_ID = 'CRITERI_ECO' and  v5.DZT_Name = 'Coefficiente_X'
				left join CTL_DOC_VALUE  v6 on v6.idheader = b.idHeader and v6.DSE_ID = 'CRITERI_ECO' and  v6.DZT_Name = 'Alfa'

			where o.id= @IdDoc

	select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
		from Document_Modelli_MicroLotti_Formula 
		where @Criterio = CriterioFormulazioneOfferte
			and @ListaModelliMicrolotti = Codice


	-- prendo i criteri specializzati sul lotto se presenti
	select @MAX_PunteggioEconomico = PunteggioEconomico
			, @MAX_PunteggioTecnico   = PunteggioTecnico
			, @FormulaEcoSDA          = FormulaEcoSDA
			, @PunteggioTecMin		  = PunteggioTecMin
			, @Coefficiente_X		  = Coefficiente_X
		from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando --and N_Lotto = @NumeroLotto 

	
	------------------------------------------------------------
	---- determino il valore economico dei lotti offerti
	------------------------------------------------------------
	--exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO   @idDoc , @IdPFU 
	



	----------------------------------------------------------
	-- recupera i dati usati come parametri nelle formule
	----------------------------------------------------------
	--select @OffertaMigliore = min(O.ValoreImportoLotto )

	--			,@Media_Valori_Offerti = sum(O.ValoreImportoLotto ) / count(*)
	--			,@Massimo_Valore_Offerta = max(O.ValoreImportoLotto )
	--			,@Minimo_Valore_Offerta = min(O.ValoreImportoLotto )

	--			,@Media_Sconti_Offerti = sum(O.ValoreSconto ) / count(*)
	--			,@Massimo_Sconto_Offerta = max(O.ValoreSconto )
	--			,@Minimo_Sconto_Offerta = min(O.ValoreSconto )

	--			,@Media_Ribassi_Offerti = sum(O.ValoreRibasso ) / count(*)
	--			,@Massimo_Ribasso_Offerta = max(O.ValoreRibasso )
	--			,@Minimo_Ribasso_Offerta = min(O.ValoreRibasso )

	--			,@ScontoMigliore= max(O.ValoreSconto )

	--			from Document_MicroLotti_Dettagli P
	--			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader
	--			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme' ,  'verificasuperata' , '' ) and P.NumeroLotto = O.NumeroLotto
	--			where  
	--				P.ID = @IdDoc and O.Voce = 0

	select o.ValoreEconomico , o.ValoreSconto , o.ValoreRibasso into #Temp  
		from CTL_DOC d
			inner join Document_Asta_Rilanci o on d.LinkedDoc =  o.idheader
		where  
			d.ID = @IdDoc 

	-- aggiungo l'offerta corrente
	insert into #Temp ( ValoreEconomico , ValoreSconto , ValoreRibasso  )
		select  v1.Value , v2.Value , v3.Value 
			from CTL_DOC o
				inner join CTL_DOC_VALUE  v1 on v1.idheader = o.id and v1.DSE_ID = 'TOTALI' and v1.DZT_Name = 'ValoreEconomico' 
				inner join CTL_DOC_VALUE  v2 on v2.idheader = o.id and v2.DSE_ID = 'TOTALI' and v2.DZT_Name = 'ValoreSconto' 
				inner join CTL_DOC_VALUE  v3 on v3.idheader = o.id and v3.DSE_ID = 'TOTALI' and v3.DZT_Name = 'ValoreRibasso' 
			where o.id = @idDoc


	select @OffertaMigliore = min(O.ValoreEconomico )

				,@Media_Valori_Offerti = sum(O.ValoreEconomico ) / count(*)
				,@Massimo_Valore_Offerta = max(O.ValoreEconomico )
				,@Minimo_Valore_Offerta = min(O.ValoreEconomico )

				,@Media_Sconti_Offerti = sum(O.ValoreSconto ) / count(*)
				,@Massimo_Sconto_Offerta = max(O.ValoreSconto )
				,@Minimo_Sconto_Offerta = min(O.ValoreSconto )

				,@Media_Ribassi_Offerti = sum(O.ValoreRibasso ) / count(*)
				,@Massimo_Ribasso_Offerta = max(O.ValoreRibasso )
				,@Minimo_Ribasso_Offerta = min(O.ValoreRibasso )

				,@ScontoMigliore= max(O.ValoreSconto )

				from #Temp o



	----------------------------------------------------------
	-- per ogni fornitore calcolo il punteggio finale relativo al lotto
	----------------------------------------------------------
	--declare crs cursor static for 
	--		select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto , o.ValoreImportoLotto
	--			from Document_MicroLotti_Dettagli P
	--			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader
	--			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme' , 'verificasuperata' , '') and P.NumeroLotto = O.NumeroLotto
	--			where  
	--				P.ID = @IdDoc  and O.voce = 0


	--open crs 
	--fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @ValoreEconomico
	--while @@fetch_status=0 

	select @ValoreEconomico = value from CTL_DOC_Value where idheader = @idDoc and   [DSE_ID] = 'TOTALI' and DZT_Name = 'ValoreEconomico'
	select @ValoreEconomicoBaseAsta = value from CTL_DOC_Value where idheader = @idDoc and   [DSE_ID] = 'TOTALI' and DZT_Name = 'ValoreEconomicoBaseAsta'
	

	begin 


		-- seguo il calcolo del punteggio totale
		set @strSql = ' ' + @FormulaEcoSDA + ' '
		--print @strSql 
		SET @strSql = REPLACE( @strSql , ' Media Valori Offerti ' , '  cast( ' + str( @Media_Valori_Offerti ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Massimo Valore Offerta ' , '  cast( ' + str( @Massimo_Valore_Offerta ,40 ,20 ) + ' as float ) ' )
		SET @strSql = REPLACE( @strSql , ' Minimo Valore Offerta ' , '  cast( ' + str( @Minimo_Valore_Offerta ,40 ,20 ) + ' as float )  ' )

		SET @strSql = REPLACE( @strSql , ' Coefficiente X ' , ' cast( ' + str( @Coefficiente_X ,40 ,20 ) + ' as float )  ' )

		SET @strSql = REPLACE( @strSql , ' Alfa ' , ' cast( ' + str( @alfa ,40 ,20 ) + ' as float )  ' )
		
		SET @strSql = REPLACE( @strSql , ' Punteggio ' , ' cast( ' + str( @MAX_PunteggioEconomico ,40 ,20 ) + ' as float )  ' )

		SET @strSql = REPLACE( @strSql , ' Offerta Migliore ' , '  cast( ' + str( @OffertaMigliore ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Offerta Corrente ' , '  cast( ' + str( @ValoreEconomico ,40 ,20 ) + ' as float )  ' )

		SET @strSql = REPLACE( @strSql , ' Valore Offerta ' , '  cast( ' + str( @ValoreEconomico ,40 ,20 ) + ' as float )  ' )


		SET @strSql = REPLACE( @strSql , ' Sconto Corrente ' , '  ValoreSconto  ' )
		SET @strSql = REPLACE( @strSql , ' Massimo Sconto Offerto ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Sconto Offerto ' , '  ValoreSconto ' )
		SET @strSql = REPLACE( @strSql , ' Sconto Migliore ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Sconto Peggiore ' , '  cast( ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Media Sconti Offerti ' , '  cast( ' + str( @Media_Sconti_Offerti ,40 ,20 ) + ' as float )  ' )


		SET @strSql = REPLACE( @strSql , ' Ribasso Corrente ' , '  ValoreRibasso  ' )
		SET @strSql = REPLACE( @strSql , ' Massimo Ribasso Offerto ' , '  cast( ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Ribasso Offerto ' , '  ValoreRibasso ' )
		SET @strSql = REPLACE( @strSql , ' Ribasso Migliore ' , '  cast( ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Ribasso Peggiore ' , '  cast( ' + str( @Minimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
		SET @strSql = REPLACE( @strSql , ' Media Ribassi Offerti ' , '  cast( ' + str( @Media_Ribassi_Offerti ,40 ,20 ) + ' as float )  ' )

		SET @strSql = REPLACE( @strSql , ' Valore Base Asta ' , '  cast( ' + str( @ValoreEconomicoBaseAsta ,40 ,20 ) + ' as float )  ' )


		SET @strSql = REPLACE( @strSql , ' SE VERO CHE ' , ' case when ' )
		SET @strSql = REPLACE( @strSql , ' ALLORA ' , ' then ' )
		SET @strSql = REPLACE( @strSql , ' ALTRIMENTI ' , ' else ' )

		SET @strSql = REPLACE( @strSql , ' POTENZA ' , ' Power ' )

		if CHARINDEX ( ' case when ' , @strSql ) > 0 
		begin
			if CHARINDEX ( ' POI ' , @strSql ) > 0 
			begin
				SET @strSql = REPLACE( @strSql , ' POI ' , ' end ' )
			end
			else
			begin
				SET @strSql =  @strSql + ' end '
			end
		end 



		---- seguo il calcolo del punteggio totale
		--set @strSqlExec =  'Update 
		--	Document_MicroLotti_Dettagli
		--	set ValoreOfferta = str(  round( ( ' + @strSql + ' ) , 2 )   + PunteggioTecnico  , 30 , 20 ) 
		--	where tipodoc = ''PDA_OFFERTE'' and 
		--	id  = ' + cast( @IdLotto as varchar(20))


		delete from CTL_DOC_VALUE where idheader = @idDoc and dzt_name in ( 'PunteggioEconomico' ) and [DSE_ID] = 'TOTALI'

		set @strSqlExec =  'insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value ) values ( ' + cast( @idDoc as varchar(20)) + ' , ''TOTALI'' , 0 , ''PunteggioEconomico'' ,
				str(  ( ' + @strSql + ' )    , 30 , 20 )) '

		--print @strSqlExec
		exec ( @strSqlExec )


		--fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @ValoreEconomico
	end 
	--close crs 
	--deallocate crs


	-- determina la graduatoria del lotto
	--EXEC PDA_GRADUATORIA_LOTTO  @idPDA , @NumeroLotto 


end
















GO
