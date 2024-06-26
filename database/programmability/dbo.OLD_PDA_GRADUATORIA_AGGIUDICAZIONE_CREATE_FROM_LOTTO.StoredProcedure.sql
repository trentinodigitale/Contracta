USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dbo].[OLD_PDA_GRADUATORIA_AGGIUDICAZIONE_CREATE_FROM_LOTTO]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON

	declare @Id as INT
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
		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_GRADUATORIA_AGGIUDICAZIONE' ) and statofunzionale not in ( 'Annullato','Variato' )


		-- se non esiste lo creo
		if @id is null
		begin

			-- se ci sono lotti per i quali è presente un ammesso con riserva si blocca la creazione
			if exists( 
	
				--select l.*
				--	from Document_MicroLotti_Dettagli g
				--		inner join document_pda_offerte o on o.IdHeader = g.IdHeader
				--		inner join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
				--	where g.id = @idDoc and o.StatoPDA = '22' -- ammesso con riserva


				select o.IdMsgFornitore
				from
					Document_MicroLotti_Dettagli g 
					inner join document_pda_offerte o with (nolock) on o.IdHeader=g.IdHeader
					inner join Document_MicroLotti_Dettagli l with (nolock) on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'escluso' , 'esclusoEco' )
																	and l.NumeroLotto=g.NumeroLotto
							left join CTL_DOC EL with (nolock)on EL.linkeddoc=o.IdMsg and EL.TipoDoc='ESCLUDI_LOTTI' and EL.Deleted=0 and EL.StatoFunzionale='Confermato'
							left join 	ESCLUDI_LOTTI_LOTTI_VIEW ELD with (nolock) on ELD.IdHeader=EL.Id and ELD.NumeroLotto=l.NumeroLotto 
						
				where 
					
					g.Id= @idDoc
					
					and
						( 
							---- ammesso con riserva su intera offerta
							( o.StatoPDA = '22' and EL.Id is null)
							or 
							-- ammesso con riserva non sciolta sul singolo lotto
							( o.StatoPDA = '22' and  ELD.StatoLotto = 'AmmessoRiserva' and ELD.EsitoRiserva <> 'OK'  )
						)

				) 
			begin 
				-- ritorna l'errore
				set @Errore = 'E'' presente un fornitore con stato ammesso con riserva. Prima di procedere e'' necessario cambiare lo stato di questo fornitore'

			end
	
			select   
					@Fascicolo=Fascicolo 
				   , @JumpCheck = case when isnull( TipoAccordoQuadro , '' ) = '' then 'MonoRound' else TipoAccordoQuadro end
				   , @DivisioneLotti = b.Divisione_lotti
				   , @NumeroLotto = NumeroLotto
				   , @Azienda = p.Azienda

				from Document_MicroLotti_Dettagli l
					inner join ctl_doc p on  p.id = l.IdHeader
					inner join document_bando b on b.idheader = p.LinkedDoc
					inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c on idBando = b.idheader and ( N_Lotto = l.NumeroLotto or N_Lotto is null ) 
				where l.id = @idDoc 


			if @Errore = '' and exists( 
						select *
							from Document_MicroLotti_Dettagli g
							where g.id = @idDoc and StatoRiga <> 'PercAggiudicazione' )

			begin
				set @Errore = 'Per aprire il documento di "Graduatoria Aggiudicazione" e'' necessario prima effettuare il calcolo economico'
			end

		
		
			-----------------------------------------------
			-- se non ci sono blocchi si crea il documento 
			-----------------------------------------------
			if @Errore = ''
			begin

	

				----------------------------------------------------
				-- creo il documento di Graduatoria Aggiudicazione
				----------------------------------------------------
				INSERT into CTL_DOC ( IdPfu,  TipoDoc,  Titolo , LinkedDoc , Data , DataInvio , Statofunzionale, fascicolo , JumpCheck , Azienda)
						select	@IdUser as idpfu , 'PDA_GRADUATORIA_AGGIUDICAZIONE' as TipoDoc ,  
							'Graduatoria Aggiudicazione' + case when @DivisioneLotti = '0' then '' else ' - Lotto ' + @NumeroLotto  end as Titolo,  @idDoc as LinkedDoc
							,getDate() as Data , null as DataInvio , 'InLavorazione' as StatoFunzionale, @fascicolo , @JumpCheck
							, @Azienda

				set @idNew = SCOPE_IDENTITY()



				-- riporto tutte le offerte ammesse legate al lotto
				insert into Document_MicroLotti_Dettagli ( idHeader, TipoDoc ,  idHeaderLotto , Aggiudicata , Posizione , Graduatoria , Sorteggio , ValoreOfferta , NumeroLotto , Voce , PercAgg ,ValoreImportoLotto )
					select @idNew as idHeader, 'PDA_GRADUATORIA_AGGIUDICAZIONE' as  TipoDoc 
								,l.id , o.idAziPartecipante , l.Posizione , l.Graduatoria , l.Sorteggio , l.ValoreOfferta , l.NumeroLotto , l.Voce , l.PercAgg  , l.ValoreImportoLotto 
						from Document_MicroLotti_Dettagli g
								inner join document_pda_offerte o on o.IdHeader = g.IdHeader
								inner join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
							where g.id = @idDoc 
							order by L.Graduatoria , L.Sorteggio


				set @id = @idNew


			end	

		end	
	END	
		
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id,'' as Errore
	
	end
	else
	begin
		-- ritorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

	SET NOCOUNT OFF
END














GO
