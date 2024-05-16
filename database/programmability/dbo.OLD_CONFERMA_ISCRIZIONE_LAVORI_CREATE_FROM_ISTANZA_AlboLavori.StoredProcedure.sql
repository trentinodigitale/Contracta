USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONFERMA_ISCRIZIONE_LAVORI_CREATE_FROM_ISTANZA_AlboLavori]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_CONFERMA_ISCRIZIONE_LAVORI_CREATE_FROM_ISTANZA_AlboLavori] 
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
	if exists( select id from CTL_DOC with(nolock) where id = @idDoc and StatoFunzionale not in ( 'InValutazione' ,  'Integrato' ) ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita per lo stato del documento' 
	end

	if @Errore = '' AND exists( select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'INTEGRA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE_LAVORI' ) and statoFunzionale in ( 'InvioInCorso','InProtocollazione' , 'Valutato') )
		set @Errore = 'Operazione non consentita, esiste un altro documento che ha valutato l''istanza' 


	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	if @Errore = '' AND exists( select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'INTEGRA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE_LAVORI' ) and statoFunzionale in ( 'InLavorazione') )
		set @Errore = 'Operazione non consentita, esiste altro documento in lavorazione di tipo diverso. E'' necessario cancellarlo' 

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC with(nolock)  where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONFERMA_ISCRIZIONE_LAVORI' ) and statoFunzionale <> 'Rifiutato'

		if @id is null
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, Azienda, StrutturaAziendale, 
					ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
					Destinatario_Azi,JumpCheck , Note )
					select 
							@IdUser as idpfu , 'CONFERMA_ISCRIZIONE_LAVORI' as TipoDoc ,  
							'Conferma Iscrizione' as Titolo, replace( OggettoAmmessa , '[TITOLO]' , b.Titolo ) as Body, 
							pfuIdAzi as  Azienda, d.StrutturaAziendale, 
							--d.ProtocolloRiferimento,
							b.Protocollo,
							d.Fascicolo, d.id as LinkedDoc, 
							d.IdPfu as Destinatario_User, 
							d.Azienda as Destinatario_Azi, d.tipodoc , t.TestoAmmessa
		
						from CTL_DOC d with(nolock)
							inner join profiliutente p with(nolock) on Destinatario_User = p.idpfu
							inner join CTL_DOC b with(nolock) on b.id = d.LinkedDoc
							left outer join Document_Parametri_Abilitazioni t with(nolock) on t.TipoDoc = 'ALBO_LAVORI' and t.deleted = 0 
						where d.id = @idDoc

				set @id = SCOPE_IDENTITY()
				
				--PER LA VERSIONE DI PUGLIA SUL DOCUMENTO ISTANZA USA GerachicoSOA ( ereditato dal vecchio ambiente )				
				declare @TipoDoc as varchar(500)

				select @TipoDoc=TipoDoc from ctl_doc with(nolock) where id=@idDoc

				if @TipoDoc in ('ISTANZA_AlboLavori_RP','ISTANZA_AlboLavori_RL')
				begin
					Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
						Select @id , 'CLASSI' , 0 , 'ClassificazioneSOA' , value
							from CTL_DOC_VALUE with(nolock)
						where idHeader=@idDoc and DSE_ID='DISPLAY_ABILITAZIONI' and DZT_NAME='GerarchicoSOA'
				end
				else
				begin	
					Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
						Select @id , 'CLASSI' , 0 , 'ClassificazioneSOA' , value
							from CTL_DOC_VALUE with(nolock)
						where idHeader=@idDoc and DSE_ID='DISPLAY_CLASSI' and DZT_NAME='ClassificazioneSOA'
				end			


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
