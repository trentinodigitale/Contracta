USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ACCORDO_CREA_FABBISOGNI_CREATE_FROM_ENTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_ACCORDO_CREA_FABBISOGNI_CREATE_FROM_ENTE] ( @IdDoc int  , @idUser int )
AS
BEGIN
	---@IdDoc corrisponde ad IDAZI
	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	

	set @Id = 0
	set @Errore=''
	
		
	-- riapro un documento in lavorazione della stessa azienda
		SELECT @Id = id
			from ctl_doc with(nolock) 
			where tipodoc = 'ACCORDO_CREA_FABBISOGNI' and azienda = @IdDoc and StatoFunzionale = 'InLavorazione' and deleted = 0

	

	IF @Id = 0 and @Errore=''
	BEGIN

		--inserisco nella ctl_doc		
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,   StatoFunzionale,IdPfuInCharge )
			values			( @idUser, 'ACCORDO_CREA_FABBISOGNI', 'Saved' , 'Accordo per attivazione Fabbisogni' , '' , @IdDoc , @IdDoc,'InLavorazione', @idUser )

		set @Id = SCOPE_IDENTITY()
		
		

	END
	ELSE
	BEGIN
		update ctl_doc set IdPfu=@idUser,idPfuInCharge=@idUser where id=@id
	END
	
	
	if @Errore=''
	begin
		select @Id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END


GO
