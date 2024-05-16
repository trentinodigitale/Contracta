USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CALCOLO_VALORE_CRITERIO_ECONOMICO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--USE [AFLink_PA_Dev]
--GO

--/****** Object:  StoredProcedure [dbo].[CALCOLO_VALORE_CRITERIO_ECONOMICO]    Script Date: 11/02/2016 10:04:32 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO




CREATE  proc [dbo].[OLD_CALCOLO_VALORE_CRITERIO_ECONOMICO] ( @idDoc int ) 
as
begin

	declare @idBando					int
	declare @tipoDoc					varchar(500) 
	declare @NumeroLotto				varchar(50)
	declare @AttributoValore			varchar(500)
	declare @SQLCalcoloValori			nvarchar(max)
	declare @CriterioFormulazioneOfferte	varchar(50)
	declare @idRow_V					int
	declare @AttributoBase				varchar(500)
	
	declare @PunteggioECO_TipoRip		varchar(50)
	declare @idModello					int
	declare @divisione_lotti			varchar(10)	
	declare @Complex					varchar(10)	
	declare @Ret						varchar(500)
	
	declare @idHeaderLottoOfferto int
	declare @IdPdA int

	--declare  @idDoc int
	--set @idDoc = 73527

	SELECT @idBando = LinkedDoc , @TipoDoc = TipoDoc from CTL_DOC with(nolock) where id = @idDoc
	if @TipoDoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP'
	BEGIN
	   select   @idBando=CPDA.LinkedDoc	
		  from ctl_doc C with(nolock)  --PDA_COMUNICAZIONE_OFFERTA_RISP
		  inner join ctl_doc C1 with(nolock)  on C1.id=C.LinkedDoc --PDA_COMUNICAZIONE_OFFERTA
		  inner join ctl_doc C2 with(nolock)  on C2.id=C1.LinkedDoc --PDA_COMUNICAZIONE
		  inner join ctl_doc CPDA with(nolock)  on CPDA.id=C2.LinkedDoc --PDA_MICROLOTTI
		where C.id = @idDoc 
	END
	if @TipoDoc like 'BANDO%'
		set @idBando = @idDoc
	
	--gestione nel caso di RETTIFICA VALORE ECONOMICO
	if @TipoDoc='RETT_VALORE_ECONOMICO'
	begin
		
		--recupero id header lotto offerto
		select @idHeaderLottoOfferto=idheader from document_microlotti_dettagli with(nolock)  where id=@idBando
		
		--recupero idpda
		select @IdPdA=idheader from DOCUMENT_PDA_OFFERTE with(nolock)  where idrow=@idHeaderLottoOfferto
		
		--recupero idbando
		select @idBando=linkeddoc from ctl_doc with(nolock)  where id=@IdPdA

		set @TipoDoc='RETT_VALORE_ECONOMICO_DEST'

	end

	-- se il bando è nella versione dalla 2
	if exists( select id from CTL_DOC with(nolock)  where id = @idBando and isnull( Versione , '' ) >= '2' )
	begin
		select @idModello = id  from ctl_doc with(nolock)  where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando
		select @divisione_lotti = divisione_lotti  , @Complex = Complex  from Document_Bando b  with(nolock)  where b.idHeader = @idBando

		-- le gare senza lotti sono state uniformate alle gare con voci
		if @divisione_lotti = 0
			set @divisione_lotti ='1'

		--if exists( select id from Document_MicroLotti_Dettagli where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 )
		select NumeroLotto into #TempLotti from Document_MicroLotti_Dettagli with(nolock)   where idheader = @idDoc and TipoDoc = @tipoDoc and Voce = 0 
		create table #TempValutaz ( idRowVal  int )

		-- per ogni lotto
		declare crs_L cursor static for 
			select  NumeroLotto
				from #TempLotti 
				order by NumeroLotto

		open crs_L 

		fetch next from crs_L into @NumeroLotto

		while @@fetch_status=0 
		begin 
			
			delete #TempValutaz
			 
			-- determina se i criteri di valutazione economica sono ripartiti per lotto e li colleziona in una tabella temporanea
			if exists(select d.id from Document_MicroLotti_Dettagli d with(nolock) 
							inner join Document_Microlotto_Valutazione_ECO v with(nolock)  on v.TipoDoc = 'LOTTO' and v.idHeader = d.id
								where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) 
								and d.idheader = @idBando  
								and NumeroLotto = @NumeroLotto and Voce = 0
					 )
			begin
				insert into #TempValutaz ( idRowVal ) 
					select v.idRow as idRowValutazione 
						from Document_MicroLotti_Dettagli d  with(nolock)  
							inner join Document_Microlotto_Valutazione_ECO v with(nolock)  on v.TipoDoc = 'LOTTO' and v.idHeader = d.id

							where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) 
								and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0
							order by v.idRow
			end
			else
			begin
				insert into #TempValutaz ( idRowVal )
					select d.idRow as idRowValutazione 
						from Document_Microlotto_Valutazione_ECO d  with(nolock) 
						where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando 
						order by d.idRow
			end


			-- cicla sui criteri per considerare le colonne coinvolte
			declare crs_F cursor static for 
					select  idRow,  dbo.GetPos( AttributoBase , '.' , 2 ) , dbo.GetPos( AttributoValore , '.' , 2 ) , CriterioFormulazioneOfferte 
						from #TempValutaz 
							inner join Document_Microlotto_Valutazione_ECO with(nolock)  on idRowVal = idRow
						order by idRowVal

			open crs_F 

			fetch next from crs_F into @idRow_V,  @AttributoBase, @AttributoValore, @CriterioFormulazioneOfferte 
			while @@fetch_status=0 
			begin 

				-- se la base asta presente sul criterio è definito solo a livello di voce si riporta sul lotto
				-- solo per le gare che non prevedono il complesso altrimenti lo si calcola sulle offerte
				if ( @TipoDoc like 'BANDO%' and @Complex <> '1' ) -- gare non complesse
					or
					(@TipoDoc not like 'BANDO%' and @Complex = '1' ) -- offerte complesse
				begin

					-- verifica se l'attributo è a livello di voce in questo caso lo fa risalire
					set @Ret = dbo.ConditionLottoVoceModello( @idModello , @AttributoBase , @divisione_lotti )

					-- se l'informazione è disponibile solo sulle voci
					if @Ret =  ' and Voce <> 0 '
					begin 
						--si sommano i valori delle voci				
						set @SQLCalcoloValori = 'update Document_MicroLotti_Dettagli set ' + @AttributoBase + ' = ( select sum( cast( ' + @AttributoBase + ' as float ) ) from Document_MicroLotti_Dettagli where Tipodoc = ''' + @TipoDoc + ''' and Voce <> 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30)) + ' )
													where Tipodoc = ''' + @TipoDoc + ''' and Voce = 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30))
						
						--print @SQLCalcoloValori
						exec ( @SQLCalcoloValori  ) 
					
					end

				end


				if @TipoDoc not like 'BANDO%' -- se il valore offerto presente sul criterio è definito solo a livello di voce si riporta sul lotto
				begin

					-- verifica se l'attributo è a livello di voce in questo caso lo fa risalire
					set @Ret = dbo.ConditionLottoVoceModello( @idModello , @AttributoValore , @divisione_lotti )

					-- se l'informazione è disponibile solo sulle voci
					if @Ret =  ' and Voce <> 0 '
					begin 

						if @CriterioFormulazioneOfferte = '15536' --prezzo
						begin
							set @SQLCalcoloValori = 'update Document_MicroLotti_Dettagli set ' + @AttributoValore + ' = ( select sum( cast( ' + @AttributoValore + ' as float ) ) from Document_MicroLotti_Dettagli where Tipodoc = ''' + @TipoDoc + ''' and Voce <> 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30))+ ' )
													where Tipodoc = ''' + @TipoDoc + ''' and Voce = 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30))
						
							
						end
						else
						begin


							--set @SQLCalcoloValori = 'update Document_MicroLotti_Dettagli set ' + @AttributoValore + ' =  ( ' + @AttributoBase + ' - ( select sum( cast( ' + @AttributoBase + ' as float ) - ( cast( ' + @AttributoValore + ' as float ) * cast( ' + @AttributoBase + ' as float ) ) / 100 )    from Document_MicroLotti_Dettagli where Tipodoc = ''' + @TipoDoc + ''' and Voce <> 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30)) + ' )  / ' + @AttributoBase + ' )  * 100 
							--						where Tipodoc = ''' + @TipoDoc + ''' and Voce = 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30))
							set @SQLCalcoloValori = 'update Document_MicroLotti_Dettagli set ' + @AttributoValore + ' =   ( select sum( cast( ' + @AttributoBase + ' as float ) *  cast( ' + @AttributoValore + ' as float ) )    from Document_MicroLotti_Dettagli where Tipodoc = ''' + @TipoDoc + ''' and Voce <> 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30)) + ' )  / ' + @AttributoBase + ' 
													where Tipodoc = ''' + @TipoDoc + ''' and Voce = 0 and NumeroLotto = ''' + @NumeroLotto + ''' AND IDHEADER = ' + cast( @idDoc as varchar(30))


						end
						
						--print @SQLCalcoloValori
						exec(  @SQLCalcoloValori  )
						
					end


				end


				-- si passa alla formula successiva
				fetch next from crs_F into @idRow_V,  @AttributoBase, @AttributoValore, @CriterioFormulazioneOfferte 

			end 
			close crs_F 
			deallocate crs_F

			fetch next from crs_L into @NumeroLotto
		end

		close crs_L 
		deallocate crs_L


		drop table #TempValutaz
		drop table #TempLotti

	end


end








GO
