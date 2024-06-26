USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CONFERMA_ISCRIZIONE_SDA_CREATE_FROM_ISTANZA_SDA_FARMACI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  PROCEDURE [dbo].[OLD2_CONFERMA_ISCRIZIONE_SDA_CREATE_FROM_ISTANZA_SDA_FARMACI] 
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
	declare @CategorieIStanza as nvarchar(max)

	set @Errore = ''

	-- controllo lo stato dell'istanza
	if exists( select * from CTL_DOC where id = @idDoc and StatoFunzionale not in ( 'InValutazione' ,  'Integrato' ) ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita per lo stato del documento' 
	end

	if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'INTEGRA_ISCRIZIONE_SDA' , 'INTEGRA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE_SDA' ) and statoFunzionale in ( 'InvioInCorso','InProtocollazione', 'Valutato') )
		set @Errore = 'Operazione non consentita, esiste un altro documento che ha valutato l''istanza' 

	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'INTEGRA_ISCRIZIONE_SDA' , 'SCARTO_ISCRIZIONE_SDA' ) and statoFunzionale in ( 'InLavorazione' ) )
		set @Errore = 'Operazione non consentita, esiste altro documento in lavorazione di tipo diverso. E'' necessario cancellarlo' 

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONFERMA_ISCRIZIONE_SDA' ) and statoFunzionale <> 'Rifiutato'

		if @id is null
		begin
			-- altrimenti lo creo
			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, 
				Titolo, Body, Azienda, StrutturaAziendale, 
				ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
				Destinatario_Azi , Note,Versione)
				select 
					@IdUser as idpfu , 'CONFERMA_ISCRIZIONE_SDA' as TipoDoc ,  
					'Conferma Iscrizione' as Titolo, replace( OggettoAmmessa , '[TITOLO]' , b.Titolo ) as Body, 
					pfuIdAzi as  Azienda, d.StrutturaAziendale, 
					d.ProtocolloRiferimento, d.Fascicolo, d.id as LinkedDoc, 
					d.IdPfu as Destinatario_User, 
					d.Azienda as Destinatario_Azi 
					, t.TestoAmmessa,case when d.TipoDoc in ( 'ISTANZA_SDA_2','ISTANZA_SDA_3','ISTANZA_SDA_IC') then 2 else NULL end
					from CTL_DOC d
						inner join profiliutente p on Destinatario_User = p.idpfu
						inner join CTL_DOC b on b.id = d.LinkedDoc
						left outer join Document_Parametri_Abilitazioni t on t.TipoDoc = 'SDA' and t.deleted = 0 
					where d.id = @idDoc

			set @id = @@identity

			-- SE è STATA POPOLATA LA GRIGLIA CON CLI ALLEGATI
			if exists (	Select 'CATEGORIE' from CTL_DOC_VALUE where idHeader=@idDoc and DSE_ID='GRIGLIA_CATEGORIE' )
			begin 

				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					Select @id , 'CATEGORIE' , Row , DZT_Name , value
						from CTL_DOC_VALUE
						where idHeader=@idDoc and DSE_ID='GRIGLIA_CATEGORIE' 
				    
				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					Select @id , 'CATEGORIE' , Row , 'Seleziona' , 'includi'
						from CTL_DOC_VALUE
						where idHeader=@idDoc and DSE_ID='GRIGLIA_CATEGORIE' 
				 
				--conserviamo le categorie dell'istanza in 2 campi
				set @CategorieIStanza='###'

				select @CategorieIStanza = @CategorieIStanza + value + '###' from 
					ctl_doc_value where idheader=@idDoc and dse_id='GRIGLIA_CATEGORIE' and  dzt_name='Categoria_Merceologica'

	 			  
				   
			end
			else -- ALTRIMENTI PRELEVIAMO SE CI SONO LE CATEGORIE DAL GERARCHICO
			begin 

				declare @Value nvarchar(max)
				select @Value = Value from CTL_DOC_Value v where  idheader  = @idDoc and dzt_name = 'Categorie_Merceologiche' and DSE_ID = 'DISPLAY_CATEGORIE'
				
				set @CategorieIStanza = @Value

				if isnull(@Value , '' )  <> ''
				begin
				
					Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
						Select @id , 'CATEGORIE' , ( ROW_NUMBER() OVER(ORDER BY ITEMS DESC)) -1  AS Row   , 'Categoria_Merceologica' , ITEMS 
							from dbo.Split( @Value , '###' ) 
					  
					
					Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
						Select @id , 'CATEGORIE' , ( ROW_NUMBER() OVER(ORDER BY ITEMS DESC)) -1  AS Row   , 'Seleziona' , 'includi' 
							from dbo.Split( @Value , '###' )     
				end

				

			end				

			--conserviamo le categorie dell'istanza
			insert into ctl_doc_value  
				( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
				values 
				(@id,'CLASSI', 0, 'Categorie_Merceologiche',@CategorieIStanza )
			
				--conserviamo le categorie dell'istanza
			insert into ctl_doc_value  
				( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
				values 
				(@id,'CLASSI', 0, 'Categorie_Merceologiche_Istanza',@CategorieIStanza )
			

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
