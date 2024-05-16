USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ProspettoConfronto_Valutazione_GetDati]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD_ProspettoConfronto_Valutazione_GetDati] ( @IdDoc int )

AS
BEGIN 
	
	declare @App varchar(max)
	declare @CodArt varchar(500)
	declare @DescArt varchar(500)
	declare @cnt int

	-- crea tabella temporanea per i dati
	select top 0 note as Dati into #Temp from ctl_doc 

	alter table #Temp add cnt int null

	-- la prima riga contiene i dati di articolo in questo forma
	-- articolo1;;;descrizione1;;;UM;;;QT###articolo2;;;descrizione2;;;....

	set @App = ''

	select 
		@App = @App + isnull(codart,'') + ';;;' + isnull(DescrizioneArticolo,'') 
			+ ';;;' + isnull(dscTesto,'') + ';;;' + cast(isnull(CARQuantitaDaOrdinare,0) as varchar(20)) + '###'

		from View_ProspettoConfronto_Valutazione_RDA
			--inner join document_rdo_product on idheader=id
			--left outer join dizionarioattributi on dztnome='CARUnitMisNonCod'
			--left outer join tipidatirange on dztidtid=tdridtid     and tdrdeleted=0 and tdrcodice=um
			--left outer join descsi on IdDsc =  tdriddsc

		where id = @IdDoc
		order by codart

if len(@App) > 0
begin

	set @App = substring(@App,1,len(@App)-3)

	insert into #Temp
		(cnt,Dati)
	values (1,@App)

	-- ciclo sui fornitori
	-- crea una tabella con i fornitori distinti
	select distinct idaziforn,aziragionesociale into #TempAzi
		from View_ProspettoConfronto_Valutazione
		where id = @IdDoc

	alter table #TempAzi add Total float null

	update #TempAzi set Total = 0

	
	-- calcola il totale per ogni fornitore
	update #TempAzi
		set Total = isnull(b.Importo,0)

		from #TempAzi a,

		(	select idaziforn, sum(PrzUnOfferta * Quantita) as Importo
				from View_ProspettoConfronto_Valutazione 
					where id = @IdDoc
			group by idaziforn
		) b

		where a.idaziforn = b.idaziforn

	
	-- per ogni fornitore va a cercare i suoi articoli
		
		declare @idaziforn int
		declare @aziragionesociale varchar(500)
		declare @total float

		declare crs cursor static
		for 
			 select idaziforn,aziragionesociale,isnull(total,0)  from #TempAzi	order by total 

		open crs

		fetch next from crs into @idaziforn,@aziragionesociale,@total

		set @cnt = 1

		while @@fetch_status=0
		begin
				
				set @App = @aziragionesociale + ';;;' + cast(@total as varchar(30)) 

				select @App = @App + ';;;' + cast(isnull(PrzUnOfferta,0) as varchar(30)) + ';;;' + cast((isnull(PrzUnOfferta,0) * isnull(Quantita,0)) as varchar(30))
					from View_ProspettoConfronto_Valutazione 
				where id = @IdDoc
					and idaziforn = @idaziforn
				order by codart

				set @cnt = @cnt + 1

				insert into #Temp
					(cnt,Dati)
				values (@cnt,@App)
				

				fetch next from crs into @idaziforn,@aziragionesociale,@total
        
		end

		close crs

		deallocate crs
	
	
	
	

	

end
	



	select Dati from #Temp order by cnt

	

END

GO
