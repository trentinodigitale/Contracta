USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CONVENZIONE_UPD_PRODOTTI_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[OLD2_CONVENZIONE_UPD_PRODOTTI_CREATE_FROM_CONVENZIONE] 
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

		-- cerco una versione precedente del documento in carico all'utente collegato
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 
		and TipoDoc in ( 'CONVENZIONE_UPD_PRODOTTI' ) and StatoFunzionale= 'InLavorazione'
		and ( ISNULL(idPfuInCharge,'') = '' or idPfuInCharge=@IdUser )

		if ISNULL(@id,'') = ''
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user,idPfuInCharge
					 )
				select 
					@IdUser as idpfu ,
					 'CONVENZIONE_UPD_PRODOTTI' as TipoDoc ,  
					'Sostituzione prodotti in Convenzione' as Titolo,
					 DC.DescrizioneEstesa as Body, 
					protocollo as ProtocolloRiferimento, 
					C.id as LinkedDoc			
					,azi_dest
					,referentefornitore
					,@IdUser
				from CTL_DOC C
					inner join Document_Convenzione DC on C.id = DC.id
				where C.id = @idDoc and C.tipodoc='CONVENZIONE'

				set @id = @@identity
				--inserisco il modello dei prodotti per poi usarlo nel viewer di selezione prodotti
				insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value)
				select  @id,'MOTIVAZIONE','ModelloConvenzione',MOD_Name
				from CTL_DOC_SECTION_MODEL
				where idheader=@idDoc
				--inserisco il modello dei prodotti per poi usarlo nel processo che contralla i prodotti
				--fatto per sfruttare i controlli già presenti sul documento convenzione
				insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value)
				select  @id,'TESTATA_PRODOTTI','Tipo_Modello_Convenzione',value
				from CTL_DOC_VALUE
				where idheader=@idDoc and  DSE_ID='TESTATA_PRODOTTI' and DZT_Name='Tipo_Modello_Convenzione'
				
				--inserisco il modello dei prodotti
				insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
				select @id,DSE_ID,MOD_Name
				from CTL_DOC_SECTION_MODEL
				where idheader=@idDoc

				
			

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
