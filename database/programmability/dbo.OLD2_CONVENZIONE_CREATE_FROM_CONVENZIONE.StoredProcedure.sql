USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CONVENZIONE_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[OLD2_CONVENZIONE_CREATE_FROM_CONVENZIONE] 
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
	declare @contatore as varchar(50)	

	set @Errore = ''
	
	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento in carico all'utente collegato
		set @id = null

		select @id = id 
			from CTL_DOC 
			where LinkedDoc = @idDoc and deleted = 0 
					and TipoDoc in ( 'CONVENZIONE' ) and StatoFunzionale= 'InLavorazione' and ISNULL(jumpcheck,'')='INTEGRAZIONE'
					and ( ISNULL(idPfuInCharge,'') = '' or idPfuInCharge=@IdUser )

		IF ISNULL(@id,'') = ''
		BEGIN

				declare @identifIniziativa varchar(500)
				declare @notEdit varchar(4000)

				set @identifIniziativa = NULL
				set @notEdit = null

				-- se l'utente che sta creando la convenzione non è dell'agenzia
				if not exists ( select idpfu from profiliutente with(Nolock) where idpfu = @IdUser and pfuIdAzi = 35152001 )
				begin
					set @notedit = ' IdentificativoIniziativa '
				end

			   -- altrimenti lo creo
				INSERT into CTL_DOC 
				(
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,idPfuInCharge,jumpcheck,Caption
				 )
				select 
					@IdUser as idpfu 
					,'CONVENZIONE' as TipoDoc
					,'Integrazione Convenzione' as Titolo
					,@idDoc
					,@IdUser
					,'INTEGRAZIONE'
					,'INTEGRAZIONE_CONVENZIONE'
				from CTL_DOC C
					inner join Document_Convenzione DC on C.id = DC.id
				where C.id = @idDoc and C.tipodoc='CONVENZIONE'

				set @id = @@identity	
				
				exec CTL_GetNewProtocol 'CONVENZIONE','',@contatore output
				
				--informzioni della convenzione
				insert into Document_Convenzione (ID,DOC_Owner,DataCreazione,AZI_Dest,IdentificativoIniziativa,Macro_Convenzione,CIG_MADRE,NumOrd,Mandataria,ReferenteFornitore,ReferenteFornitoreHide,CodiceFiscaleReferente,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,DataInizio,DataFine,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,DataScadenzaOrdinativo,Merceologia,Ambito)
					select @id,@IdUser,getdate(),AZI_Dest,IdentificativoIniziativa,Macro_Convenzione,CIG_MADRE,@contatore,Mandataria,ReferenteFornitore,ReferenteFornitoreHide,CodiceFiscaleReferente,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,DataInizio,DataFine,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,DataScadenzaOrdinativo,Merceologia,Ambito
						from document_convenzione
							where id=@idDoc

				insert into Document_dati_protocollo ( idHeader,fascicoloSecondario)
					-- values (  @Id )
				select  @Id,fascicoloSecondario
				from Document_dati_protocollo
				where idHeader=@idDoc

				--informzioni aggiuntive della convenzione
				insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value)
				select @id,DSE_ID,DZT_Name,Value
				from  CTL_DOC_Value 
				where idheader=@idDoc and DSE_ID='INFO_AGGIUNTIVE'
				
				
				--informzioni prodotti della convenzione
				insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value)
				select @id,DSE_ID,DZT_Name,Value
				from  CTL_DOC_Value 
				where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI'


				insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
					select @id,CM.DSE_ID,MOD_Name
						from CTL_DOC_SECTION_MODEL CM with(nolock)
					inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID='CONVENZIONE' and DSE_Param like '%DYNAMIC_MODEL=yes%'	
					where idheader=@idDoc  and CM.DSE_ID=LIB_DocumentSections.DSE_ID
					
				
				--chiamo la stored che gestisce i campi not editable sulla convenzione
				exec CAMPI_NOT_EDITABLE_CONVENZIONE @id , @IdUser
			
				update Document_convenzione 
					set noteditable = isnull(noteditable,'') + isnull(@notedit,'')
				where id = @id

		END

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
