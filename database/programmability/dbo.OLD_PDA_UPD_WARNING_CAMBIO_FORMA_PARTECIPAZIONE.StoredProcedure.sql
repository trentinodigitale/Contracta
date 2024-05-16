USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_UPD_WARNING_CAMBIO_FORMA_PARTECIPAZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE proc [dbo].[OLD_PDA_UPD_WARNING_CAMBIO_FORMA_PARTECIPAZIONE]( @idPda as int, @IdOff as int )
as
begin

	declare @idrow int
	declare @IdGara as int
	declare @DescrizioneWarning as nvarchar(max)
	declare @faseconcorso as varchar(100)
	declare @IdConcorso_PrimaFase as int
	declare @IdRisp_PrimaFase as int
	declare @IDFornitore as int
	declare @Forma_Partecipazione_PrimaFase as nvarchar(max)
	declare @Forma_Partecipazione_SecondaFase as nvarchar(max)
	declare @CambioFormaPartecipazione as int

	set @CambioFormaPartecipazione = 0
	set @faseconcorso = ''
	set @IdConcorso_PrimaFase = 0
	set @IdRisp_PrimaFase = 0
	set @Forma_Partecipazione_PrimaFase=''
	set @Forma_Partecipazione_SecondaFase=''

	--recupero id gara 
	select @IdGara=LinkedDoc  from ctl_doc with (nolock) where id = @IdOff

	select @faseconcorso = isnull(faseconcorso,'') from document_bando with (nolock) where idheader =@IdGara

	if @faseconcorso = 'seconda'
	begin

		--recupero idrow offerta sulla document_pda_offerte
		select @idrow = idrow , @IDFornitore=idAziPartecipante  from document_pda_offerte with (nolock) where idmsg=@IdOff


		--recupero risposta sulla prima fase
		select @IdConcorso_PrimaFase = isnull(LinkedDoc,0)  from ctl_doc with (nolock) where id = @IdGara

		--recupero risposta stesso fornitore sulla prima fase
		select @IdRisp_PrimaFase = id 
			from ctl_doc with (nolock) 
			where tipodoc='RISPOSTA_CONCORSO' and Deleted = 0 and azienda = @IDFornitore and linkeddoc = @IdConcorso_PrimaFase
					and StatoFunzionale = 'Inviato' and statodoc = 'Sended'
		

		--controllo se è cambiata la forma di partecipazione
		select @Forma_Partecipazione_PrimaFase=value from ctl_doc_Value with (nolock)  where idheader= @IdConcorso_PrimaFase and dse_id='TESTATA_RTI' and dzt_name='DenominazioneATI'

		select @Forma_Partecipazione_SecondaFase=value from ctl_doc_Value with (nolock)  where idheader= @IdOff and dse_id='TESTATA_RTI' and dzt_name='DenominazioneATI'

		--controllare direttamente dulla tabella document_offerta_partecipanti 
		--se esiste qualcosa a sinistra e non adestra e viceversa 
		--è cambiata forma e azienda 

		--metto in una temp le partecipanti del primo giro
		select * into #RtiPrimoGiro
			from document_offerta_partecipanti with (nolock)
			where
				idheader=@IdRisp_PrimaFase

		--metto in una temp le partecipanti del secondo  giro
		select * into #RtiSecondoGiro
			from document_offerta_partecipanti with (nolock)
			where
				idheader=@IdOff

		-- controllo se rti cambiata prima o dopo
		if exists 
			(
			select idazi 	
				from #RtiPrimoGiro
					where tiporiferimento='RTI' and ruolo_impresa <>'mandataria'
						and idazi not in (
								select idazi 	
									from #RtiSecondoGiro
									where tiporiferimento='RTI' and ruolo_impresa <>'mandataria'
									)
			union

			select idazi 	
				from #RtiSecondoGiro
					where tiporiferimento='RTI' and ruolo_impresa <>'mandataria'
						and idazi not in (
								select idazi 	
									from #RtiPrimoGiro
									where tiporiferimento='RTI' and ruolo_impresa <>'mandataria'
									)

			)
		begin
			set @CambioFormaPartecipazione =1
		end

		--controllo se sono cambiate le ausiliare/ausiliate
		if @CambioFormaPartecipazione = 0
		begin
			if exists 
				(
					--ausiliata primo giro non presente sul secondogiro
					select idaziriferimento 
						from #RtiPrimoGiro
						where tiporiferimento='AUSILIARIE'
							and IdAziRiferimento not in (
											select idaziriferimento 
											from #RtiSecondoGiro
											where tiporiferimento='AUSILIARIE'
											)
				
					union
					--ausiliata secondogiro non presente sul primo giro
					select idaziriferimento 
						from #RtiSecondoGiro
						where tiporiferimento='AUSILIARIE'
							and IdAziRiferimento not in (
											select idaziriferimento 
											from #RtiPrimoGiro
											where tiporiferimento='AUSILIARIE'
											)
					union
					--chi ausilia primo giro non presente sul secondogiro
					select idazi 
						from #RtiPrimoGiro
						where tiporiferimento='AUSILIARIE'
							and IdAziRiferimento not in (
											select idazi 
											from #RtiSecondoGiro
											where tiporiferimento='AUSILIARIE'
											)
					union
					--chi ausilia secondogiro  non presente sul primo giro
					select idazi 
						from #RtiSecondoGiro
						where tiporiferimento='AUSILIARIE'
							and IdAziRiferimento not in (
											select idazi 
											from #RtiPrimoGiro
											where tiporiferimento='AUSILIARIE'
											)

				)

			begin
				set @CambioFormaPartecipazione =1
			end
		end
		
		--controllo se sono cambiate le ESECUTRICI
		if @CambioFormaPartecipazione = 0
		begin
			if exists 
				(
					--esecutrici primo giro non presente sul secondogiro
					select idaziriferimento 
						from #RtiPrimoGiro
						where tiporiferimento='ESECUTRICI'
							and IdAziRiferimento not in (
											select idaziriferimento 
											from #RtiSecondoGiro
											where tiporiferimento='ESECUTRICI'
											)
				
					union
					--esecutrici secondogiro non presente sul primo giro
					select idaziriferimento 
						from #RtiSecondoGiro
						where tiporiferimento='ESECUTRICI'
							and IdAziRiferimento not in (
											select idaziriferimento 
											from #RtiPrimoGiro
											where tiporiferimento='ESECUTRICI'
											)
					union
					--chi esecutrici primo giro non presente sul secondogiro
					select idazi 
						from #RtiPrimoGiro
						where tiporiferimento='ESECUTRICI'
							and IdAziRiferimento not in (
											select idazi 
											from #RtiSecondoGiro
											where tiporiferimento='ESECUTRICI'
											)
					union
					--chi esecutrici secondogiro  non presente sul primo giro
					select idazi 
						from #RtiSecondoGiro
						where tiporiferimento='ESECUTRICI'
							and IdAziRiferimento not in (
											select idazi 
											from #RtiPrimoGiro
											where tiporiferimento='ESECUTRICI'
											)
				)
			begin
				set @CambioFormaPartecipazione =1
			end
		end

		--if ( @Forma_Partecipazione_PrimaFase <> @Forma_Partecipazione_SecondaFase)
		if @CambioFormaPartecipazione = 1
		begin

			--cancello i warning memorizzati se ci sono
			delete Document_Pda_Offerte_Anomalie where IdHeader= @idPda and IdRowOfferta = @idrow and IdFornitore = @IDFornitore and TipoAnomalia ='CAMBIO_FORMA_PARTECIPAZIONE'

			
			insert into  Document_Pda_Offerte_Anomalie 
					( [IdHeader], [IdRowOfferta], [IdDocOff], [IdFornitore], [Descrizione], [Data], [TipoAnomalia] ) 
				values
				( @idPda, @idrow, @IdOff, @IDFornitore, 'il fornitore ha cambiato la forma di partecipazione', getdate(), 'MODULO_QUESTIONARIO_AMMINISTRATIVO' ) 
		end			

	end
	
end



GO
