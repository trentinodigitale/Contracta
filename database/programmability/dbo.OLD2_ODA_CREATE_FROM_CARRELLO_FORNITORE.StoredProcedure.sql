USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ODA_CREATE_FROM_CARRELLO_FORNITORE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD2_ODA_CREATE_FROM_CARRELLO_FORNITORE] 
	( @idFornitore int, @RagioneSocialeFornitore varchar(500),  @idPfu int, @idDoc int output)
AS
BEGIN

	SET NOCOUNT ON	
	declare @newId int = 0;
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
	--declare @TotaleIva int
	--declare @TotaleValoreAccessorio int
	--declare @TotaleIvaEroso int
	--declare @TotaleEroso int

	--mi recuperi i dati del fornitore
	select @pfuIdAzi = pfuIdAzi 
		from ProfiliUtente where IdPfu = @idPfu
	
	---recupero ruolo dell'utente
	select @userRole= isnull( attvalue,'')
		from 
			profiliutenteattrib 
		where 
			dztnome = 'UserRole'  
			and idpfu = @idPfu
			and attvalue='PO'

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
			from 
				PROFILIUTENTEATTRIB PA inner join profiliutente P on PA.attvalue=P.idpfu
			where 
				dztnome='pfuResponsabileUtente' and PA.idpfu=@IdPfu
				and PA.attvalue in (
									select PA.idpfu from PROFILIUTENTEATTRIB PA,profiliutente P where attvalue='po' 
									and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
				and P.pfudeleted=0

		if @NumPO=1
		begin

			select @IdPfuInCharge=attvalue 
				from 
					PROFILIUTENTEATTRIB PA inner join profiliutente P on PA.attvalue=P.idpfu
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

	set @newId = @@identity		
	
	--recuperi i totali dei prodotti per il fornitore
	--select 		
	--	@TotaleIva=isnull(sum(QTDisp*Prezzounitario + isnull(ValoreAccessorioTecnico, 0) + ( ((QTDisp*Prezzounitario) + isnull(ValoreAccessorioTecnico, 0)) * isnull(iva, 0) /100)),0), 
	--	@TotaleIvaEroso=isnull(sum(QTDisp*Prezzounitario + isnull(ValoreAccessorioTecnico, 0) + ( ((QTDisp*Prezzounitario) + isnull(ValoreAccessorioTecnico, 0)) * isnull(iva, 0) /100)),0),
	--	@TotaleEroso=isnull(sum(QTDisp*Prezzounitario + isnull(ValoreAccessorioTecnico, 0)),0),
	--	@TotaleValoreAccessorio=isnull(sum(ValoreAccessorioTecnico),0)
	--	from carrello_me b 
	--		inner join ctl_doc c with(nolock) on b.id_catalogo = c.id
	--		inner join aziende a with(nolock) on idazi = azienda	
	--	where c.Azienda = @idFornitore and b.idPfu = @idPfu 
				
	if @newId > 0
		begin
		--inserisco gli articoli del carrello_me in Document_MicroLotti_Dettagli
			DECLARE crsArticoliPerFornitori CURSOR STATIC FOR 
				select b.id, b.Id_Product, b.Id_Catalogo, b.QTDisp 
					from Carrello_ME b
						inner join ctl_doc c with(nolock) on b.id_catalogo = c.id
						inner join aziende a with(nolock) on idazi = azienda	
						where c.Azienda = @idFornitore and b.idPfu = @idPfu

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
		end	
		
	set @idDoc = @newId

END

GO
