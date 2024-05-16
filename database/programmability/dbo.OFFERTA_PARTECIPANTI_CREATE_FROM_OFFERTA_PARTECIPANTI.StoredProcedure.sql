USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_PARTECIPANTI_CREATE_FROM_OFFERTA_PARTECIPANTI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[OFFERTA_PARTECIPANTI_CREATE_FROM_OFFERTA_PARTECIPANTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @IdOfferta as int
	--declare @IdLast as int

	--recupero linkeddoc dal documento corrente
	select @IdOfferta=linkeddoc from ctl_doc where id=@idDoc
	
	--select linkeddoc from ctl_doc where id=58659

	

	--recupero ultimo doc OFFERTA_PARTECIPANTI salvato legato all'offerta
	set @Id=-1
	select @Id=id from ctl_doc where tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='InLavorazione' and linkeddoc=@IdOfferta and jumpcheck='OFFERTA'
	
	--select id from ctl_doc where tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='InLavorazione' and linkeddoc=58619 and jumpcheck='OFFERTA'
	
	if @Id = '-1' 
	begin
		
		--generare nuovo protocollo per il doc offerta_partecipante
		insert into CTL_DOC 
			( IdPfu, TipoDoc, Titolo,Protocollo, Body ,Azienda, 
			ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, JumpCheck , StatoFunzionale, StatoDoc ,Destinatario_Azi ) 
			select @IdUser, TipoDoc, Titolo , '' , Body, Azienda ,  
				ProtocolloRiferimento, Fascicolo, LinkedDoc , Destinatario_User, JumpCheck, 'InLavorazione', 'Saved' ,Azienda
			from ctl_doc where id=@idDoc

		set @Id=@@IDENTITY
		
		--copio su questo tutti i dati di quello corrente
		insert into ctl_doc_value
			(IdHeader, DSE_ID, Row, DZT_Name, Value	)
			select 
				@Id, DSE_ID, Row, DZT_Name, Value	
			from 
				ctl_doc_value
			where idheader=@idDoc

		insert into Document_Offerta_Partecipanti
			(IdHeader, TipoRiferimento, IdAziRiferimento, RagSocRiferimento, IdAzi, RagSoc, CodiceFiscale, IndirizzoLeg, LocalitaLeg, ProvinciaLeg, Ruolo_Impresa,StatoDGUE,AllegatoDGUE,IdDocRicDGUE)
			select 	
				@Id, TipoRiferimento, IdAziRiferimento, RagSocRiferimento, IdAzi, RagSoc, CodiceFiscale, IndirizzoLeg, LocalitaLeg, ProvinciaLeg, Ruolo_Impresa,StatoDGUE,AllegatoDGUE,IdDocRicDGUE
			from 
				Document_Offerta_Partecipanti
			where 
				idheader=@idDoc
				order by IdRow
	end
	
	-- rirorna l'id del documento
	select @Id as id
	
	
	
END

GO
