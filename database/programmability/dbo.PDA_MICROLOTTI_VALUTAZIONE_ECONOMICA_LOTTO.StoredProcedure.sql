USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO] ( @idLotto int ) 
as
begin

	declare @FormulaEconomica varchar(4000)
	declare @StrSql varchar(4000)
	declare @Criterio as varchar(100)
	declare @NumeroLotto as varchar(130)
	declare @ListaModelliMicrolotti varchar(250)
	declare @FieldBaseAsta				varchar(200)
	declare @FieldQuantita				varchar(200)
	declare @NumeroDecimali				varchar(20)

	--declare @idLotto int
	declare @idDoc int


	--set @idLotto = 372--<ID_DOC>
	select @idDoc = idheader , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli where id = @idLotto

	set @NumeroDecimali = 5
	
	-- determino il criterio di aggiudicazione della gara
	if exists( select id from ctl_doc where isnull( jumpcheck , '' ) <> '' and id = @IdDoc)
	begin
		select @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando , @NumeroDecimali = isnull( NumDec , 5 )
			 from Document_Bando 
				inner join CTL_DOC on LinkedDoc = idheader
				where id = @IdDoc
	end
	else
	begin
		select @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = ListaModelliMicrolotti
			 from TAB_MESSAGGI_FIELDS 
				inner join CTL_DOC on LinkedDoc = idMsg
				where id = @IdDoc
	end

	select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
		from Document_Modelli_MicroLotti_Formula 
		where @Criterio = CriterioFormulazioneOfferte
			and @ListaModelliMicrolotti = Codice

	update Document_MicroLotti_Dettagli 
		set Graduatoria = 0 ,  Aggiudicata = 0 , Exequo = 0
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc  and NumeroLotto = @NumeroLotto and StatoRiga not in ( 'escluso' , 'esclusoEco' )






	--set @strSql =  'Update 
	--	Document_MicroLotti_Dettagli
	--		set ValoreOfferta =  ' + @FormulaEconomica + ' 
	--		, ValoreImportoLotto = round( ' + 
			
	--					CASE 
	--						when @FieldQuantita <> '' and  @Criterio = '15536' /*prezzo*/ then  @FormulaEconomica + ' * ' + @FieldQuantita 
	--						when @FieldQuantita = '' and  @Criterio = '15536' /*prezzo*/ then  @FormulaEconomica 
	--						when @FieldQuantita <> '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * ' + @FormulaEconomica + ' ) / 100 ) ' + ' * ' + @FieldQuantita 
	--						when @FieldQuantita = '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * ' + @FormulaEconomica + ' ) / 100 ) ' 
							
	--						else '' 
						
	--					end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
			
	--	from Document_MicroLotti_Dettagli d
	--		inner join Document_PDA_OFFERTE o on d.TipoDoc = ''PDA_OFFERTE'' and d.IdHeader = o.IdRow
	--	where o.IdHeader = ' + cast( @idDoc as varchar( 20)) + ' and NumeroLotto = ''' + @NumeroLotto + '''  and StatoRiga not in ( ''escluso'' , ''anomalo'' )'


	------------------------------------------------------------
	---- determino il valore economico dei lotti offerti
	------------------------------------------------------------
	exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO @idLotto , -1


	--set @strSql =  'Update 
	--	Document_MicroLotti_Dettagli
	--		set ValoreOfferta =  ' + @FormulaEconomica + ' 
			
	--	from Document_MicroLotti_Dettagli d
	--		inner join Document_PDA_OFFERTE o on d.TipoDoc = ''PDA_OFFERTE'' and d.IdHeader = o.IdRow
	--	where o.IdHeader = ' + cast( @idDoc as varchar( 20)) + ' and NumeroLotto = ''' + @NumeroLotto + '''  and StatoRiga not in ( ''escluso'' , ''anomalo'' )'


	-- riporto il valore sul campo utilizzato per determinare la graduatoria
	Update 
		Document_MicroLotti_Dettagli
			set ValoreOfferta = str( ValoreRibasso , 30 , 20 )  --ValoreEconomico 
		from Document_MicroLotti_Dettagli d
			inner join Document_PDA_OFFERTE o on d.TipoDoc = 'PDA_OFFERTE' and d.IdHeader = o.IdRow
		where o.IdHeader = @idDoc and NumeroLotto = @NumeroLotto and StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) and voce = 0




	-- si determina la graduatoria e si evince il primo e secondo classificato
	exec PDA_GRADUATORIA_LOTTO @idDoc , @NumeroLotto 
end







GO
