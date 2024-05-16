USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SEDUTA_PDA_FROM_SEDUTA_VIRTUALE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SEDUTA_PDA_FROM_SEDUTA_VIRTUALE]
	-- Add the parameters for the stored procedure here
	@idDoc as int,
	@idPfu as int
AS
BEGIN

	SET NOCOUNT ON;
	Declare @idNuovaSeduta as int
	declare @LNG varchar(10)
	
	select @LNG=lngSuffisso from Lingue where idlng=(select pfuIdLng from Profiliutente where idpfu=@idPfu)

---------------------------------------------------------------------------------------
---------- INSERIMENTO TESTATA
---------------------------------------------------------------------------------------
	INSERT INTO [dbo].[CTL_DOC]
			   ([IdPfu]
			   ,[TipoDoc]
			   ,[StatoDoc]
			   ,[Data]
			   --,[Protocollo]
			   --,[PrevDoc]
			   ,[Deleted]
			   ,[Titolo]
			   ,[Body]
			   ,[Azienda]
			   ,[StrutturaAziendale]
			   --,[DataInvio]
			   --,[DataScadenza]
			   --,[ProtocolloRiferimento]
			   --,[ProtocolloGenerale]
			   ,[Fascicolo]
			   --,[Note]
			   --,[DataProtocolloGenerale]
			   ,[LinkedDoc]
			   --,[SIGN_HASH]
			   --,[SIGN_ATTACH]
			   --,[SIGN_LOCK]
			   --,[JumpCheck]
			   --,[StatoFunzionale]
			   --,[Destinatario_User]
			   --,[Destinatario_Azi]
			   --,[RichiestaFirma]
			   ,[NumeroDocumento]
			   --,[DataDocumento]
			   --,[Versione]
			   ,[VersioneLinkedDoc]
			   --,[GUID]
			   --,[idPfuInCharge]
			   --,[CanaleNotifica]
			   --,[URL_CLIENT]
			   --,[Caption]
			   --,[FascicoloGenerale]
					   )
			select 
					@idPfu 
					, 'SEDUTA_PDA'
					, 'Saved'
					, getDate()
					, 0
					, dbo.CNV('SEDUTA_PDA_DA_SEDUTA_VIRTUALE_TITOLO', @LNG)
					, dbo.CNV('SEDUTA_PDA_DA_SEDUTA_VIRTUALE_BODY', @LNG)
					, azienda
					, StrutturaAziendale
					, Fascicolo
					, @idDoc
					, NumeroDocumento
					, 'SEDUTA_VIRTUALE'
				from SEDUTA_PDA_FROM_PDA where id_From=@idDoc

	set @idNuovaSeduta = @@identity

---------------------------------------------------------------------------------------
---------- INSERIMENTO DATE
---------------------------------------------------------------------------------------

	--Recupero la data di inizio della seduta virtuale
	declare @DataInizioSedutaVirtuale as varchar(19)
	set @DataInizioSedutaVirtuale = convert( varchar(19) , getdate() , 126 )
	declare @IdBando as int 
	select @IdBando = linkedDoc from ctl_doc where id= @idDoc and deleted=0
	if exists(select * from [CTL_DOC_Value] where [IdHeader]=@IdBando and [DSE_ID]='SedutaVirtuale' and [DZT_Name]='DataInizio')
	begin
		select @DataInizioSedutaVirtuale = value from [CTL_DOC_Value] where [IdHeader]=@IdBando and [DSE_ID]='SedutaVirtuale' and [DZT_Name]='DataInizio'
	end

	INSERT INTO [CTL_DOC_Value]
			   ([IdHeader]
			   ,[DSE_ID]
			   ,[Row]
			   ,[DZT_Name]
			   ,[Value])
		select @idNuovaSeduta, 'DATE', 0, 'DaDefinire', '1'
		union all
		select @idNuovaSeduta, 'DATE', 0, 'DataFine', convert( varchar(19) , getdate() , 126 )  
		union all
		select @idNuovaSeduta, 'DATE', 0, 'DataInizio', @DataInizioSedutaVirtuale
		union all
		select @idNuovaSeduta, 'DATE', 0, 'DataSeduta', ''
		union all
		select @idNuovaSeduta, 'DATE', 0, 'NumeroSeduta', cast(NumeroSeduta as varchar) from SEDUTA_PDA_FROM_PDA where id_From=@idDoc
		union all
		select @idNuovaSeduta, 'DATE', 0, 'TipoSeduta', 'Virtuale'

---------------------------------------------------------------------------------------
---------- INSERIMENTO VERBALE
---------------------------------------------------------------------------------------
	declare @JumpCheck as uniqueidentifier
	declare @indice as int
	declare @selRow as char(1) 
	set @selRow = '1'
	declare @GUID as uniqueidentifier
	declare @Titolo as nvarchar(500)
	DECLARE seduta_pda_verbale_cursor CURSOR FAST_FORWARD FOR   
	SELECT cast(Guid as uniqueidentifier), titolo FROM SEDUTA_PDA_VERBALE_FROM_PDA  where id_From=@idDoc order by id
	OPEN seduta_pda_verbale_cursor

	FETCH NEXT FROM seduta_pda_verbale_cursor INTO @GUID, @Titolo

	set @indice = 0
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO [CTL_DOC_Value]
				   ([IdHeader]
				   ,[DSE_ID]
				   ,[Row]
				   ,[DZT_Name]
				   ,[Value])
		    select @idNuovaSeduta, 'VERBALE', @indice, 'guid', cast(@GUID as nvarchar(50))
			union all
			select @idNuovaSeduta, 'VERBALE', @indice, 'SelRow', @selRow
			union all
			select @idNuovaSeduta, 'VERBALE', @indice, 'Titolo', @Titolo

			-- Solo il primo verbale deve essere selezionato.
			set @selRow = '0'

			if @indice = 0
			begin
				-- Conservo il guid per memorizzarlo nel registro della CTL_Doc nella colonna jumpCheck.
				set @JumpCheck = @GUID
			end

			set @indice = @indice +1
	FETCH NEXT FROM seduta_pda_verbale_cursor INTO @GUID, @Titolo
	END

	CLOSE seduta_pda_verbale_cursor
	DEALLOCATE seduta_pda_verbale_cursor

	--Aggiorno la colonna JumpCheck con il Guid del verbale selezionato.
	UPDATE [CTL_DOC]
		SET [JumpCheck] = @JumpCheck
		WHERE id = @idNuovaSeduta 
END
GO
