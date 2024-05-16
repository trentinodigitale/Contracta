USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CONFERMA_ISCRIZIONE_CREATE_FROM_ISTANZA_AlboOperaEco]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE  PROCEDURE [dbo].[OLD2_CONFERMA_ISCRIZIONE_CREATE_FROM_ISTANZA_AlboOperaEco] 
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
	declare @JumpCheck as varchar(200)
	declare @TipoDocParametri as varchar(100)

	set @Errore = ''

	-- controllo lo stato dell'istanza
	if exists( select * from CTL_DOC with(nolock) where id = @idDoc and StatoFunzionale not in ( 'InValutazione' ,  'Integrato' ) ) 
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita per lo stato del documento' 
	end


	if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'INTEGRA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE' ) and statoFunzionale in ( 'InvioInCorso','InProtocollazione', 'Valutato') )
		set @Errore = 'Operazione non consentita, esiste un altro documento che ha valutato l''istanza' 


	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	if @Errore = '' AND exists( select * from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'INTEGRA_ISCRIZIONE' , 'SCARTO_ISCRIZIONE' ) and statoFunzionale in ( 'InLavorazione'  ) )
		set @Errore = 'Operazione non consentita, esiste altro documento in lavorazione di tipo diverso. E'' necessario cancellarlo' 

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select  @id=id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CONFERMA_ISCRIZIONE' ) and statoFunzionale <> 'Rifiutato'

		if @id is null
		begin
			
			--recupeor jumpcheck sul bando
			select @JumpCheck=isnull(JumpCheck,'') from ctl_doc  with(nolock) where id=(select LinkedDoc from ctl_doc where id=@idDoc)

			set @TipoDocParametri='ALBO'

			if @JumpCheck='BANDO_ALBO_LAVORI'
				set @TipoDocParametri='ALBO_LAVORI'

			if @JumpCheck='BANDO_ALBO_FORNITORI'
				set @TipoDocParametri='ALBO_FORN'

			if @JumpCheck='BANDO_ALBO_PROFESSIONISTI'
				set @TipoDocParametri='ALBO_PROF'


			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, Azienda, StrutturaAziendale, 
					ProtocolloRiferimento, Fascicolo, LinkedDoc, Destinatario_User, 
					Destinatario_Azi,JumpCheck , Note )
					select 
							@IdUser as idpfu , 'CONFERMA_ISCRIZIONE' as TipoDoc ,  
							'Conferma Iscrizione' as Titolo, replace( OggettoAmmessa , '[TITOLO]' , b.Titolo ) as Body, 
							pfuIdAzi as  Azienda, d.StrutturaAziendale, 
							--d.ProtocolloRiferimento,
							b.Protocollo,
							 d.Fascicolo, d.id as LinkedDoc, 
							d.IdPfu as Destinatario_User, 
							d.Azienda as Destinatario_Azi, d.tipodoc , t.TestoAmmessa
		
						from CTL_DOC d with(nolock)
							inner join profiliutente p with(nolock) on Destinatario_User = p.idpfu
							inner join CTL_DOC b  with(nolock) on b.id = d.LinkedDoc
							left outer join Document_Parametri_Abilitazioni t with(nolock) on t.TipoDoc = @TipoDocParametri and t.deleted = 0
						where d.id = @idDoc

				set @id = SCOPE_IDENTITY()

				--quest'operazione serve a rimuovere eventuali classi duplicate presenti sull'istanza
				declare @value as nvarchar(max)
				declare @dse_id as nvarchar(max)
				if EXISTS ( select * from ctl_doc with(nolock) where tipodoc in ( 'ISTANZA_ALBO_ME_3','ISTANZA_ALBO_ME_4') and id=@idDoc )
					set @dse_id='DISPLAY_CLASSI'
				ELSE
					set @dse_id='DISPLAY_ABILITAZIONI'

				set @value='###'
				select   @value = @value + items  + '###' 
				from dbo.split((select value from ctl_doc_value with(nolock) where idheader=@idDoc and dse_id=@dse_id and dzt_name='ClasseIscriz'),'###')
				group by (items)

				
				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					Select @id , 'CLASSI' , 0 , 'ClasseIscriz' , @value
			
				
		-- se si tratta di ALBO_PROF valorizzo il campo AttivitaProfessionale sulla sezione CLASSI
		-- e riporto OrdineProfessionale attivita prima fascia
			declare @TipoDoc as varchar(500)

			select @TipoDoc=TipoDoc from ctl_doc with(nolock) where id=@idDoc

			if @TipoDoc in ('ISTANZA_AlboProf','ISTANZA_AlboProf_RP')
			begin
					
				declare @CodiceAtt as varchar(100)
				declare @CodiceAttMultiValore as varchar(max)

				set @CodiceAttMultiValore='###'

				DECLARE crsAtt CURSOR STATIC FOR 

					select C.value + '01' as Codice 
						from ctl_doc_value P with(nolock)
							inner join ctl_doc_value C with(nolock) on C.row=P.row
						where P.idheader=@idDoc and P.dse_id='TIPOLOGIA_INCARICO' and P.dzt_name='SelRow' and P.value='1'
									and C.idheader=P.idheader and C.dse_id=P.dse_id and C.dzt_name='DMV_Cod' 
					union
					select C.value + '02' as Codice 
						from ctl_doc_value P with(nolock)
							inner join ctl_doc_value C with(nolock) on C.row=P.row
						where P.idheader=@idDoc and P.dse_id='TIPOLOGIA_INCARICO' and P.dzt_name='SelRow1' and P.value='1'
								and C.idheader=P.idheader and C.dse_id=P.dse_id and C.dzt_name='DMV_Cod' 

				OPEN crsAtt

				FETCH NEXT FROM crsAtt INTO @CodiceAtt
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
					set @CodiceAttMultiValore = @CodiceAttMultiValore + @CodiceAtt + '###'

					FETCH NEXT FROM crsAtt INTO @CodiceAtt
				END

					
				CLOSE crsAtt 
				DEALLOCATE crsAtt 


				Insert Into CTL_DOC_VALUE 
					( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
				values
					(@id , 'CLASSI' , 0 , 'AttivitaProfessionale' , @CodiceAttMultiValore)
					
				Insert Into CTL_DOC_VALUE 
					( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
				values
					(@id , 'CLASSI' , 0 , 'AttivitaProfessionaleIstanza' , @CodiceAttMultiValore)
	
				--ordine professionale					
				Insert Into CTL_DOC_VALUE 
					( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
				Select @id , 'CLASSI' , 0 , 'OrdineProfessionale' , value
					from CTL_DOC_VALUE
				where idHeader=@idDoc and DSE_ID='TESTATA' and DZT_NAME='OrdineProfessionale'
					

			end
		
			if @TipoDoc in ( 'ISTANZA_AlboProf_2','ISTANZA_AlboProf_SA','ISTANZA_AlboProf_BIM','ISTANZA_AlboProf_VI')
			begin
				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					select @id , 'CLASSI' , 0 , 'AttivitaProfessionale' , value
						from CTL_DOC_Value 
							where IdHeader=@idDoc and DSE_ID='STUDIO_ASSOCIATO' and DZT_Name='AttivitaProfessionaleIstanza'

				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					select @id , 'CLASSI' , 0 , 'AttivitaProfessionaleIstanza' , value
						from CTL_DOC_Value 
							where IdHeader=@idDoc and DSE_ID='STUDIO_ASSOCIATO' and DZT_Name='AttivitaProfessionaleIstanza'

				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					Select @id , 'CLASSI' , 0 , 'OrdineProfessionale' , value
						from CTL_DOC_VALUE
							where idHeader=@idDoc and DSE_ID='TESTATA' and DZT_NAME='OrdineProfessionale'
					
			end		
			if @TipoDoc='ISTANZA_AlboProf_3'
			begin
				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					select @id , 'CLASSI' , 0 , 'AttivitaProfessionale' , value
						from CTL_DOC_Value with(nolock)
							where IdHeader=@idDoc and DSE_ID='DICHIARAZIONI' and DZT_Name='AttivitaProfessionaleIstanza'

				Insert Into CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name, Value)
					select @id , 'CLASSI' , 0 , 'AttivitaProfessionaleIstanza' , value
						from CTL_DOC_Value with(nolock)
							where IdHeader=@idDoc and DSE_ID='DICHIARAZIONI' and DZT_Name='AttivitaProfessionaleIstanza'
			
					
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
