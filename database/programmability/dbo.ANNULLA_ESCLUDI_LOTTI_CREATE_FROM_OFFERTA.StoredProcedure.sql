USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANNULLA_ESCLUDI_LOTTI_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[ANNULLA_ESCLUDI_LOTTI_CREATE_FROM_OFFERTA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @IdMittente as int
	declare @IdAziMittente as int
	declare @ProtocolloOfferta as varchar(50)
	declare @Oggetto as nvarchar(4000)
	declare @ProtocolloBando as varchar(50)
	declare @Fascicolo as  varchar(50)
	declare @IdDestinatario as int
	declare @TipoDoc as  varchar(50)
	declare @IdPDA as int
	declare @Errore as nvarchar(2000)
	declare @IdLast as int
	declare @IdAziPartecipante as int
	--select * from document_pda_offerte where idheader=58951	

	set @Errore=''

	--recupero id della pda
	select 
		 @IdPDA=PO.Idheader, @TipoDoc=O.TipoDoc
	from 
		document_pda_offerte PO  
			inner join ctl_doc PDA on PO.Idheader=PDA.id and PDA.TipoDoc='PDA_MICROLOTTI' and PDA.deleted=0
				left outer join ctl_doc O on PO.idmsg=O.id and PO.TipoDoc=O.TipoDoc and O.deleted=0
	where 
		PO.idmsg=@idDoc

	
	--controllo esistenza documenti ESCLUDI_LOTTO CONFERMATO
	if not exists (select id from ctl_doc where tipodoc='ESCLUDI_LOTTI' and IdDoc=@IdPDA and linkeddoc=@idDoc and StatoFunzionale = 'Confermato' and deleted=0 )
	BEGIN	
		set @Errore='Operazione non consentita:non esiste un documento escludi lotti confermato'
	END

	IF  @Errore=''
	BEGIN

		--recupero ultimo doc ANNULLA_ESCLUDI_LOTTI inlavorazione legato all'offerta e se esiste lo riapro
		set @Id=-1
		select @Id=id from ctl_doc where tipodoc='ANNULLA_ESCLUDI_LOTTI' and IdDoc=@IdPDA and linkeddoc=@idDoc and StatoFunzionale ='InLavorazione' and deleted=0 
	
		if @Id = '-1' 
		begin
		
			--prima di crearlo controllo che stato riga dell'offerta non sia ammessa/esclusa
			--set @Errore='Operazione non consentita:necessario annullare esito ammessa/esclusa'
			--if not exists (select * from document_pda_offerte where idmsg=@idDoc and Idheader=@IdPDA and statopda in ('1','2','22'))
			--begin
				
				set @Errore=''

				--recupero info offerta da settare sul doc offerta_partecipanti
				select @ProtocolloOfferta=Protocollo, @Fascicolo=Fascicolo , @IdAziPartecipante=azienda
					from ctl_doc where id=@IdDoc

				--recupero azienda utente collegato
				select @IdAziMittente=pfuidazi from profiliutente where idpfu=@IdUser
		
				insert into CTL_DOC 
					( IdPfu, TipoDoc, Body ,Azienda, IdDoc,
					ProtocolloRiferimento, Fascicolo, LinkedDoc,  StatoFunzionale, StatoDoc , Destinatario_Azi) 
				values 
					( @IdUser, 'ANNULLA_ESCLUDI_LOTTI', '', @IdAziMittente , @IdPDA,
					@ProtocolloOfferta, @Fascicolo, @IdDoc , 'InLavorazione', 'Saved', @IdAziPartecipante )   

				set @Id=SCOPE_IDENTITY()

			

			--end

		end

	END

	if @Errore=''

		-- rirorna l'id del documento
		select @Id as id
	
	else

	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end
	
	
END






GO
