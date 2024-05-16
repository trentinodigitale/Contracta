USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_INTEGRA_ISCRIZIONE_SDA_CREATE_FROM_ISTANZA_SDA_FARMACI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROCEDURE [dbo].[OLD2_INTEGRA_ISCRIZIONE_SDA_CREATE_FROM_ISTANZA_SDA_FARMACI] 
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

	-- controllo lo stato dell'istanza
	if exists( select * from CTL_DOC where id = @idDoc and StatoFunzionale not in ( 'InValutazione' ,  'Integrato' ) ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita per lo stato del documento' 
	end

	if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'SCARTO_ISCRIZIONE_SDA' , 'CONFERMA_ISCRIZIONE_SDA' ) and statoFunzionale in ( 'InProtocollazione', 'Valutato') )
		set @Errore = 'Operazione non consentita, esiste un altro documento che ha valutato l''istanza' 


	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'SCARTO_ISCRIZIONE_SDA', 'CONFERMA_ISCRIZIONE_SDA' ) and statoFunzionale in ( 'InLavorazione' ) )
		set @Errore = 'Operazione non consentita, esiste altro documento in lavorazione di tipo diverso. E'' necessario cancellarlo' 

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'INTEGRA_ISCRIZIONE_SDA'  ) and StatoFunzionale not in ( 'Integrato' , 'Annullato' , 'Scaduta' ,'Rifiutato' )

		if @id is null
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, Azienda, StrutturaAziendale, 
					ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
					Destinatario_Azi , Note )
					select 
						@IdUser as idpfu , 'INTEGRA_ISCRIZIONE_SDA'  as TipoDoc ,  
						'Richiesta integrazione' as Titolo,  replace( OggettoIntegrativa , '[TITOLO]' , b.Titolo ) as  Body, 
						pfuIdAzi as  Azienda, d.StrutturaAziendale, 
						--d.ProtocolloRiferimento, 
						--nel campo protocolloriferimento ci mettiamo il protocollo dell'istanza
						d.protocollo,
						d.Fascicolo, d.id as LinkedDoc, 
						d.IdPfu as Destinatario_User, 
						d.Azienda as Destinatario_Azi , TestoIntegrativa
		
						from CTL_DOC d
							inner join profiliutente p on Destinatario_User = p.idpfu
							inner join CTL_DOC b on b.id = d.LinkedDoc
							left outer join Document_Parametri_Abilitazioni t on t.TipoDoc = 'SDA' and t.deleted = 0 
						where d.id = @idDoc

				set @id = @@identity

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
