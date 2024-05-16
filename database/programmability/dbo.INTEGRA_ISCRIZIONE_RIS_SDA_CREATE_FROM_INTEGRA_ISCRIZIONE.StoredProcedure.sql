USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INTEGRA_ISCRIZIONE_RIS_SDA_CREATE_FROM_INTEGRA_ISCRIZIONE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INTEGRA_ISCRIZIONE_RIS_SDA_CREATE_FROM_INTEGRA_ISCRIZIONE]
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

	set @Errore = ''

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'INTEGRA_ISCRIZIONE_RIS_SDA' ) 

		if @id is null
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, LinkedDoc,Azienda,Destinatario_Azi,ProtocolloRiferimento,fascicolo,StrutturaAziendale,Body,Note,Destinatario_User
					 )
					select 
							@IdUser as idpfu , 
							'INTEGRA_ISCRIZIONE_RIS_SDA' as TipoDoc ,  
							@idDoc as LinkedDoc,
							d.Destinatario_Azi as Azienda,
							d.Azienda as Destinatario_Azi,
							d.Protocollo as ProtocolloRiferimento,
							d.Fascicolo,
							d.StrutturaAziendale,
							d.Body,
							d.Note,
							d.IdPfu AS Destinatario_User
									
					 from CTL_DOC  d
						inner join CTL_DOC i on d.LinkedDoc = i.id
						where d.Id= @idDoc

				set @id = @@identity

				Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
					select @id,'RISPOSTA','Destinatario_Azi',Azienda
						from CTL_DOC
					where  Id= @idDoc
				
				
				
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
