USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ASTA_GRADUATORIA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD_ASTA_GRADUATORIA]( @idAsta int )
as
begin
	
	--declare @idAsta int
	declare @Flag as int
	declare @idheaderlottoOff as int

	--set @idAsta=73403
	set @Flag=0

	declare CurGraduatoria Cursor Static for 

		select idheaderlottoOff from 
		(
			select 
				top 2 max (idrow) as idrow,  AR.idheader,AR.idaziFornitore 
			from document_asta_rilanci AR
					inner join ctl_doc O on O.tipodoc='OFFERTA_ASTA' and O.statofunzionale='Inviato' and AR.idheader=O.linkeddoc
					--inner join document_microlotti_dettagli DMD on AR.idheaderlottoOff= DMD.id
			where 
				AR.idheader=@idAsta 
				--and isnull(DMD.Graduatoria,0)<>0
			group by Ar.idheader,AR.idaziFornitore 
			order by idrow desc		

		)	GR1 inner join document_asta_rilanci AR on GR1.idrow=AR.idrow
			order by AR.idrow desc					  

	open CurGraduatoria

	FETCH NEXT FROM CurGraduatoria INTO @idheaderlottoOff
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		if @Flag=0
			update  document_microlotti_dettagli set Posizione='Aggiudicatario provvisorio' where id=@idheaderlottoOff 
		else
			update  document_microlotti_dettagli set Posizione='II Classificato' where id=@idheaderlottoOff
		

		--aggirono lo stato dell'asta sulla document_asta ad Aggiudicazione Proposta
		update document_asta set statoAsta='AggiudicazioneProvv' where idheader=@idAsta

		set @Flag=1

		FETCH NEXT FROM CurGraduatoria INTO @idheaderlottoOff
	END 

		
	CLOSE CurGraduatoria
	DEALLOCATE CurGraduatoria
			
	
	--select * from document_microlotti_dettagli where id in (95312,95308)


end



















GO
