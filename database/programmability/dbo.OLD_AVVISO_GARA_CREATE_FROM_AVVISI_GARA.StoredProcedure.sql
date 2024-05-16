USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AVVISO_GARA_CREATE_FROM_AVVISI_GARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[OLD_AVVISO_GARA_CREATE_FROM_AVVISI_GARA] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	set @PrevDoc=0
	
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	-- cerco una versione precedente del documento 
	set @id = null

	select @id = id 
		from CTL_DOC with(nolock)
		where LinkedDoc = @idDoc and deleted = 0 and TipoDoc = 'AVVISO_GARA' and statofunzionale = 'InLavorazione' and idpfu = @IdUser

	-- se non esiste lo creo
	IF @id is null and @Errore=''
	BEGIN

			INSERT INTO CTL_DOC ( IdPfu,  TipoDoc, LinkedDoc,VersioneLinkedDoc,fascicolo, ProtocolloRiferimento,idPfuInCharge, StatoFunzionale,note,Body)
				select 	@IdUser , 'AVVISO_GARA' ,  @idDoc, tipodoc, fascicolo,Protocollo,@IdUser, 'InLavorazione','',''
					from ctl_doc gara with(nolock)
							inner join document_bando dt on id=idheader
				where gara.id = @idDoc

			set @id = SCOPE_IDENTITY()

	END	
		
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

	SET NOCOUNT OFF

END
		
		























GO
