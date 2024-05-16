USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_INIT_FROM_AQ]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OFFERTA_INIT_FROM_AQ] ( @idBandoAQ int , @idOfferta int )
as
begin


	declare @idOFFCOPY INT
	set @idOFFCOPY=0

	select distinct  @idOFFCOPY=PDA_OFF.IdMsg
		from ctl_doc  offerta with(NOLOCK)  --OFFERTA
			inner join Document_MicroLotti_Dettagli LOTTI_O with(NOLOCK) on offerta.id=LOTTI_O.IdHeader and LOTTI_O.TipoDoc='OFFERTA'  --LOTTI OFFERTA
			inner join ctl_doc  RILANCIO with(NOLOCK) on offerta.LinkedDoc=RILANCIO.id  --RILANCIO
			inner join ctl_doc  AQ with(NOLOCK) on RILANCIO.LinkedDoc=AQ.id  --AQ
			inner join ctl_doc  PDA_AQ with(NOLOCK) on PDA_AQ.LinkedDoc=AQ.id and PDA_AQ.TipoDoc='PDA_MICROLOTTI'  --PDA AQ
			inner join Document_PDA_OFFERTE  PDA_OFF with(NOLOCK) on PDA_OFF.IdHeader=PDA_AQ.id and PDA_OFF.idAziPartecipante=offerta.Azienda --OFFERTE AQ
			inner join Document_MicroLotti_Dettagli LOTTI_P  with(NOLOCK) on LOTTI_P.IdHeader=PDA_OFF.IdMsg and LOTTI_P.TipoDoc='OFFERTA' and LOTTI_P.NumeroLotto=LOTTI_O.NumeroLotto  --LOTTI OFFERTE
			inner join Document_Offerta_Partecipanti OFF_PART with(NOLOCK) on OFF_PART.IdHeader=LOTTI_P.IdHeader and OFF_PART.Ruolo_Impresa='Mandataria' and OFF_PART.IdAzi=offerta.Azienda --RTI
		where offerta.id=@idOfferta

	if @idOFFCOPY > 0
	BEGIN

		insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @idOfferta,DSE_ID,Row,DZT_Name,Value from CTL_DOC_Value where IdHeader=@idOFFCOPY and DSE_ID in ('AUSILIARIE','ESECUTRICI','SUBAPPALTO','RTI','TESTATA_RTI')

		insert into Document_Offerta_Partecipanti ( IdHeader, TipoRiferimento, IdAziRiferimento, RagSocRiferimento, IdAzi, RagSoc, CodiceFiscale, IndirizzoLeg, LocalitaLeg, ProvinciaLeg, Ruolo_Impresa)
			select @idOfferta, TipoRiferimento, IdAziRiferimento, RagSocRiferimento, IdAzi, RagSoc, CodiceFiscale, IndirizzoLeg, LocalitaLeg, ProvinciaLeg, Ruolo_Impresa
			from Document_Offerta_Partecipanti where IdHeader=@idOFFCOPY
			order by IdRow

		
	END


	-- spostato fuori dalla condizione per bloccare sempre la composizione delle partecipanti quando l'offerta è su un rilancio competittivo
	insert into CTL_DOC_Value ( IdHeader,DSE_ID,Row,DZT_Name,Value)
		select @idOfferta,'PARTECIPANTI',0,'PARTECIPANTI_BLOCCATI','YES'
		


end


GO
