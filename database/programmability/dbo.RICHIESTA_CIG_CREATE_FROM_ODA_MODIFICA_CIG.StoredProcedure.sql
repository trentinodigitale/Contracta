USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_CIG_CREATE_FROM_ODA_MODIFICA_CIG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE  PROCEDURE [dbo].[RICHIESTA_CIG_CREATE_FROM_ODA_MODIFICA_CIG] ( @Oda int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @idr as int
	declare @Rup varchar(50)
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int

	declare @notEditable varchar(1000)
	declare @CODICE_CPV_PREVALENTE varchar(50)

	declare @categoriaPrevalente varchar(100)

	declare @TYPE_TO varchar(200)
	declare @bloccaOutput int
	declare @TipoAppaltoGara as varchar(50)

	declare @importoTotale float --Importo dell’OdF al netto dell'IVA
	declare @cigMaster varchar(100)

	declare @idGara INT

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @categoriaMerceologica varchar(100)

	declare @versioneSimog varchar(100)
	declare @docVersione varchar(100)
	declare @statoFunzDoc varchar(100)

	set @versioneSimog = '3.4.2' 

	select top 1 @versioneSimog = DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = 'SYS_VERSIONE_SIMOG'

	set @Errore=''	
	set @notEditable = ''


	-- per effettuare una variazione deve esistere un documento precedentemente inviato
	select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @Oda and deleted = 0 and TipoDoc in (  'RICHIESTA_CIG' ,'RICHIESTA_SMART_CIG'  ) and StatoFunzionale in ( 'Inviato' , 'Invio_con_errori' )  
	IF @newId is null
	BEGIN
		set @Errore = 'Per effettuare la modifica della richiesta smart CIG occorre che prima sia stata eseguita una richiesta'
	end	





	IF @newId is not null
	BEGIN

				
		EXEC RICHIESTA_SMART_CIG_CREATE_FROM_ODA @Oda , @IdUser , 1
				
	end
	else	
	begin

		select 'Errore' as id , @Errore as Errore

	end


END










GO
