USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_SEMP_OFF_EVAL_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[BANDO_SEMP_OFF_EVAL_CREATE_FROM_BANDO_GARA] ( @idlotto int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Idbando as INT	
	declare @IdlottoAQ as INT	
	declare @IdAQ as INT	
	
	declare @Errore as nvarchar(2000)
	declare @PunteggioMax float

	set @Errore=''
	set @Idbando = 0
	set @IdlottoAQ = 0
	set @IdAQ=0

	--120074 da recupe
	--120075 OK
	select @Idbando=IdHeader from Document_MicroLotti_Dettagli with(NOLOCK) where id=@idlotto

	--VERIFICA SE SONO SU UN RILANCIO COMPETITIVO 
	IF EXISTS ( select * from Document_Bando with(NOLOCK) where idHeader=@Idbando and ISNULL(TipoProceduraCaratteristica,'')='RilancioCompetitivo' )
	BEGIN
		--SE NON SONO PRESENTI SPECIALIZZAZIONI SUL LOTTO INIZIALIZZO IL DOCUMENTO
		IF NOT EXISTS (select * from Document_Microlotto_Valutazione where idHeader=@idlotto)
		BEGIN
			select @IdlottoAQ=DMAQ.id, @IdAQ=CAQ.id
				from Document_MicroLotti_Dettagli DMRC with(NOLOCK)
					inner join ctl_doc CRC with(NOLOCK) on CRC.id=DMRC.IdHeader and CRC.TipoDoc='BANDO_GARA'
					inner join ctl_doc CAQ with(NOLOCK) on CAQ.id=CRC.LinkedDoc and CAQ.TipoDoc='BANDO_GARA'
					inner join Document_MicroLotti_Dettagli DMAQ with(NOLOCK) on DMAQ.IdHeader=CAQ.Id and DMAQ.TipoDoc='BANDO_GARA' and DMAQ.NumeroLotto=DMRC.NumeroLotto and DMAQ.Voce=0
				where DMRC.id=@idlotto and DMRC.TipoDoc='BANDO_GARA'


			-- se esiste un criterio specializzato inseriamo il criterio per copia dei dati base ma senza i criteri tecnici ed economici
			if exists ( select value from Document_Microlotti_DOC_Value with(NOLOCK) where dse_id='CRITERI_AGGIUDICAZIONE' and dzt_name='CriterioAggiudicazioneGara' and idheader= @IdlottoAQ )
			begin
				-- RIPORTO LA SPECIALIZZAZIONE
				INSERT INTO Document_Microlotti_DOC_Value( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select @idlotto, DSE_ID, Row, DZT_Name, Value 
						from Document_Microlotti_DOC_Value with(nolock)
						where idheader = @IdlottoAQ


				if exists( select [idRow] from Document_Microlotto_Valutazione with(nolock) where idheader = @IdlottoAQ and TipoDoc='LOTTO' )
				begin

					select @PunteggioMax = value from Document_Microlotti_DOC_Value where idheader = @IdlottoAQ and DZT_Name = 'PunteggioTecMaxEredit' and DSE_ID = 'AQ_EREDITA_TEC' 

					-- CREO IL CRITERIO PER EREDITARE I PUNTEGGI
					insert into Document_Microlotto_Valutazione
						(idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio )
						values( @idlotto , 'LOTTO' , 'ereditato' , 'Punteggio ereditato' , @PunteggioMax , '' , ''  )


					-- CREO LE RIGHE PER INDICARE COSA EREDITARE
					insert into Document_Microlotto_Valutazione
						(idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio,PunteggioMin,Eredita)
						select @idlotto,'LOTTO_CRITERI_AQ_EREDITA_TEC' as TipoDoc,CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio, PunteggioMin,Eredita
							from Document_Microlotto_Valutazione with(nolock)
							where idheader = @IdlottoAQ and TipoDoc='LOTTO' and Eredita = '1'


				 end
			  end
			  else --SE NON LI TROVA SPECIALIZZATI RIPRENDE QUELLI PREVALENTI SU AQ
			  begin
					-- aggiungo i criteri di valutazione ereditati
					select @PunteggioMax = value from CTL_DOC_Value where idheader = @IdAQ and DZT_Name = 'PunteggioTecMaxEredit' and DSE_ID = 'AQ_EREDITA_TEC' 

					-- CREO IL CRITERIO PER EREDITARE I PUNTEGGI
					IF EXISTS ( select * from Document_Microlotto_Valutazione with(nolock) where idheader = @IdAQ and TipoDoc='BANDO_GARA' and Eredita = '1')
					BEGIN
						insert into Document_Microlotto_Valutazione
							(idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio )
							values( @idlotto , 'LOTTO' , 'ereditato' , 'Punteggio ereditato' , @PunteggioMax , '' , ''  )
					END

					-- CREO LE RIGHE PER INDICARE COSA EREDITARE
					insert into Document_Microlotto_Valutazione
						(idHeader, TipoDoc, CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio,PunteggioMin,Eredita)
						select @idlotto,'LOTTO_CRITERI_AQ_EREDITA_TEC' as TipoDoc,CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio, PunteggioMin,'1'
							from Document_Microlotto_Valutazione with(nolock)
							where idheader = @IdAQ and TipoDoc='BANDO_GARA' and Eredita = '1'
			  end



		END
		--INSERT PER BLOCCARE I CAMPI PunteggioTecMinEredit PunteggioTecMaxEredit
		insert into Document_Microlotti_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value) 
			select @idlotto,'AQ_EREDITA_TEC',0,'NotEditable',' PunteggioTecMaxEredit PunteggioTecMinEredit '

	END

	if @Errore=''

		-- rirorna l'id del documento
		select @idlotto as id
	
	else

	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end
	
	
END






GO
