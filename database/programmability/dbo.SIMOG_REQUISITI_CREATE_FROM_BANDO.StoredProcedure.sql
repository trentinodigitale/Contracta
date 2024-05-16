USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SIMOG_REQUISITI_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SIMOG_REQUISITI_CREATE_FROM_BANDO] ( @idDoc int , @idLog int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @newId INT
	declare @Errore nvarchar(1000)
	declare @tipoDoc varchar(200)
	declare @prevDoc INT

	set @prevDoc = NULL
	set @tipoDoc = 'SIMOG_REQUISITI' 

	select @prevDoc = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc =  @tipoDoc

	IF @prevDoc is not null
	BEGIN
		
		update ctl_doc
				set Deleted = 1
			where id = @prevDoc

	END

	INSERT into CTL_DOC ( TipoDoc, Azienda ,LinkedDoc, StatoFunzionale, PrevDoc, idDoc)
		select  @tipoDoc , Azienda, @idDoc, 'Inviato', @prevDoc, @idLog
			from ctl_doc with(nolock)
			where id=@idDoc		

	set @newId = SCOPE_IDENTITY()

	insert into Document_Bando_Requisiti ( [idHeader], [RequisitoGara], [Valore], [Esclusione], [ComprovaOfferta], [Avvalimento], [BandoTipo], [Riservatezza], [ElencoCIG], [DescrizioneRequisito], [esitoRichiesta] )
						select @newId as [idHeader], [RequisitoGara], [Valore], [Esclusione], [ComprovaOfferta], [Avvalimento], [BandoTipo], [Riservatezza], [ElencoCIG], [DescrizioneRequisito], [esitoRichiesta] 
							from Document_Bando_Requisiti with(nolock)
							where idHeader = @idDoc

	IF  ISNULL(@newId,0) <> 0
	begin

		select @newId as id
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end

END










GO
