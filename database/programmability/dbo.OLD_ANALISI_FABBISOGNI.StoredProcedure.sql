USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANALISI_FABBISOGNI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[OLD_ANALISI_FABBISOGNI]( @id as int , @NRiga as varchar(200) = '' )
as
begin



--	declare @id INT
	declare @idbando as int
	declare @idquestionario as int
	declare @modello as varchar(500)
	declare @Cod varchar(200)
	declare @SQL varchar(max)
	declare @SQL_Calcoli varchar(max)
	--declare @SQL_CONTROLLO_NULL varchar(max)
	declare @SQL_ColUpdate  varchar(max)
	declare @NumeroRiga as varchar(500)

	set @SQL_Calcoli = ''
	set @SQL_ColUpdate = ''
	--set @SQL_CONTROLLO_NULL=''


	--select @id = idheader from 
	--set @id=<ID_DOC>

	--recupero id BAndo e modello
	select @idbando=c.linkeddoc , @Cod = c1.TipoBando 
			from ctl_doc C
				inner join document_bando c1 on c1.idheader =C.linkeddoc 
			where C.id=@id


	set @modello='MODELLO_BASE_FABBISOGNI_' + @Cod + '_Fabb_Questionario'



	declare @IdDocModello int
	select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_FABBISOGNI' and deleted = 0 and linkeddoc = @idbando

	---CICLO SU TUTTE LE COLONNE DEL MODELLO QUESTIONARIO
	declare @MA_DZT_Name varchar(max)
	declare @row as INT
	declare @operazione as varchar(200)

	declare CurProg Cursor Static for 
		select MA_DZT_Name , v2.value as operazione
			from CTL_ModelAttributes  M
				inner join lib_dictionary D on D.DZT_Name=M.MA_DZT_Name and D.DZT_Type=2
				inner join ctl_doc_value v1 on v1.idheader=@IdDocModello and v1.dzt_name='DZT_Name' and v1.DSE_ID='MODELLI' and v1.value = MA_DZT_Name
				inner join ctl_doc_value v2 on v2.idheader=@IdDocModello and v2.dzt_name='Fabb_Operazioni' and v2.DSE_ID='MODELLI' and v2.Row=v1.Row
			where MA_MOD_ID=@modello and MA_DZT_Name not in ('EsitoRiga','NumeroRiga','TipoDoc')  and v2.value in ( 'max','min','somma' ,'media' )

	open CurProg

	-- per ogni colonna da calcolare
	FETCH NEXT FROM CurProg 	INTO @MA_DZT_Name , @operazione
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- per ogni colonna definisco il tipo di operazione da eseguire
		set @SQL_Calcoli = @SQL_Calcoli +  case when @operazione = 'max'  then ' isnull( max( case when cast( ' + @MA_DZT_Name + ' as float ) = 0.0 then null else cast( ' + @MA_DZT_Name + ' as float ) end ) , 0 ) as ' + @MA_DZT_Name + ' , '
												when @operazione = 'min'  then ' isnull( min( case when cast( ' + @MA_DZT_Name + ' as float ) = 0.0 then null else cast( ' + @MA_DZT_Name + ' as float ) end ) , 0 ) as ' + @MA_DZT_Name + ' , '
												when @operazione = 'somma'  then ' isnull( sum( case when cast( ' + @MA_DZT_Name + ' as float ) = 0.0 then null else cast( ' + @MA_DZT_Name + ' as float ) end  ) , 0 ) as ' + @MA_DZT_Name + ' , '
												when @operazione = 'media'  then ' isnull( avg( case when cast( ' + @MA_DZT_Name + ' as float ) = 0.0 then null else cast( ' + @MA_DZT_Name + ' as float ) end  ) , 0 ) as ' + @MA_DZT_Name + ' , '
												else '' end
		
		-- colleziono le colonne da aggiornare
		set @SQL_ColUpdate = @SQL_ColUpdate + 'D.' + @MA_DZT_Name + ' = S.' + @MA_DZT_Name + ' , '

		FETCH NEXT FROM CurProg 	INTO @MA_DZT_Name , @operazione

	end

	CLOSE CurProg
	DEALLOCATE CurProg

	set @SQL_Calcoli = left( @SQL_Calcoli , len( @SQL_Calcoli ) - 2 )
	set @SQL_ColUpdate = left( @SQL_ColUpdate , len( @SQL_ColUpdate ) - 2 )
	--set @SQL_CONTROLLO_NULL = left( @SQL_CONTROLLO_NULL , len( @SQL_CONTROLLO_NULL ) - 4 )


	-- i valori null SQL non li considera nelle funzioni matematiche di somma, media, minimo e massimo
	-- la verifica è stata fatta con un test 
	--create table #Temp ( v  float )

	--insert into #Temp( v ) values( 1 )
	--insert into #Temp( v ) values( 2 )
	--insert into #Temp( v ) values( null )
	--insert into #Temp( v ) values( 3 )
	--insert into #Temp( v ) values( 4 )

	--select * from #Temp
	--select sum( v ) from #Temp
	--select avg( v ) from #Temp
	--select min( v ) from #Temp
	--select max( v ) from #Temp



	-- compongo lo script
	set @SQL = 'update D Set ' + @SQL_ColUpdate + '
		from Document_MicroLotti_Dettagli D
			inner join ( select idheader , ' + @SQL_Calcoli + ' 
							from Document_MicroLotti_Dettagli
							where   TipoDoc = ''ANALISI_FABBISOGNO_DETTAGLIO'' and idheader in ( select id from Document_MicroLotti_Dettagli where TipoDoc = ''ANALISI_FABBISOGNI'' and idheader = ' + cast ( @id as varchar(15) ) + @NRiga + ' )
							group by idheader 
						) as S on S.idheader = D.id
			where D.idheader = ' + cast ( @id as varchar(15) ) +  @NRiga 
							
	exec( @SQL )
	--print @SQL


end






GO
