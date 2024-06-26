USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANNULLA_ODA_CREATE_FROM_ODA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[ANNULLA_ODA_CREATE_FROM_ODA] 
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdConvenzione as int
	declare @IdOrdinativo as int	
	declare @IdAzi as int
	declare @userRole as varchar(59)

	set @Id = ''
	set @Errore=''
	set @Id=0
	set @userRole = ''

	---recupero ruolo dell'utente che sta facendo la richiesta
	select @userRole = isnull(d.IdPfu + o.UserRUP, '') 
		from CTL_DOC as d with(Nolock)
			inner join Document_ODA as o with(Nolock) on o.idHeader = d.Id
		where d.id = @IdDoc
	
	if @userRole <> ''
		begin 
			--Se e' presente una richiesta salvata riapro quella
			select @id=id from ctl_doc where tipodoc='ANNULLA_ODA' and linkeddoc=@IdDoc and deleted=0
		
			if @id=0
				begin		
					--inserisco nella ctl_doc		
					insert into CTL_DOC (
						IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
						ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
				
					select @idUser,  'ANNULLA_ODA', 'Saved' , left( 'Annulla ordine ' + Titolo , 150 ) , note , Azienda , Destinatario_Azi
						,Protocollo  , Fascicolo , @IdDoc  ,'InLavorazione', @idUser , ''
					from CTL_DOC 
						where Id = @IdDoc

					set @Id = @@identity		
				end

		end
	else	
		begin 
			set @Errore = 'Attenzione solo il PO, oppure il PI con approvazione del PO, possono annullare l''ordine di acquisto'
		end
		
	if @Errore=''
		-- rirorna id oda creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	

END


GO
