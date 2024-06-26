USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ASSOCIA_MODELLI_NEW_AMP_GAMMA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_ASSOCIA_MODELLI_NEW_AMP_GAMMA] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	


		--per i bandi semplificati dove è prevista l'apertura per busta si devono creare i dati delle buste
		--declare @idDoc int

		declare @CriterioAggiudicazioneGara varchar(50)
		declare @Conformita varchar(50)
		declare @TipoDoc varchar(500)
		declare @TipoBando varchar(500)
		declare @idrow int
		declare @newID int
		declare @idBando int
		declare @Divisione_Lotti varchar(20)

		--set @idDoc  = <ID_DOC>

		select @TipoDoc  = o.TipoDoc , @TipoBando = TipoBando  , @idBando = o.LinkedDoc , @Divisione_Lotti = Divisione_lotti, 
				@CriterioAggiudicazioneGara=CriterioAggiudicazioneGara,@Conformita=isnull( Conformita , 'No')
			from ctl_doc o with (nolock)
				inner join ctl_doc b with (nolock) on o.LinkedDoc = b.id
				inner join document_bando with (nolock) on b.id = idheader  where o.id = @idDoc


		--svuoto le firme eventualmente caricate  rimosso con kpf 465113 dietro confronto tra MG SABATO E CARLA
		--update CTL_DOC_SIGN 
		--    set F1_SIGN_HASH = '', F1_SIGN_ATTACH = '' , F1_SIGN_LOCK = 0 ,  F2_SIGN_HASH = '' , F2_SIGN_ATTACH = '' , F2_SIGN_LOCK = 0 , F3_SIGN_HASH = '' , F3_SIGN_ATTACH = '' , F3_SIGN_LOCK = 0 , F4_SIGN_HASH = '' , F4_SIGN_ATTACH = '' , F4_SIGN_LOCK = 0
		--    where  idHeader=@idDoc


		--set @TipoDoc = 'BANDO_SEMPLIFICATO'
		if @TipoDoc = 'OFFERTA'
		begin 
			--if exists( select * from document_bando where idheader = @idBando and ( Conformita = 'Ex-Ante' or CriterioAggiudicazioneGara = '15532' ) )
			--	and @Divisione_Lotti <> '0'
			
	
			
				--update Document_MicroLotti_Dettagli 	
				--	set idHeaderLotto = id
				--	where idHeader=@idDoc and TipoDoc = @TipoDoc

				-- per ogni lotto cancello e ricreo il riferimento del modello da utilizzare per le buste tecniche ed economiche
				delete from CTL_DOC_SECTION_MODEL 
									where IdHeader in 
													( select distinct offer.idHeaderLotto 
														from Document_MicroLotti_Dettagli offer with (nolock)	
															inner join Document_MicroLotti_Dettagli bando with (nolock)	on 
																	bando.IdHeader = @idBando and bando.TipoDoc = 'BANDO_GARA'
																		and bando.NumeroLotto = offer.NumeroLotto
																		and bando.voce = offer.voce and bando.AmpiezzaGamma='1'
															where offer.idHeader=@idDoc and offer.TipoDoc = @TipoDoc  
													) 											
											and DSE_ID in ( 'PRODOTTI_GAMMA', 'PRODOTTI_GAMMA_TEC', 'PRODOTTI_GAMMA_ECO' )
											--'OFFERTA_AMPIEZZA_ECO' , 'OFFERTA_AMPIEZZA_TEC' , 'OFFERTA_AMPIEZZA' )


				select 
						@idbando = doc.LinkedDoc
					from ctl_doc as doc with(nolock) 
						--inner join Document_MicroLotti_Dettagli as lot with(nolock) on doc.Id = LOT.IdHeader --and Voce = '0' and NumeroLotto = @lotto
					where doc.id = @iddoc --recupero bando
				
				declare @idmodelloAcquisto varchar(5000)
				declare @idmodelloAmpiezzaGamma varchar(5000)
				declare @nomeModelloAmpGamma varchar(5000)
				declare @nomeModelloAmpGammaTemp varchar(5000)

				select @idmodelloAcquisto = Value						
					from CTL_DOC_Value with(nolock)
					where idheader = @idbando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' --idModello acquisto

				select @idmodelloAmpiezzaGamma = Value 
					from CTL_DOC_Value with(nolock)
					where IdHeader = @idmodelloAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma' --idmodelloAmpiezzaGamma
			
				select @nomeModelloAmpGamma = Titolo from CTL_DOC with(nolock) where id = @idmodelloAmpiezzaGamma

				

				--controllo se il modello di ampiezza di gamma prevede busta economica 
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_Offerta' 
											and DSE_ID = 'MODELLI' and Value <> '')  
				
					--se nel modello di ampiezza di gamma è presente anche la busta tecnica apro il modello busta economica dedicata
					if exists(
								select * from ctl_doc_value with(nolock) 
									where IdHeader = @idmodelloAmpiezzaGamma 
												and DZT_Name = 'MOD_OffertaTec' 
												and DSE_ID = 'MODELLI' and Value <> ''
								)
					begin
						set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_Offerta' -- se l'ampiezza di gamma prevede un modello dedicato
					end
					else --altrimenti apro offertaInput con tutti i campi presenti nel modello
					begin
						set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT' 
					end
				
			
				else
				begin

					-- nel caso in cui non è prevista l'ampiezza di gamma economica o non aprima e diamo errore oppure rappresentiamo con il modello complessivo

					set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT'
				end

				


				insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) 
					select distinct offer.idHeaderLotto , 'PRODOTTI_GAMMA' ,  'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT' 
						from Document_MicroLotti_Dettagli offer with (nolock)	
								inner join Document_MicroLotti_Dettagli bando with (nolock)	on 
										bando.IdHeader = @idBando and bando.TipoDoc = 'BANDO_GARA'
											and bando.NumeroLotto = offer.NumeroLotto
											and bando.voce = offer.voce and bando.AmpiezzaGamma='1'
												where offer.idHeader=@idDoc and offer.TipoDoc = @TipoDoc  

				insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) 
						select distinct offer.idHeaderLotto , 'PRODOTTI_GAMMA_TEC' ,  'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT' 
							from Document_MicroLotti_Dettagli offer with (nolock)	
								inner join Document_MicroLotti_Dettagli bando with (nolock)	on 
										bando.IdHeader = @idBando and bando.TipoDoc = 'BANDO_GARA'
											and bando.NumeroLotto = offer.NumeroLotto
											and bando.voce = offer.voce and bando.AmpiezzaGamma='1'
												where offer.idHeader=@idDoc and offer.TipoDoc = @TipoDoc 

				-- associa il modello economica
				insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) 
					
					select distinct offer.idHeaderLotto , 'PRODOTTI_GAMMA_ECO' , 						
							-- testiamo la presenza di una busta tecnica dedicata per stabilire il modello corretto da associare
							case when CriterioAggiudicazioneGara = '15532' or CriterioAggiudicazioneGara = '25532' or  Conformita <> 'No'
								-- esiste busta tecnica dedicata 
									then @nomeModelloAmpGammaTemp 
							else
									'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT' 
							end								
						
						from Document_MicroLotti_Dettagli offer with (nolock)	
								inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO with (nolock) on idBando=@idbando
																									and N_Lotto = offer.NumeroLotto 
								inner join Document_MicroLotti_Dettagli bando with (nolock)	on 
										bando.IdHeader = @idBando and bando.TipoDoc = 'BANDO_GARA'
											and bando.NumeroLotto = offer.NumeroLotto
											and bando.voce = offer.voce and bando.AmpiezzaGamma='1'
												where offer.idHeader=@idDoc and offer.TipoDoc = @TipoDoc 

									
			if exists( select * from document_bando with (nolock) where idheader = @idBando and Divisione_lotti<>'0' )
			begin
			
				insert into Document_Microlotto_Firme ( idheader ) 
					select id  from Document_MicroLotti_Dettagli  with (nolock)	where idHeader=@idDoc and TipoDoc = @TipoDoc and Voce = 0 
							and  id not in  ( select idheader from Document_Microlotto_Firme )

			end



		end

END















GO
