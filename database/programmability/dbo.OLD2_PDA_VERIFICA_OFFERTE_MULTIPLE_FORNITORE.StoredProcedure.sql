USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_VERIFICA_OFFERTE_MULTIPLE_FORNITORE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  proc [dbo].[OLD2_PDA_VERIFICA_OFFERTE_MULTIPLE_FORNITORE]( @idPda as int )
as
begin

	--declare @idPda int
	--set @idPda = 68271

	declare @idRow INT
	declare @idAzi INT
	declare @IdMsgFornitore INT
	declare @Lotti varchar(max)
	declare @aziRagionesociale nvarchar(4000)
	declare @codice_fiscale as nvarchar(200)

	------------------------------------------------------
	-- tutte le combinatorie di lotti offerti per ogni partecipante anche in RTI
	------------------------------------------------------
	select distinct  o.idrow , isnull( r.CodiceFiscale , vatValore_FT ) as CodiceFiscale,  
					isnull( r.IdAzi , idazipartecipante ) as idazi , 
					ISNULL( l.NumeroLotto , '1' ) as NumeroLotto,
					ISNULL(tiporiferimento,'') as tiporiferimento,
					isnull( r.aziragionesociale , o.aziragionesociale ) as aziragionesociale 

		into #Temp
		 from Document_PDA_OFFERTE o
			inner join DM_Attributi with(nolock) on lnk=idazipartecipante and dztNome='codicefiscale'
			left outer join CTL_DOC p on p.LinkedDoc = o.IdMsg  and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and deleted = 0
			--left outer join document_offerta_partecipanti r on r.IdHeader = o.IdMsgFornitore
			left outer join (
					select vatValore_FT as CodiceFiscale,azienda as idazi, id as idheader,'' as tiporiferimento	,aziragionesociale					
						from CTL_DOC 
							left join DM_Attributi with(nolock) on lnk=Azienda and dztNome='codicefiscale' 
							left join Aziende A with(nolock) on A.IdAzi=Azienda  
						where tipodoc = 'OFFERTA_PARTECIPANTI' and StatoFunzionale = 'Pubblicato' and deleted = 0
					union 
					select CodiceFiscale,idazi , idheader , tiporiferimento ,RagSoc  as aziragionesociale
						from  document_offerta_partecipanti 
				) as r on r.IdHeader = p.id

			--left outer join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.TipoDoc = 'PDA_OFFERTE'  and Voce = 0
			left outer join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdMsg   and l.TipoDoc = 'OFFERTA'  and Voce = 0

			-- escludo i lotti che sono stati considerati esclusi sull'offerta o per i campioni
			left outer join CTL_DOC ca on  ca.Tipodoc = 'RICEZIONE_CAMPIONI' and ca.deleted = 0 and ca.StatoFunzionale = 'Confermato' and ca.IdDoc = o.idheader and o.IdMsg  = ca.LinkedDoc
			left outer join Document_Pda_Ricezione_Campioni rc on rc.IdHeader = ca.id and rc.NumeroLotto = l.NumeroLotto

			left outer join CTL_DOC es on  es.Tipodoc = 'ESCLUDI_LOTTI' and es.deleted = 0 and es.StatoFunzionale = 'Confermato' and es.IdDoc = o.idheader and o.IdMsg = es.LinkedDoc
			left outer join Document_Pda_Escludi_Lotti el on el.IdHeader = es.id and el.NumeroLotto = l.NumeroLotto

		where o.idheader = @idPda and statopda in ( '2' , '22' , '8' , '9' , '222' ,'1')

			-- escludo dalla combinatoria i lotti esclusi 
			and  isnull( el.StatoLotto , '' ) <> 'escluso' 
			and isnull( rc.CampioneRicevuto , '1' ) <> '0' 



	------------------------------------------------------
	-- cancello eventuali anomalie precedentemente calcolate
	------------------------------------------------------
	delete from document_pda_offerte_anomalie where idheader = @idPda and  TipoAnomalia = 'Conflitto'



	------------------------------------------------------
	-- inserisco i conflitti di offerte per ogni offerta fornitore
	------------------------------------------------------
	declare CurProg Cursor static for 
	--Select distinct t.IdRow , t.idazi , a.aziRagionesociale  , IdMsg 
	--	from  Document_PDA_OFFERTE o
	--	inner join #Temp t on o.idrow = t.idrow
	--	inner join #Temp t2 on t.idazi = t2.idazi and t.NumeroLotto = t2.NumeroLotto and t.IdRow <> t2.IdRow   and  not  ( t.tiporiferimento = 'SUBAPPALTO' and t2.tiporiferimento = 'SUBAPPALTO' )
	--	inner join aziende a on a.idazi = t.idazi
	--	--where idHeader=@idPda
	--	order by t.IdRow
	Select distinct t.IdRow ,t.CodiceFiscale , t.idazi , t.aziRagionesociale  , IdMsg 
		from  Document_PDA_OFFERTE o
			inner join #Temp t on o.idrow = t.idrow
			inner join #Temp t2 on t.CodiceFiscale  = t2.CodiceFiscale and t.NumeroLotto = t2.NumeroLotto and t.IdRow <> t2.IdRow   and  not  ( t.tiporiferimento = 'SUBAPPALTO' and t2.tiporiferimento = 'SUBAPPALTO' )
		--	left join aziende a on a.idazi = t.idazi
		--where idHeader=@idPda
		order by t.IdRow
	
	open CurProg

	FETCH NEXT FROM CurProg INTO @idrow , @codice_fiscale ,@idAzi , @aziRagionesociale , @IdMsgFornitore
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		set @Lotti = ''

		-- estraggo i lotti che sull'offerta iesima risultano anche su altre offerte con lo stesso fornitore
