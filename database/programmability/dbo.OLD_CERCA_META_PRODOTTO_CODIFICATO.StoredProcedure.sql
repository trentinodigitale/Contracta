USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CERCA_META_PRODOTTO_CODIFICATO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--exec  CERCA_META_PRODOTTO_CODIFICATO 304922 , 45094
CREATE PROCEDURE [dbo].[OLD_CERCA_META_PRODOTTO_CODIFICATO] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON
	
	--declare  @idDoc int 
	--declare  @IdUser int 
	--set @idDoc=304922--<ID_DOC>
	--set @IdUser=45094--<ID_DOC>

	declare @idModProd		as int
	declare @linkedDoc	as int
	declare @idFornitore	as int


	declare @Ambito			as varchar(100)
	declare @tipodoc        as varchar(200)
	declare @CodiceMod		as varchar(1000)
	declare @CodiceModListino		as varchar(1000)
	declare @SQL_COND		as varchar(max)
	declare @SQL			as varchar(max)
	declare @SQL_RIGA_ZERO	as varchar(max)
	declare @modellocodifica varchar(500)
	declare @modellobando varchar(500)
	declare @Cod varchar(200)
	declare @divisione_lotti as varchar(1)
	
	set @SQL_RIGA_ZERO=''
	
	select 
			@Cod = b.TipoBando,
			@tipodoc=TipoDoc ,
			@divisione_lotti=Divisione_lotti
		from Document_Bando b with(nolock)
				inner join ctl_doc C with(nolock) on C.Id=b.idHeader
		where b.idHeader = @iddoc

	--recupero modello bando associato
	select @modellobando=modellobando + '_LOTTI' from Document_Modelli_MicroLotti with(nolock) where codice=@Cod

	

	--se nel modello della gara è presente il codice regionale
	IF EXISTS ( select MA_ID from CTL_ModelAttributes where MA_MOD_ID=@modellobando and MA_DZT_Name='CODICE_REGIONALE' )
	BEGIN
			---recupero l'ambito della gara
			IF @tipodoc='BANDO_GARA'
			BEGIN
				Select 
						@ambito=value
					from CTL_DOC_Value with(nolock) 
					where IdHeader=@iddoc and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='Ambito'		
			END

			IF @tipodoc='BANDO_SEMPLIFICATO'
			BEGIN
				Select @ambito=cod.value
					from CTL_DOC with(nolock)
						left outer join CTL_DOC_Value idmod  with(nolock) on id = idmod.idheader and idmod.dzt_name = 'id_modello' and idmod.DSE_ID = 'TESTATA_PRODOTTI'
						left outer join ctl_doc_value cod with(nolock) on idmod.Value = cod.idHeader and  cod.dzt_name = 'MacroAreaMerc' and cod.dse_id = 'AMBITO' 
					where id=@iddoc
			END

			--recupero modello codifica per ambito
			select 
					@modellocodifica='MODELLO_BASE_CODIFICA_PRODOTTI_' + titolo + '_MOD_Macro_Prodotto' ,
					@idModProd=id
				from ctl_doc with(nolock)
					inner join CTL_DOC_Value with(nolock) on id=IdHeader and DSE_ID='AMBITO' and DZT_Name='MacroAreaMerc' and value=@ambito
				where tipodoc='CONFIG_MODELLI' and Deleted=0 and JumpCheck='CODIFICA_PRODOTTI' and StatoFunzionale='Pubblicato'
	
			-- recupero gli attributi chiave per il confronto
			set @SQL_COND = ''

			select @SQL_COND = @SQL_COND  + ' ISNULL( S.' + v1.Value + ' , '''' ) = ISNULL( D.' + v1.Value + ' ,'''' )AND '
				from ctl_doc d with(nolock)
						inner join CTL_DOC_VALUE v1 with(nolock)  on v1.IdHeader = d.id and v1.DSE_ID = 'MODELLI' and v1.DZT_Name = 'DZT_Name'
						inner join CTL_DOC_VALUE v2 with(nolock)  on v2.IdHeader = d.id and v2.DSE_ID = 'MODELLI' and v2.DZT_Name = 'MOD_Macro_Prodotto' and v1.Row = v2.Row
				where d.id = @idModProd and v2.Value = 'Chiave'

			--PER LE GARE SINGOLA VOCE PRENDE LA RIGA ZERO ALTRIMENTI NO
			IF @divisione_lotti='2'
			BEGIN
				set  @SQL_RIGA_ZERO=''
			END
			ELSE
			BEGIN
				set @SQL_RIGA_ZERO=' and  D.Voce <> 0 '
			END

			--ho trovato gli attributi chiave
			if @SQL_COND <> ''
			BEGIN
				
				set @SQL_COND = left( @SQL_COND , len( @SQL_COND) - 3 )
				select top 0 CODICE_REGIONALE , DESCRIZIONE_CODICE_REGIONALE ,DESCRIZIONE_CODICE_REGIONALE as DESCRIZIONE_BANDO ,idheader as id into #temp from Document_microlotti_dettagli
				-- compongo la query di confronto e metto in una temp il tutto
				set @SQL = ' insert into #temp (CODICE_REGIONALE , DESCRIZIONE_CODICE_REGIONALE ,DESCRIZIONE_BANDO ,id)
								select S.CODICE_REGIONALE,S.DESCRIZIONE_CODICE_REGIONALE,D.DESCRIZIONE_CODICE_REGIONALE as DESCRIZIONE_BANDO ,D.id 
									from Document_microlotti_dettagli D
										inner join Document_microlotti_dettagli S on  S.TipoDoc = ''META_PRODOTTO'' AND ' + @SQL_COND + ' 
									where  D.idHeader = ' + cast( @iddoc as varchar(20)) + ' and isnull(S.CODICE_REGIONALE,'''')<>'''' and isnull(D.CODICE_REGIONALE,'''')='''' AND D.TipoDoc = '''+ @tipodoc +'''  and S.Posizione = ''' + @Ambito + '''' + @SQL_RIGA_ZERO  
									
									
				--PRINT @SQL
				exec(  @SQL ) 			
				
				--SE ID NELLA TEMP E' presente solo una volta significa che ho trovato un solo prodotto codificato per quella chiave
				select id  into #temp_ok from #temp T  group by id having count(*) = 1
				
				--LO RIPORTO SUL BANDO
				update  D set D.CODICE_REGIONALE=T1.CODICE_REGIONALE
					from Document_microlotti_dettagli D
						inner join #temp_ok T on T.id=D.id
						inner join #temp T1 on T1.id=T.id
					where D.Id=T.id and ISNULL(D.CODICE_REGIONALE,'') = ''
				
				delete from #temp where ID in (select id from #temp_ok)
				drop table #temp_ok

				--se la descrizione sulla riga combacia con una delle codifiche trovate si associa il codice regionale
				select id,max(codice_regionale) as CODICE_REG_OK into #temp_ok1 
					from #temp T where Descrizione_bando=DESCRIZIONE_CODICE_REGIONALE 
					group by id  having count(*) = 1
				
				--LO RIPORTO SUL BANDO
				update  D set D.CODICE_REGIONALE=T.CODICE_REG_OK
					from Document_microlotti_dettagli D
						inner join #temp_ok1 T on T.id=D.id						
					where D.Id=T.id and ISNULL(D.CODICE_REGIONALE,'') = ''
				
				delete from #temp where ID in (select id from #temp_ok1)
				drop table #temp_ok1
				
				--altrimenti si scrive nell'esito riga "Esiste più di un prodotto per la chiave inserita, è necessario inserire la descrizione esatta del prodotto"
				IF EXISTS ( select ID from #temp )
				BEGIN
					update  D set EsitoRiga = isnull(EsitoRiga,'') +  '<br>Esiste più di un prodotto per la chiave inserita, è necessario inserire la descrizione esatta del prodotto'
						from Document_microlotti_dettagli D
							inner join #temp T on T.id=D.id						
						where D.Id=T.id and ISNULL(D.CODICE_REGIONALE,'') = ''
				END

				

			END



	
	END --FINE IF PRESENZA ATTRIBUTO CODICE REGIONALE



END
GO
