USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONFORMITA_MICROLOTTI_VERIFICA_LOTTO_MULTIFORNITORE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[CONFORMITA_MICROLOTTI_VERIFICA_LOTTO_MULTIFORNITORE]( @IdDoc as int, @NumeroLotto as varchar(10),@IdUser as int  )
as
begin

	--declare @idDoc as int
	--declare @NumeroLotto as int
	--declare @IdUser as int

	--set @idDoc = 407552
	--set @NumeroLotto = 2
	--set @IdUser = 42727

	declare @idgara as int
	declare @IdPda as int
	declare @IdDocGraduatoria as int

	--drop table #temp_gara_info_lotti

	--recupero id della gara e della pda dal doc CONFORMITA_MICROLOTTI
	select @idgara=db.idHeader,@IdPda=pda.Id
		from CTL_DOC c1 with(nolock)
				inner join CTL_DOC pda with(nolock) on pda.Id = c1.LinkedDoc and pda.TipoDoc = 'PDA_MICROLOTTI'
				inner join Document_Bando db with(nolock) on db.idHeader = pda.LinkedDoc
		where c1.id = @IdDoc and c1.TipoDoc = 'CONFORMITA_MICROLOTTI'

	--mi conservo le info TipoAggiudicazione dei lotti della gara in una temp
	select N_Lotto , TipoAggiudicazione 
		into #temp_gara_info_lotti 
		from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idgara and N_Lotto=@NumeroLotto

	--select @idgara  
	--select @IdPda  
	--select * from #temp_gara_info_lotti
	--se lotto multifornitore
	if exists (select N_Lotto from #temp_gara_info_lotti where TipoAggiudicazione ='multifornitore')
	begin

		--CONSERVO I NON CONFORMI IN UNA TEMP
		select dettConf.Aggiudicata into #Temp_NonConformi

					from Document_MicroLotti_Dettagli m with(nolock) 
						inner join CTL_DOC do with(nolock) on do.linkeddoc = m.id and do.tipodoc = 'CONFORMITA_MICROLOTTI_OFF'
						inner join Document_MicroLotti_Dettagli dettConf with(nolock)  on dettConf.idheader = do.id and dettConf.tipodoc=do.tipodoc
																							and dettConf.StatoRiga='NonConforme'
					where m.IdHeader = @IdDoc  and m.tipodoc='CONFORMITA_MICROLOTTI' and m.NumeroLotto = @NumeroLotto


		--SE ESISTE UN NON CONFORME (posizione=esclusa condividere con sabato)
		if exists ( select Aggiudicata from  #Temp_NonConformi )
		begin
			
			--RECUPERO ID GRADUATORIA DEL LOTTO
			select @IdDocGraduatoria = id
			--select id
				from ctl_doc with (nolock)
				where deleted = 0 and TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' 
					--and statofunzionale in ( 'Confermato' )
					and linkedDoc in (select id 
										from 
											Document_MicroLotti_Dettagli with (nolock)
										where idheader = @IdPda and NumeroLotto = @NumeroLotto and Voce = 0 
										and TipoDoc = 'PDA_MICROLOTTI' ) 
			
			--se esiste la percentuale <> 100 sul documento di graduatoria per i non conformi
			--allora annullo il documento di PDA_GRADUATORIA_AGGIUDICAZIONE
			if exists (select * 
							from document_microlotti_dettagli gra with (nolock)
								INNER JOIN #Temp_NonConformi T on T.Aggiudicata = gra.Aggiudicata
							where idheader = @IdDocGraduatoria and TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and percagg <> 100  )
			begin
				
				update ctl_doc set statofunzionale='Annullato' where id = @IdDocGraduatoria

				--inserisco cronologia sulla PDA
				insert into CTL_ApprovalSteps 
							( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
					values ('PDA_MICROLOTTI' , @IdPda , 'CONFORMITA_MICROLOTTI' , 'Annullata Graduatoria di Aggiudicazione lotto ['+ @NumeroLotto + '] per mancata confomità di uno dei fornitori idonei' , @IdUser, '', 1 , getdate() )


			end
			
		end

	end


end
GO