--		select @Lotti = @Lotti + cast( numerolotto as varchar(10)) + ' - ' from ( select distinct numerolotto from #Temp where idrow <> @idrow and @idAzi = idazi ) as a
		select @Lotti = @Lotti + cast( numerolotto as varchar(10)) + ' - ' 
		from ( 
				select distinct t.numerolotto from #Temp t 
								inner join #Temp t2 on t.numerolotto  = t2. numerolotto  and t.CodiceFiscale  = t2.CodiceFiscale
								where t.idrow = @idrow  and t2.idrow <> @idrow and @codice_fiscale  = t.CodiceFiscale  
						
			) as a

		if @Lotti <> ''
			set @Lotti = left( @Lotti , len(@Lotti) - 2 ) 
		
		insert into document_pda_offerte_anomalie ( IdHeader, IdRowOfferta, IdDocOff, IdFornitore, Descrizione,  TipoAnomalia ) 
			select @idPda as  IdHeader, @idrow as IdRowOfferta, @IdMsgFornitore as IdDocOff, @idAzi as IdFornitore, 
				'Il fornitore ' + @aziRagionesociale + ' risulta presente su altre offerte per i lotti : ' + @Lotti as Descrizione,  
				'Conflitto' as TipoAnomalia 
	             
		FETCH NEXT FROM CurProg INTO @idrow, @codice_fiscale , @idAzi , @aziRagionesociale , @IdMsgFornitore
	END 
	CLOSE CurProg
	DEALLOCATE CurProg

	------------------------------------------------------
	--aggiorno il warning
	------------------------------------------------------
	exec PDA_UPD_WARNING @idPda 

	--declare @Warning as nvarchar(max)
	--update Document_PDA_OFFERTE 
	--		set Warning = ''
	--	where 
	--		idheader=@idPda

	--declare CurProgW Cursor for 
	--Select distinct IdRow 
	--	from  Document_PDA_OFFERTE o
	
	--open CurProgW

	--FETCH NEXT FROM CurProgW INTO @idrow
	--WHILE @@FETCH_STATUS = 0
	--BEGIN
		
	--	set @Warning = ''

	--	--recupero tutti i warning della riga offerta corrente
	--	select @Warning=@Warning + ' - ' + Descrizione from Document_Pda_Offerte_Anomalie where IdRowOfferta=@idrow and IdHeader = @idPda

				
	--	--print @Warning
	--	set @Warning = substring(@Warning,4,len(@Warning))

	--	--se presente aggiorna colonna riepilogativa su offerta
	--	if @Warning <> ''
	--	begin
	--		update Document_PDA_OFFERTE 
	--			set Warning = '<img src="../images/Domain/State_Warning.png" alt="' + @Warning + '" title="' + @Warning + '">'
	--		where 
	--			idRow=@idrow
	--	end

	             
	--	FETCH NEXT FROM CurProgW INTO @idrow
	--END 
	--CLOSE CurProgW
	--DEALLOCATE CurProgW




	drop table #Temp


end




GO
