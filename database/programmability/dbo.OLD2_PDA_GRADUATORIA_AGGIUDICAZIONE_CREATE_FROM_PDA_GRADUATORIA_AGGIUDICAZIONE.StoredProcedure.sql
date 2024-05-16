USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_PDA_GRADUATORIA_AGGIUDICAZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [AFLink_PA_Dev]
--GO

--/****** Object:  StoredProcedure [dbo].[PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_PDA_GRADUATORIA_AGGIUDICAZIONE]    Script Date: 26/03/2018 11:22:29 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO




CREATE PROCEDURE [dbo].[OLD2_PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_PDA_GRADUATORIA_AGGIUDICAZIONE]
	( @idDocGraD int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON
	
	--declare @idDocGraD int , @IdUser int

	--set @idDocGraD=185446
	--set @IdUser=42727

	declare @idNew  as INT

	declare @PrevDoc as INT
	set @PrevDoc=0
	
	declare @StatoRiga varchar(50)
	
	declare @JumpCheck varchar(100)


	declare @Errore as nvarchar(2000)
	declare @Fascicolo as varchar(100)
	declare @DivisioneLotti as varchar(100)
	declare @NumeroLotto		varchar(200)
	declare @Azienda			varchar(200)
	declare @IdDoc as int


	--recupero azienda utente collegato
	select @Azienda=pfuidazi from ProfiliUtente where IdPfu=@IdUser

	--recupero id del lotto a cui è relativa la graduatoria
	select @IdDoc=linkeddoc from CTL_DOC where Id=@idDocGraD

	set @Errore = ''

	--AGGIUNGIAMO UN CONTROLLO per la creazione che deve essere il presidente della parte economica, 3 o prima commissione
	IF NOT EXISTS ( select * 
						from Document_MicroLotti_Dettagli D
							inner join ctl_doc C on D.IdHeader=C.Id  --PDA
							inner join ctl_doc B on B.id=C.LinkedDoc  --BANDO_GARA
							inner join ctl_doc com on B.id=Com.LinkedDoc  and com.Deleted=0 and com.TipoDoc='COMMISSIONE_PDA' and com.StatoFunzionale='Pubblicato' --COMMISSIONE
							left join Document_CommissionePda_Utenti DC on DC.TipoCommissione='C' and DC.IdHeader=com.Id and DC.RuoloCommissione='15548' and dc.UtenteCommissione=@IdUser ---COMMISSIONE ECONOMICA
							left join Document_CommissionePda_Utenti DA on DA.TipoCommissione='A' and DA.IdHeader=com.Id and DA.RuoloCommissione='15548'and da.UtenteCommissione=@IdUser ---COMMISSIONE SEGGIO DI GARA
						where D.id=@idDoc and ( dc.IdRow IS NOT NULL or da.IdRow is not NULL )
				)
	BEGIN
		set  @Errore = 'La creazione del documento e'' consentita al presidente della parte economica o prima commissione'
	END

	
	if @Errore = ''
	BEGIN
		
		-- cerco una versione precedente del documento in lavorazione
		set @idNew = null
		select @idNew = id from CTL_DOC where PrevDoc =@idDocGraD and LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_GRADUATORIA_AGGIUDICAZIONE' ) and statofunzionale not in ( 'Annullato','Variato' )


		-- se non esiste lo creo per copia dal precedente
		if @idNew is null
		BEGIN
			
			----------------------------------------------------
			-- creo il documento di Graduatoria Aggiudicazione per copia dal precedente
			----------------------------------------------------
			INSERT into CTL_DOC ( IdPfu,  TipoDoc,  Titolo , LinkedDoc , Data , DataInvio , Statofunzionale, fascicolo , JumpCheck , Azienda, Prevdoc, body)
					select	@IdUser as idpfu , 'PDA_GRADUATORIA_AGGIUDICAZIONE' as TipoDoc ,  
						'Modifica ' + Titolo,  LinkedDoc
						,getDate() as Data , null as DataInvio , 'InLavorazione' as StatoFunzionale, fascicolo , JumpCheck
						, @Azienda, @idDocGraD, body
						from CTL_DOC where Id= @idDocGraD

			set @idNew = SCOPE_IDENTITY()


			--RICOPIA LA CTL_DOC_VALUE
			Insert into CTL_DOC_Value (IdHeader, DSE_ID, Row, DZT_Name, Value)
				select @idNew, DSE_ID, Row, DZT_Name, Value
					from CTL_DOC_Value where IdHeader=@idDocGraD



			-- RICOPIO LA MICROLOTTI DETTAGLI 	
			--declare @Filter as varchar(500)
			--declare @DestListField as varchar(500)
			--set @Filter = ' Tipodoc=''PDA_GRADUATORIA_AGGIUDICAZIONE'' '
			--set @DestListField = ' ''PDA_GRADUATORIA_AGGIUDICAZIONE'' as TipoDoc '
		  
			--exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDocGraD, @idNew, 'IdHeader', 
			--					' Id,IdHeader,TipoDoc ', 
			--					@Filter, 
			--					' TipoDoc ', 
			--					@DestListField,
			--					' id '			


			-- riporto tutte le offerte ammesse legate al lotto
			-- e riprendo le percentuali di assegnazioni dal doc precedente
			insert into Document_MicroLotti_Dettagli ( idHeader, TipoDoc ,  idHeaderLotto , Aggiudicata , Posizione , Graduatoria , Sorteggio , ValoreOfferta , NumeroLotto , Voce , PercAgg ,ValoreImportoLotto )
				select @idNew as idHeader, 'PDA_GRADUATORIA_AGGIUDICAZIONE' as  TipoDoc 
							,PREC_GRAD.id , 
							--o.idAziPartecipante , l.Posizione , l.Graduatoria , l.Sorteggio , l.ValoreOfferta , l.NumeroLotto , l.Voce , PREC_GRAD.PercAgg  , l.ValoreImportoLotto 
							PREC_GRAD.Aggiudicata,PREC_GRAD.Posizione,PREC_GRAD.Graduatoria, PREC_GRAD.Sorteggio , PREC_GRAD.ValoreOfferta , PREC_GRAD.NumeroLotto , PREC_GRAD.Voce , PREC_GRAD.PercAgg  , PREC_GRAD.ValoreImportoLotto 
					from Document_MicroLotti_Dettagli g
							inner join document_pda_offerte o on o.IdHeader = g.IdHeader
							inner join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
							inner join Document_MicroLotti_Dettagli PREC_GRAD on PREC_GRAD.IdHeader=@idDocGraD and PREC_GRAD.TipoDoc='PDA_GRADUATORIA_AGGIUDICAZIONE' and PREC_GRAD.Aggiudicata = o.idAziPartecipante
						where g.id = @idDoc 
						order by L.Graduatoria , L.Sorteggio


		END	
	END	
	
	
		
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @idNew as id,'' as Errore
	
	end
	else
	begin
		-- ritorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

	SET NOCOUNT OFF
END














GO
