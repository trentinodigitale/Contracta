USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ODC_CREATE_FROM_ODC]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[OLD2_ODC_CREATE_FROM_ODC] ( @IdDoc int  , @idUser int, @bRiduzione int = 0 )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @userRole as varchar(100)
	declare @IdPfuInCharge as int
	declare @NumPO as int
	declare @CodiceModelloConvenzione as varchar(200)
	declare @CodiceModelloOrdinativo as varchar(200)
	declare @IdConvenzione as int
	declare @IdOrdinativo as int	
	declare @NoteConvenzione as nvarchar(max)

	set @Id = ''
	set @Errore=''
	set @userRole=''

	--recupero id convenzione
	select @IdConvenzione=id_convenzione from document_odc with(nolock) where rda_id=@IdDoc

	--controllo se la mandataria settata sulla convenzione è cessata in quel caso esco con un messaggio
	IF EXISTS( select * from aziende with(nolock) where azideleted=1 and idazi=(Select azi_dest from document_convenzione with(nolock) where id=@IdConvenzione))
	BEGIN
		set @Errore = 'Operazione non consentita, il fornitore risulta cessato'
	END

	if @Errore = ''
	BEGIN

		---recupero ruolo dell'utente
		select   @userRole= isnull( attvalue,'')
			from profiliutenteattrib with(nolock)
			where 
				--dztnome = 'UserRoleDefault'  
				dztnome = 'UserRole'  
				and idpfu = @idUser	
				and attvalue='PO'
	
		--se sono punto ordinante metto il documento ordinativo in approvazione per me stesso			
		if @userRole='PO'
		begin	
			set @IdPfuInCharge=@idUser
			set @NumPO=1
		end	
		else
		begin

			--sono punto istruttore (PI)
			--valorizzo @IdPfuInCharge solo se il PO è uno solo
			set @IdPfuInCharge = null
			set @NumPO=0
			select @NumPO=count(*) 
				from PROFILIUTENTEATTRIB PA with(nolock) inner join profiliutente P with(nolock) on PA.attvalue=P.idpfu
				where dztnome='pfuResponsabileUtente' and PA.idpfu=@idUser
						and PA.attvalue in (
										select PA.idpfu from PROFILIUTENTEATTRIB PA,profiliutente P where attvalue='po' 
										and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
						and P.pfudeleted=0

			if @NumPO=1
			begin

				select @IdPfuInCharge=attvalue 
					from PROFILIUTENTEATTRIB PA with(nolock) inner join profiliutente P with(nolock) on PA.attvalue = P.idpfu
					where dztnome='pfuResponsabileUtente' and PA.idpfu=@idUser
							and PA.attvalue in (
										select PA.idpfu from PROFILIUTENTEATTRIB PA with(nolock),profiliutente P with(nolock) where attvalue='po' 
										and dztnome='UserRole' and PA.idpfu = P.idpfu and P.pfudeleted=0)
							and P.pfudeleted=0
			end

		end

		set @id=0
	
		--recupero odc integrativo o di riduzione se esiste per lo stesso utente
		select @id=id 
			from ctl_doc with(nolock)
					inner join document_odc with(nolock) on id=RDA_ID
			where tipodoc='ODC' and statofunzionale='InLavorazione' and idpfu=@idUser and deleted=0
					and @IdDoc = case when @bRiduzione = 0 then IdDocIntegrato else IdDocRidotto end
	
		IF @id=0
		BEGIN
		
			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi, ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
					select @idUser,  TipoDoc, 'Saved' , case when @bRiduzione = 1 then 'Riduzione Ordinativo su ' else 'Ordinativo Integrativo su ' end + Titolo , 
						Body , Azienda ,Destinatario_Azi,ProtocolloRiferimento  , Fascicolo , LinkedDoc  ,'InLavorazione',@IdPfuInCharge , '' as jumpcheck
					from CTL_DOC with(nolock) 
					where Id = @IdDoc

			set @Id = SCOPE_IDENTITY()		

			--inserisco nella  document_ODC
			insert into document_ODC (RDA_ID, RDA_Owner, RDA_Name, RDA_DataCreazione,RDA_DataScad, RDA_Protocol, RDA_Object, RDA_Total,TotalIva, RDA_Stato, 
										RDA_AZI,  RDA_Valuta, RDA_Deleted,Id_Convenzione ,UserRup, NotEditable,IdAziDest,
										NumeroConvenzione,RDA_ResidualBudget,TotaleValoreAccessorio,IdDocIntegrato,CIG, IdDocRidotto, Obbligo_Cig_Derivato, 
										Motivazione_ObbligoCigDerivato, idpfuRup, RichiestaCigSimog,CIG_MADRE  )
				select 
					@Id, @idUser , case when @bRiduzione = 1 then 'Riduzione Ordinativo su ' else 'Ordine Integrativo su ' end + RDA_Name , RDA_DataCreazione ,RDA_DataScad,'', RDA_Object , 0 ,0,   'Saved', 
					RDA_AZI , RDA_Valuta,0
					,Id_Convenzione,@IdPfuInCharge,  case @NumPO when 1 then ' UserRUP  RDA_DataScad  CIG  CIG_MADRE ' else '  RDA_DataScad  CIG  CIG_MADRE ' end
					,IdAziDest,
					NumeroConvenzione,
					--RDA_ResidualBudget,
					isnull( c.Total , 0 ) - isnull( c.TotaleOrdinato , 0 ),
					0, 
					case when @bRiduzione = 0 then @IdDoc else 0 end,
					CIG, 
					case when @bRiduzione = 1 then @IdDoc else 0 end,
					Obbligo_Cig_Derivato,
					Motivazione_ObbligoCigDerivato,
					idpfuRup,
					RichiestaCigSimog,
					--case when @bRiduzione = 1 then document_ODC.CIG_MADRE else '' end
					--conservo sempre il cig madre, in precedenza era stato richiesto solo per le riduzione
					--con kpf 561788 anche per gli integrativi
					document_ODC.CIG_MADRE
					from 
						document_ODC with(nolock)
							inner join document_convenzione c with(nolock) on c.ID = Id_Convenzione
					where 
						rda_Id = @IdDoc
				
			-- Inserisco il record nella document_protocollo
			insert into Document_dati_protocollo ( idHeader )
				values (  @Id )
		
			set @CodiceModelloConvenzione=''
			set @CodiceModelloOrdinativo=''

			select @CodiceModelloConvenzione=[value]
				from ctl_doc_value with(nolock)
				where idheader=@IdConvenzione and dse_id='TESTATA_PRODOTTI' and dzt_name='Tipo_Modello_Convenzione'

			set @CodiceModelloOrdinativo ='MODELLO_BASE_CONVENZIONI_' + @CodiceModelloConvenzione + '_MOD_Ordinativo'

			-- sezione DOCUMENTAZIONE	
			insert into CTL_DOC_ALLEGATI ( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma, NotEditable )
				select DescrizioneRichiesta, AllegatoRichiesto, obbligatorio, anagDoc, @Id as idHeader , TipoFile, isnull(RichiediFirma,'0')  , ' Descrizione ' 
					from Document_Bando_DocumentazioneRichiesta with(nolock)
					where idHeader = @IdConvenzione
		

			--memorizzo nella section_model
			insert into CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
				values (@Id, 'PRODOTTI', @CodiceModelloOrdinativo)

			IF @bRiduzione = 0
			BEGIN

				--setto EsistoIntegrazioni su ODC origine
				update document_ODC set esistonointegrazioni='1' where rda_id=@IdDoc

			END

			--recupero note dalla convenzione
			select @NoteConvenzione=Note from ctl_doc with(nolock) where id=@IdConvenzione
				
			--le inserisco sull'ordinativo
			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value	)
				values ( @IdOrdinativo, 'NOTECONTRATTO', 0, 'NoteConvenzione', @NoteConvenzione	)

		END

	END
	
	if @Errore=''
		-- rirorna id odc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	

END








GO
