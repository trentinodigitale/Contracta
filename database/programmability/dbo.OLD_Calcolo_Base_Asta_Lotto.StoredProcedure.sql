USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Calcolo_Base_Asta_Lotto]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create PROC [dbo].[OLD_Calcolo_Base_Asta_Lotto] (@idBando  int , @NumeroLotto VARCHAR(50) , @ValoreEconomicoBaseAsta float OUT )
AS
BEGIN 
	
    
    declare @Criterio as varchar(100)
    declare @ListaModelliMicrolotti as varchar(500)
    declare @NumeroDecimali as int
    declare @BaseAstaUnitaria as int
    declare @FieldQuantita as varchar(200)
    declare @LottoVoce varchar(50)

    declare @FieldBaseAsta as varchar(200)
    declare @IdDocModello as int
    declare @divisione_lotti as varchar(50)
    declare @RigaZero as int
    declare @TipoDocBando as varchar(200)
    declare @TipoDoc as varchar(200)
    declare @SorgenteVoce varchar(50)
    declare @strSql as nvarchar (max)
   


    select  @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando , @NumeroDecimali = isnull( NumDec , 5 ) , @BaseAstaUnitaria = isnull( BaseAstaUnitaria , 0 ) 
				    , @divisione_lotti = divisione_lotti
			 from Document_Bando 
			 where idheader = @idBando

    select  @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
			 from Document_Modelli_MicroLotti_Formula 
			 where @Criterio = CriterioFormulazioneOfferte
				and @ListaModelliMicrolotti = Codice

    select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando



    if exists( select * from ctl_doc_value where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
		  set @RigaZero = 1
    else
		  set @RigaZero = 0


    select @TipoDocBando = TipoDoc from ctl_doc where id = @idBando


    select @LottoVoce =  l.Value 
			 from CTL_DOC_VALUE a
				inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce' and l.DSE_ID = 'MODELLI'
				where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FieldBaseAsta and a.DSE_ID = 'MODELLI'
						  --and  l.Value in ( 'Lotto' , 'LottoVoce' )


    if ( @divisione_lotti <> '0'  and @LottoVoce in ( 'Lotto' , 'LottoVoce' ))
		  or 
		  ( @divisione_lotti = '0' and @RigaZero = 1 and @LottoVoce in ( 'Lotto' , 'LottoVoce' )) -- LE GARE SENZA LOTTI VENGONO PRESE DALLO VOCE ZERO SOLO SE PRESENTE E LA RICHIESTA DI COMPILAZIONE E PER LOTTO
		  or 
		  @divisione_lotti = '2' -- per le gare a lotti ma senza voci
		  set @SorgenteVoce = ' = ''0'' '
    else
		  set @SorgenteVoce = ' <> ''0'' '


    set @strSql =  'insert into #TempValori (  ValoreImportoLotto ) select round(  sum (  ' +
        						    CASE 
								when @FieldQuantita <> '' and @BaseAstaUnitaria=1 /* base asta unitaria*/ then @FieldQuantita + ' * ' + @FieldBaseAsta 
								else @FieldBaseAsta 
							    END
        
										  + ' ), 2  ) 
				    from Document_MicroLotti_Dettagli
				    where tipodoc = ''' + @TipoDocBando  + '''  and 
						  idheader  = ' + cast( @idBando as varchar(20))
				+ ' and (( isnull( Voce , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + ''' <> ''0'' ) or ( isnull( numeroriga , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + '''  = ''0'' ) )'


    -- nel caso di gare a lotti la base asta è da considerare solo per i lotti dove si risponde
    if @divisione_lotti <> '0'
    begin
		  set @strSql =  @strSql + ' and numerolotto = ' + @NumeroLotto
    end

    create table #TempValori ( NumeroLotto varchar(50) collate DATABASE_DEFAULT ,  ValoreImportoLotto float )

    exec ( @strSql )

    select  @ValoreEconomicoBaseAsta = sum( ValoreImportoLotto ) from #TempValori
        													
    drop table #TempValori

    

END





GO
