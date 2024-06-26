USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ODA_CREATE_FROM_CARRELLO_FORNITORE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ODA_CREATE_FROM_CARRELLO_FORNITORE] ( @idFornitore int, @RagioneSocialeFornitore varchar(500),  @idPfu int, @idDoc int output)
AS
BEGIN

	SET NOCOUNT ON

	declare @newId int = 0
	declare @pfuIdAzi int 
	declare @idProdotto int
	declare @idCatalogo int
	declare @qta int
	declare @idCarrello int
	declare @valoriColonneMicrolotti varchar(100)
	declare @userRole as varchar(100)
	declare @IdPfuInCharge as int
	declare @StatoFunzionale as varchar(100)
	declare @NumPO as int


	--mi recuperi i dati del fornitore
	select @pfuIdAzi = pfuIdAzi 
		from ProfiliUtente where IdPfu = @idPfu
	
	---recupero ruolo dell'utente
	select @userRole= isnull( attvalue,'')
		from profiliutenteattrib with(nolock)
		where dztnome = 'UserRole'  and idpfu = @idPfu	and attvalue='PO'

	--se sono punto ordinante metto il documento ordinativo in approvazione per me stesso			
	if @userRole='PO'
	begin	
		set @IdPfuInCharge=@IdPfu
		set @StatoFunzionale='InLavorazione'
		set @NumPO=1
	end	
	else
	begin
		--sono punto istruttore (PI)
		--valorizzo @IdPfuInCharge solo se il PO è uno solo
		set @IdPfuInCharge = null
		set @NumPO=0

		select @NumPO=count(*) 
			from PROFILIUTENTEATTRIB PA with(nolock)
					inner join profiliutente P with(nolock) on PA.attvalue=P.idpfu
			where dztnome='pfuResponsabileUtente' and PA.idpfu=@IdPfu
					and PA.attvalue in (
									select PA.idpfu from PROFILIUTENTEATTRIB PA with(nolock),profiliutente P with(nolock) where attvalue='po' 
									and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
					and P.pfudeleted=0

		if @NumPO=1
		begin

			select @IdPfuInCharge=attvalue 
				from PROFILIUTENTEATTRIB PA with(nolock)
						inner join profiliutente P with(nolock) on PA.attvalue=P.idpfu
				where 
					dztnome='pfuResponsabileUtente' and PA.idpfu=@IdPfu
					and PA.attvalue in (
									select PA.idpfu from PROFILIUTENTEATTRIB PA,profiliutente P where attvalue='po' 
									and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
					and P.pfudeleted=0
		end

	end

	--inserisco nella ctl_doc		
	insert into CTL_DOC (
				IdPfu, TipoDoc, StatoDoc, Data, DataInvio, Titolo, Body, Azienda, Destinatario_Azi,  
				ProtocolloRiferimento, Fascicolo, LinkedDoc, StatoFunzionale, IdPfuInCharge, jumpcheck)
			values
				(@idPfu, 'ODA', 'Saved', GETDATE(), GETDATE(), left('Ordine di acquisto per ' + @RagioneSocialeFornitore,150), '', @pfuIdAzi,
				@idFornitore, '', '', 0, 'InLavorazione', @idPfu, '')

	set @newId = SCOPE_IDENTITY()
				
	if @newId > 0
	begin

		--inserisco gli articoli del carrello_me in Document_MicroLotti_Dettagli
		DECLARE crsArticoliPerFornitori CURSOR STATIC FOR 
			select b.id, b.Id_Product, b.Id_Catalogo, b.QTDisp 
				from Carrello_ME b
					inner join ctl_doc c with(nolock) on b.id_catalogo = c.id
					inner join aziende a with(nolock) on idazi = azienda	
				where c.Azienda = @idFornitore and b.idPfu = @idPfu
					and b.EsitoRiga = ''

		OPEN crsArticoliPerFornitori
		FETCH NEXT FROM crsArticoliPerFornitori INTO @idCarrello, @idProdotto, @idCatalogo, @qta

		WHILE @@FETCH_STATUS = 0
		BEGIN
			declare @Filter as nvarchar(max)
			set @Filter = 'id=' + cast(@idProdotto as varchar(50)) 	
			set @valoriColonneMicrolotti = cast (@qta as varchar(100)) + ',' + cast (@idProdotto as varchar(100))
						
			exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idCatalogo, @newId, 'IdHeader', 'id', @Filter, 'Quantita,idHeaderLotto', @valoriColonneMicrolotti, 'id'					
												
			--cancello gli articoli  dal carrello
			delete Carrello_ME where id= @idCarrello

			FETCH NEXT FROM crsArticoliPerFornitori INTO @idCarrello, @idProdotto, @idCatalogo, @qta
		END
					
		CLOSE crsArticoliPerFornitori 
		DEALLOCATE crsArticoliPerFornitori 	

		--aggiorno il tipoDocumento Document_MicroLotti_Dettagli
		update Document_MicroLotti_Dettagli set TipoDoc = 'ODA' where IdHeader = @newId
		update Document_MicroLotti_Dettagli set AliquotaIva = 0 where AliquotaIva = Null and IdHeader = @newId

		-- Inserisco il record nella document_protocollo
		insert into Document_dati_protocollo ( idHeader )
			values (@newId)

		--inserisco nella document_OD
		insert into document_ODA			
					(idHeader, NotEditable)
				values (@newId, '')
		
		insert into CTL_ApprovalSteps 
				( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values 
				('ODA' , @newId , 'Compiled' , left('Ordine di acquisto per ' + @RagioneSocialeFornitore,150) , @IdPfu , @userRole , 0  , getdate() )
				
		exec UPDATE_TOTALI_ODA @newId

		--SE ATTIVO LA PCP ALLORA INIZIALIZZO LE STRUTTURE DATI PER LA PCP
		--COMPRESO LA SCHEDA E LA VERSIONE DELLA SCHEDA
		if dbo.attivoPCP () = 1
		begin
			exec INIT_STRUTTURA_PCP_DOCUMENTO @newId, @IdPfu , 'ODA'
		end

	end	
		
	set @idDoc = @newId

END

GO
