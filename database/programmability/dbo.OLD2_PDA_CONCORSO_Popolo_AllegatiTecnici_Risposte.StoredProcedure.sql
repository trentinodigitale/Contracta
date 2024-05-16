USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_CONCORSO_Popolo_AllegatiTecnici_Risposte]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--@Idmsg = id della RISPOSTA_CONCORSO
CREATE PROCEDURE [dbo].[OLD2_PDA_CONCORSO_Popolo_AllegatiTecnici_Risposte] ( @Idmsg int ) as 
begin

	--per ogni risposta concorso devo ricopiare gli allegati della documentazione
	--tecnica sulla riga document_microlotti_dettagli con TIPODOC='RISPOSTA_CONCORSO'
	
	--declare @Idmsg as int

	--DECLARE CurRisp CURSOR STATIC FOR 
				
	--	select idMsg 
	--		from 
	--			Document_PDA_OFFERTE with(nolock)
	--		where 
	--			IdHeader = @idPda --and StatoPDA in ( '99')

	--open CurRisp

	--FETCH NEXT FROM CurRisp INTO @Idmsg

	--insert into CTL_DOC_Value
	--	(IdHeader,DSE_ID,DZT_Name,value)
	--	values
	--	(@Idmsg,'DOCUMENTAZIONE_TECNICA','INIZIO_POPOLO_ALLEGATI',1) 
	--WHILE @@FETCH_STATUS = 0
	--BEGIN
		
		--metto in una #temp (max 20) le righe della doc tecnica del fornitore con il valore inserito
		select 
			top 20 
				'CampoAllegato_' +  cast ( ROW_NUMBER() OVER(ORDER BY idrow ASC) as varchar) as Attributo , Allegato 
				into #tempAttach
			from 
				ctl_doc_allegati with (nolock) where idheadeR=@Idmsg and dse_id='DOCUMENTAZIONE_RICHIESTA_TECNICA'
			order by idrow

		--giro la tabella #temp con un PIVOT		
		select * into #temp2 from 
			(
				select * from #tempAttach
			) p
			pivot
			(
			   min(allegato)
			   for p.aTTRIBUTO in ([CampoAllegato_1],[CampoAllegato_2],[CampoAllegato_3],[CampoAllegato_4],[CampoAllegato_5],[CampoAllegato_6]
									,[CampoAllegato_7],[CampoAllegato_8],[CampoAllegato_9],[CampoAllegato_10],[CampoAllegato_11],[CampoAllegato_12]
									,[CampoAllegato_13],[CampoAllegato_14],[CampoAllegato_15],[CampoAllegato_16],[CampoAllegato_17],[CampoAllegato_18]
									,[CampoAllegato_19],[CampoAllegato_20]
									)
				 ) as PIV



		--aggiorno la riga della risposta per tutti i campi allegati
		update 
			T
			set 
				T.CampoAllegato_1 = S.CampoAllegato_1, T.CampoAllegato_2 = S.CampoAllegato_2, 
				T.CampoAllegato_3 = S.CampoAllegato_3, T.CampoAllegato_4 = S.CampoAllegato_4, 
				T.CampoAllegato_5 = S.CampoAllegato_5, T.CampoAllegato_6 = S.CampoAllegato_6, 
				T.CampoAllegato_7 = S.CampoAllegato_7, T.CampoAllegato_8 = S.CampoAllegato_8, 
				T.CampoAllegato_9 = S.CampoAllegato_9, T.CampoAllegato_10 = S.CampoAllegato_10, 
				T.CampoAllegato_11 = S.CampoAllegato_11, T.CampoAllegato_12 = S.CampoAllegato_12, 
				T.CampoAllegato_13 = S.CampoAllegato_13, T.CampoAllegato_14 = S.CampoAllegato_14, 
				T.CampoAllegato_15 = S.CampoAllegato_15, T.CampoAllegato_16 = S.CampoAllegato_16, 
				T.CampoAllegato_17 = S.CampoAllegato_17, T.CampoAllegato_18 = S.CampoAllegato_18, 
				T.CampoAllegato_19 = S.CampoAllegato_19, T.CampoAllegato_20 = S.CampoAllegato_20
			from
				document_microlotti_dettagli T
					cross join #temp2 S 
			where 
				T.idheader= @Idmsg and T.tipodoc='RISPOSTA_CONCORSO'

		drop table #tempAttach
		drop table #temp2

		--insert into CTL_DOC_Value
			--(IdHeader,DSE_ID,DZT_Name,value)
			--values
			--(@Idmsg,'DOCUMENTAZIONE_TECNICA','FINE_POPOLO_ALLEGATI',1)


		--FETCH NEXT FROM CurRisp INTO @Idmsg
	--END 

	--CLOSE CurRisp
	--DEALLOCATE CurRisp

end

GO
