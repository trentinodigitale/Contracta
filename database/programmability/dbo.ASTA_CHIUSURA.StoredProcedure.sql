USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ASTA_CHIUSURA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc  [dbo].[ASTA_CHIUSURA] ( @idDoc int , @IdPFU int ) as
begin

	IF  exists( select * from document_asta where idheader = @idDoc and  StatoAsta = 'InCorso' )
	BEGIN

		declare @idHeaderLottoOff		int
		declare @IdOff					int
		declare @ValoreRilancio			float
		declare @ValoreRibasso			float
		declare @ValoreEconomico		float
		declare @ValoreSconto			float
		declare @src					int
		declare @dest					int
		DECLARE @idRow					INT
		declare @DataRilancio			datetime
		declare @NumPartecipanti			int
		
		set @NumPartecipanti=0

		update document_asta set StatoAsta = 'Chiusa' where idheader = @idDoc

		
		-- tutti i rilanci eseguiti vengono posti nello stato di sended e vengono ripristinati i valori dell'ultimo rilancio accettato
		update O
			set StatoDoc = 'Invalidate' , Statofunzionale = 'Annullato' 
			from CTL_DOC as O 
			where O.LinkedDoc = @idDoc and o.TipoDoc = 'OFFERTA_ASTA' and Protocollo = '' 

		update O
			set StatoDoc = 'Saved' , Statofunzionale = 'InAttesaFirma' 
			from CTL_DOC as O 
			where O.LinkedDoc = @idDoc and o.TipoDoc = 'OFFERTA_ASTA' and Protocollo <>'' 

		--recupero numero partecipanti (che hanno fatto almeno un rilancio) e lo aggiorno sull'asta
		select @NumPartecipanti=count(*) from CTL_DOC where LinkedDoc = @idDoc and TipoDoc = 'OFFERTA_ASTA' and Protocollo <>'' 
		update document_bando set RecivedIstanze =@NumPartecipanti where idheader=@idDoc


		--schedulo processo per caricare nel dossier le offerte in attesa di firma
		insert into CTL_Schedule_Process
			(IdDoc, IdUser, DPR_DOC_ID, DPR_ID, DataRequestExec)
		select id ,idpfu ,'OFFERTA_ASTA','LOAD_DOSSIER',getdate()
			from
				ctl_doc 
			where
				linkeddoc = @idDoc and TipoDoc = 'OFFERTA_ASTA' and Statofunzionale = 'InAttesaFirma' 
		


		-------------------------------------------------------------
		-- per ogni offerta che ha partecipato almeno ad un rilancio
		-- si ricopiano i valori dell'ultimo rilancio effettuato
		-------------------------------------------------------------
		declare CurRilanci Cursor Static for 
			select max( idRow ) as idRow , O.ID   
				from CTL_DOC as O 
					inner join Document_Asta_Rilanci R on R.idAziFornitore = O.azienda and O.linkeddoc = R.idheader
				where O.LinkedDoc = @idDoc and o.TipoDoc = 'OFFERTA_ASTA'
				group by O.id

		open CurRilanci

		FETCH NEXT FROM CurRilanci INTO @idRow,@IdOff 
		WHILE @@FETCH_STATUS = 0
		BEGIN

			select  @idHeaderLottoOff  = idHeaderLottoOff ,  @ValoreRilancio  = [ValoreRilancio] , @ValoreRibasso  = [ValoreRibasso] 
					, @ValoreEconomico  = [ValoreEconomico] , @ValoreSconto = [ValoreSconto] , @DataRilancio = DataRilancio
				from Document_Asta_Rilanci
				where idRow = @idRow

			update ctl_doc set Datainvio = @DataRilancio , Titolo = case when isnull( titolo ,'' ) = '' then 'Offerta per Asta' else Titolo end where id = @IdOff

			-- riporto i totali
			update CTL_DOC_VALUE set Value = @ValoreRibasso where IdHeader = @IdOff and  DZT_Name = 'ValoreRibasso' and  DSE_ID = 'TOTALI' 
			update CTL_DOC_VALUE set Value = @ValoreEconomico where IdHeader = @IdOff and  DZT_Name = 'ValoreEconomico' and  DSE_ID = 'TOTALI' 
			update CTL_DOC_VALUE set Value = @ValoreSconto where IdHeader = @IdOff and  DZT_Name = 'ValoreSconto' and  DSE_ID = 'TOTALI' 
			update CTL_DOC_VALUE set Value = @ValoreRilancio where IdHeader = @IdOff and  DZT_Name = 'ValoreOfferta' and  DSE_ID = 'TESTATA_PRODOTTI' 
			
			-- riporto i valori sull offerta
			declare CurProg Cursor Static for 
				select  s.id , d.id
						from Document_MicroLotti_Dettagli s
						inner join Document_MicroLotti_Dettagli d on  s.idheader = d.IdHeader and d.TipoDoc = 'OFFERTA_ASTA' and s.NumeroRiga = d.NumeroRiga
					where s.idheader = @idOff and s.tipoDoc = 'OFFERTA_RILANCIO' and s.idHeaderLotto = @idHeaderLottoOff
					order by s.id

			open CurProg

			FETCH NEXT FROM CurProg INTO @src,@dest
			WHILE @@FETCH_STATUS = 0
			BEGIN
				 
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  , @src ,@dest , ',Id,IdHeader,TipoDoc,EsitoRiga,idHeaderLotto,'			 

				FETCH NEXT FROM CurProg INTO @src,@dest
		
			END 

			CLOSE CurProg
			DEALLOCATE CurProg


			FETCH NEXT FROM CurRilanci INTO @idRow,@IdOff 
		
		END 

		CLOSE CurRilanci
		DEALLOCATE CurRilanci
		

		--setto la graduatoria
		declare @Graduatoria int
		set @Graduatoria=0

		declare CurGraduatoria Cursor Static for 
			select idheaderlottoOff from 
				( select 
					max (idrow) as idrow,  idheader,idaziFornitore 
					from document_asta_rilanci 
					where idheader=@idDoc
					group by idheader,idaziFornitore 
				) GR1 inner join document_asta_rilanci AR on GR1.idrow=AR.idrow
				order by AR.idrow desc
		
		open CurGraduatoria

		FETCH NEXT FROM CurGraduatoria INTO @idheaderlottoOff
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			set @Graduatoria = @Graduatoria + 1

			--update  document_microlotti_dettagli set graduatoria=@Graduatoria where id=@idheaderlottoOff
			update  document_microlotti_dettagli set sorteggio=@Graduatoria where id=@idheaderlottoOff

			FETCH NEXT FROM CurGraduatoria INTO @idheaderlottoOff
		END 

		
		CLOSE CurGraduatoria
		DEALLOCATE CurGraduatoria


		--in alternativa posso update join da questa
		--select ROW_NUMBER() over (order by AR.idrow desc) as RowNUm, idheaderlottoOff from 
		--	( select 
		--	max (idrow) as idrow,  idheader,idaziFornitore 
		--	from document_asta_rilanci 
		--	where idheader=73317
		--	group by idheader,idaziFornitore 
		--	) GR1 inner join document_asta_rilanci AR on GR1.idrow=AR.idrow
		--order by AR.idrow desc

	END

end








GO
