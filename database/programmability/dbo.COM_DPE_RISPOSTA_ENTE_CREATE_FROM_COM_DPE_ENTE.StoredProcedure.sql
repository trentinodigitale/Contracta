USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COM_DPE_RISPOSTA_ENTE_CREATE_FROM_COM_DPE_ENTE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[COM_DPE_RISPOSTA_ENTE_CREATE_FROM_COM_DPE_ENTE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @idCom as INT

	

	--CON LE MODIFICHE FATTE IN ATT 293135 @iddoc è Idcomfor quando arriviamo qua
	Select @idCom=IdCom,@azienda=IdAzi from Document_Com_DPE_Enti where IdComEnte=@idDoc

	set @Errore = ''

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idCom and deleted = 0 and TipoDoc in ( 'COM_DPE_RISPOSTA_ENTE' ) and StatoFunzionale='InLavorazione' and idpfu=@IdUser

		if @id is null
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, LinkedDoc,titolo,ProtocolloRiferimento,DataScadenza,JumpCheck,Destinatario_User,Azienda
					 )
					select 
							@IdUser as idpfu , 
							'COM_DPE_RISPOSTA_ENTE' as TipoDoc ,  
							@idCom as LinkedDoc,
							Name as Titolo,
							Protocollo as ProtocolloRiferimento,
							DataScadenza,
							'ENTI' as JumpCheck,
							[Owner] ,
							@azienda
									
					 from dbo.Document_Com_DPE
						where IdCom= @idCom

				set @id = SCOPE_IDENTITY()
				
				
		end
	end
		
	



	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END








GO
