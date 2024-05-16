USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_SORTEGGIO_OFFERTA_DO_SORTEGGIO_AUTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[PDA_SORTEGGIO_OFFERTA_DO_SORTEGGIO_AUTO]( @idDoc int ) 
as
begin

	declare @id int
	declare @idRow int

	set @id = 1

--	update Document_MicroLotti_Dettagli set Sorteggio = RAND() 
--		where  idheader = @idDoc
--			and tipodoc = 'PDA_SORTEGGIO_OFFERTA'
			
--
--	select  id , Sorteggio 
--		into #Temp
--		from Document_MicroLotti_Dettagli 
--		where  idheader = @idDoc
--				and tipodoc = 'PDA_SORTEGGIO_OFFERTA'
--		order by Sorteggio
--
--	declare crs_dsodsa cursor for select id from #Temp order by Sorteggio
--
--	open crs_dsodsa 
--	fetch next from crs_dsodsa into @idRow
--	while @@fetch_status=0 
--	begin 
--
--		update Document_MicroLotti_Dettagli set Sorteggio = @id where id = @idRow
--		set @id = @id +1
--
--		fetch next from crs_dsodsa into @idRow
--	end 
--	close crs_dsodsa 
--	deallocate crs_dsodsa
--
--	drop table #Temp
--


----------- metto un valore random
	declare crs_dsodsa cursor static for 
		select  id 
			from Document_MicroLotti_Dettagli 
			where  idheader = @idDoc
					and tipodoc = 'PDA_SORTEGGIO_OFFERTA'
			order by Sorteggio


	open crs_dsodsa 
	fetch next from crs_dsodsa into @idRow
	while @@fetch_status=0 
	begin 

		update Document_MicroLotti_Dettagli set Sorteggio = RAND() where id = @idRow
		

		fetch next from crs_dsodsa into @idRow
	end 
	close crs_dsodsa 
	deallocate crs_dsodsa

-- poi inserisco la graduatoria
	declare crs_dsodsa cursor static for 
		select  id 
			from Document_MicroLotti_Dettagli 
			where  idheader = @idDoc
					and tipodoc = 'PDA_SORTEGGIO_OFFERTA'
			order by Sorteggio


	open crs_dsodsa 
	fetch next from crs_dsodsa into @idRow
	while @@fetch_status=0 
	begin 

		update Document_MicroLotti_Dettagli set Sorteggio = @id where id = @idRow
		set @id = @id +1

		fetch next from crs_dsodsa into @idRow
	end 
	close crs_dsodsa 
	deallocate crs_dsodsa



end


GO
