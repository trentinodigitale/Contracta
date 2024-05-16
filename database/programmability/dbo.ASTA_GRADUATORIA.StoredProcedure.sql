USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ASTA_GRADUATORIA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE proc [dbo].[ASTA_GRADUATORIA]( @idAsta int )
as
begin
	
	--declare @idAsta int
	--declare @Flag as int
	declare @idheaderlottoOff as int
	declare @rank as int
	
	set @rank=0

	--set @idAsta=73403
	--set @Flag=1

	declare CurGraduatoria Cursor Static for 

		--select idheaderlottoOff from 
		--(
			select 
				--top 2 max (idrow) as idrow,  AR.idheader,AR.idaziFornitore 
				--idrow, AR.idheader,AR.idaziFornitore 
				idheaderlottoOff
			from document_asta_rilanci AR
					inner join ctl_doc O on O.tipodoc='OFFERTA_ASTA' and O.statofunzionale='Inviato' and O.linkeddoc=AR.idheader and O.azienda=AR.idazifornitore
					inner join document_microlotti_dettagli DMD on  DMD.id = AR.idheaderlottoOff and isnull(DMD.sorteggio,0) > 0
			where 
				AR.idheader=@idAsta 
			--group by Ar.idheader,AR.idaziFornitore 
			order by sorteggio asc		

		--)	GR1 inner join document_asta_rilanci AR on GR1.idrow=AR.idrow
		--	order by AR.idrow desc					  

	open CurGraduatoria

	FETCH NEXT FROM CurGraduatoria INTO @idheaderlottoOff
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @rank = @rank + 1	
		
		--ricalcolo la graduatoria
		update document_microlotti_dettagli set Graduatoria=@rank where id=@idheaderlottoOff 

		--setto 
		if @rank=1
			update  document_microlotti_dettagli set Posizione='Aggiudicatario provvisorio' where id=@idheaderlottoOff 

		if @rank=2
			update  document_microlotti_dettagli set Posizione='II Classificato' where id=@idheaderlottoOff
		
		

		FETCH NEXT FROM CurGraduatoria INTO @idheaderlottoOff
	END 

	CLOSE CurGraduatoria
	DEALLOCATE CurGraduatoria
	
	--aggirono lo stato dell'asta sulla document_asta ad Aggiudicazione Proposta se ho settato la graduatoria
	if @rank<>0
		update document_asta set statoAsta='AggiudicazioneProvv' where idheader=@idAsta		
	
	--select * from document_microlotti_dettagli where id in (95312,95308)


end


















GO
