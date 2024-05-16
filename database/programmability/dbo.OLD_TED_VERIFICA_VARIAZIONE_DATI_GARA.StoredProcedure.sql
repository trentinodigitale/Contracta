USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TED_VERIFICA_VARIAZIONE_DATI_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_TED_VERIFICA_VARIAZIONE_DATI_GARA] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id_Gara varchar(100)
	declare @titolo_procedura varchar(500)
	declare @data_apertura varchar(100)

	declare @id_Gara_new varchar(100)
	declare @titolo_procedura_new varchar(500)
	declare @data_apertura_new varchar(100)

	declare @NumLotti int
	declare @NumLotti_new int

	declare @nEqual as int
	declare @IdRichiesta as int = 0

	set @nEqual = 1

	select @IdRichiesta = isnull(max(id),0) from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'DELTA_TED'  ) and StatoFunzionale = 'Inviato' 

	if isnull(@IdRichiesta,0) > 0
	begin
		
		select @id_Gara = id_gara,
				@titolo_procedura = TED_TITOLO_PROCEDURA_GARA,
				@data_apertura = CONVERT(varchar(19), TED_DATA_APERTURA_OFFERTE , 126) 
			from Document_TED_GARA with(nolock)
			where idHeader = @IdRichiesta

		select @id_Gara_new = id_gara,
				@titolo_procedura_new = TED_TITOLO_PROCEDURA_GARA,
				@data_apertura_new = CONVERT(varchar(19), TED_DATA_APERTURA_OFFERTE , 126) 
			from VIEW_TED_DATI_GARA
			where id = @idDoc

		if ( @id_Gara <> @id_Gara_new or @titolo_procedura <> @titolo_procedura_new or @data_apertura <> @data_apertura_new )
			set @nEqual = 0

		--se non ci sono differenze controllo i dettagli
		if @nEqual = 1
		begin

			--select @Divisione_lotti = Divisione_lotti, @CIG_MONOLOTTO = CIG from document_bando with(nolock) where idHeader = @idDoc

			select @NumLotti_new = count(*) 
				from ctl_doc b with(nolock) 
						inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
				where b.id = @idDoc
					
			select @NumLotti = count(*) 
				from Document_TED_LOTTI with(nolock)
				where idHeader = @IdRichiesta


			if exists(
				select l.idRow
					from Document_TED_LOTTI l with(nolock) 
							inner join VIEW_TED_DATI_LOTTI d on d.idGara = @idDoc and d.TED_LOT_NO = l.TED_LOT_NO
					where l.idHeader = @IdRichiesta and ( d.CIG <> l.CIG or d.TED_TITOLO_APPALTO <> d.TED_TITOLO_APPALTO  )
			)
				set @nEqual = 0
			 
		end
	end

	IF @nEqual = 0
		select 'BLOCCA' as Esito
	else
		select top 0 'NON_BLOCCA' as Esito

END










GO
