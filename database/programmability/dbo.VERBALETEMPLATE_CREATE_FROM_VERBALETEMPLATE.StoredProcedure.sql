USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERBALETEMPLATE_CREATE_FROM_VERBALETEMPLATE]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[VERBALETEMPLATE_CREATE_FROM_VERBALETEMPLATE] 
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int

	set @Id = ''
	set @Errore=''
	
	--controllo che il doc sorgente è pubblicato
	if exists(select id from ctl_doc where id=@IdDoc and StatoFunzionale<>'Pubblicato')
	begin
		set @Errore='modifica consentito solo su un template pubblicato'
	end

	if @Errore=''
	begin
		
		set @id=0

		--Se presente un documento di modifica template in lavorazione sullo stesso template lo riapro
		if exists (select * from ctl_doc where tipodoc='VERBALETEMPLATE' and prevdoc=@IdDoc and statofunzionale='InLavorazione' and deleted=0 )
		begin
			select @id = id from ctl_doc where tipodoc='VERBALETEMPLATE' and prevdoc=@IdDoc and statofunzionale='InLavorazione' and deleted=0 
		end
		else
		begin
		
			if @id=0
			begin
				
				--recupero azienda utente collegato
				select @IdAzi=pfuidazi from profiliutente where idpfu=@idUser

				--inserisco nella ctl_doc nuovo doc		
				insert into CTL_DOC (
						 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
							ProtocolloRiferimento,  Fascicolo,PrevDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
				
						select @idUser,  TipoDoc, 'Saved' , 'Modifica Template ' + Titolo , Body , @IdAzi ,Destinatario_Azi
							,ProtocolloRiferimento  , Fascicolo , @IdDoc  ,'InLavorazione', @idUser , ''
						from CTL_DOC 
							where Id = @IdDoc

				set @Id = @@identity		
			
				
				--inserisco nella Document_VerbaleGara nuovo doc
				insert into Document_VerbaleGara
				( IdHeader, ProceduraGara, CriterioAggiudicazioneGara, Testata, PiePagina, Testata2, Multiplo, IdTipoVerbale, TipoVerbale, TipoSorgente, CriterioFormulazioneOfferte)
				select 
					@Id, ProceduraGara, CriterioAggiudicazioneGara, Testata, PiePagina, Testata2, Multiplo, IdTipoVerbale, TipoVerbale, TipoSorgente, CriterioFormulazioneOfferte
					from Document_VerbaleGara
						where idheader=@IdDoc

				
				--copio i dettagli nella Document_VerbaleGara_Dettagli
				insert into Document_VerbaleGara_Dettagli
				select
					 @Id, Pos, SelRow, TitoloSezione, DescrizioneEstesa, Edit, CanEdit, Expression
					 from Document_VerbaleGara_Dettagli
						where idheader=@IdDoc 
			end

		end
	end

	
	if @Errore=''
		-- rirorna id odc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	

END


GO
