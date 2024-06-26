USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_ELENCO_PARTECIPANTI_AL_SEMPLIFICATO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD_DASHBOARD_SP_ELENCO_PARTECIPANTI_AL_SEMPLIFICATO]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as



	declare @Param varchar(max)
	declare @SQLCmd varchar(max)
	
	

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


	declare @CrLf varchar (10)
	set @CrLf = '
'

	declare @idSDA varchar(20)
	select @idSDA = linkeddoc from ctl_doc where id = @Filter
	--print @idSDA
-------------------------------------------------------------------
-- creo la query di estrazione
-------------------------------------------------------------------

	set @SQLCmd =   '
		select 
		
			d.idrow, d.idHeader, d.IdPfu, 
			
			--d.IdAzi, d.aziRagioneSociale, d.aziPartitaIVA, 
			--d.aziE_Mail, d.aziIndirizzoLeg, d.aziLocalitaLeg, d.aziProvinciaLeg, d.aziStatoLeg, 
			--d.aziCAPLeg, d.aziTelefono1, d.aziFAX, d.aziDBNumber, d.aziSitoWeb, 

		  	A.IdAzi, A.aziRagioneSociale, A.aziPartitaIVA, 
			A.aziE_Mail, A.aziIndirizzoLeg, A.aziLocalitaLeg, A.aziProvinciaLeg, A.aziStatoLeg, 
		  	A.aziCAPLeg, A.aziTelefono1, A.aziFAX, A.aziDBNumber, A.aziSitoWeb, 

			d.CDDStato, d.Seleziona, 
			d.NumRiga, d.CodiceFiscale, d.StatoIscrizione, d.DataIscrizione, d.DataScadenzaIscrizione, 
			d.DataSollecito, d.Id_Doc , c.id as id_Conferma into #Temp

				from CTL_DOC_Destinatari d with(nolock)
				
					inner join Aziende A with(nolock)  on D.IdAzi = A.idazi and aziDeleted = 0
					inner join CTL_DOC i with(nolock) on i.id = d.Id_Doc -- ultima istanza confermata
					left join CTL_DOC c with(nolock) on c.LinkedDoc = i.id and c.statofunzionale = ''Notificato'' and c.deleted = 0  and c.TipoDoc like ''CONFERMA_ISCRIZIONE%''
			
				where d.statoiscrizione= ''Iscritto'' and d.idheader = ' + @idSDA + '
			'
	
	--print @SQLCmd
	--verifico se il semplificato ha la selezione delle categorie ed il criterio tutte o almeno una
	declare @Criteriio_scelta_fornitori varchar(100)
	declare @Categorie_Merceologiche varchar(max)
	declare @DSE_ID varchar(200)
	declare @DZT_Name varchar(200)
	set @DSE_ID = 'CATEGORIE'
	set @DZT_Name = 'Categoria_Merceologica'

	select @Categorie_Merceologiche = isnull( value , '' ) from CTL_DOC_Value with(nolock) where IdHeader = @Filter and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'Categorie_Merceologiche' 
	select @Criteriio_scelta_fornitori = isnull( value ,'OR' ) from CTL_DOC_Value with(nolock) where IdHeader = @Filter and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'Criteriio_scelta_fornitori' 


	if @Categorie_Merceologiche <> '' 
	begin
		if @Criteriio_scelta_fornitori = 'OR' 
		begin

		set @SQLCmd =  @SQLCmd + '
		
			select * 
				from #Temp T
				where T.idrow in (
					select t.idrow
						from #Temp t
						inner join CTL_DOC_Value v with(nolock) on v.DSE_ID = ''' + @DSE_ID + ''' and v.DZT_Name  = ''' + @DZT_Name + ''' and v.idheader =  id_Conferma and ''' + @Categorie_Merceologiche + ''' like ''%###'' + v.value + ''###%''
						inner join CTL_DOC_Value v2 with(nolock) on v.Row = v2.Row and v2.DSE_ID = ''' + @DSE_ID + ''' and v2.DZT_Name  = ''Seleziona'' and v2.idheader =  id_Conferma and v2.value  = ''includi''
						
					)
		'

		end
		else -- AND
		begin

			-- costruisce la query con tutte le and
			declare @item varchar(100)
			declare @ix int
			declare @i  varchar(10)

			set @ix = 1
			set @SQLCmd = @SQLCmd +  ' select t.* 
					from #Temp T
					'


			declare Cur  Cursor static for 
				select replace( items  , '''' , '''''' ) as items from dbo.split(  @Categorie_Merceologiche , '###' )
			
			open Cur
			


			FETCH NEXT FROM Cur 	INTO @item
			WHILE @@FETCH_STATUS = 0
			BEGIN
				set @i = cast( @ix as varchar)
				set @ix = @ix + 1

				set @SQLCmd = @SQLCmd  + ' inner join CTL_Doc_Value V' + @i + ' with(nolock) on  V' + @i + '.idheader = id_Conferma and V' + @i + '.DSE_ID = ''' + @DSE_ID + ''' and V' + @i + '.DZT_Name = ''' + @DZT_Name + ''' and V' + @i + '.Value = ''' + @item + ''' 
				' 
				set @SQLCmd = @SQLCmd  + ' inner join CTL_Doc_Value V2_' + @i + ' with(nolock) on    V' + @i + '.Row =  V2_' + @i + '.Row and V2_' + @i + '.idheader = id_Conferma and V2_' + @i + '.DSE_ID = ''' + @DSE_ID + ''' and V2_' + @i + '.DZT_Name = ''Seleziona'' and V2_' + @i + '.Value = ''includi''
				' 

				FETCH NEXT FROM Cur 	INTO @item
			end
			CLOSE Cur
			DEALLOCATE Cur	


		end

		
		set @SQLCmd = @SQLCmd  + ' order by T.aziRagioneSociale'


	end
	else
	begin

		set @SQLCmd = @SQLCmd  + ' select T.* from #Temp T order by T.aziRagioneSociale'
		

	end

	--print @SQLCmd 
	exec ( @SQLCmd )






GO
