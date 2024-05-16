USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_LST_BUSTE_TEC_CREATE_FROM_PDA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[PDA_LST_BUSTE_TEC_CREATE_FROM_PDA] 
	( @idDoc int -- rappresenta l'id dela riga del lotto, legato alla PDA, sul quale si fa la valutazione
	, @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @IdPda as INT

	declare @Errore as nvarchar(2000)
	set @Errore = ''
	
	set @Id = @idDoc

	--Si recupera la pda
	select @IdPda = idHeader from document_microlotti_dettagli where id=@Id

	-- Se si ha avviato la apertura delle buste.
	if(exists(select * from CTL_ApprovalSteps C where C.APS_Doc_Type='PDA_MICROLOTTI' and APS_State = 'PDA_AVVIO_APERTURE_BUSTE_TECNICHE' and APS_ID_DOC=@IdPda))
	begin
		update Document_MicroLotti_Dettagli set StatoRiga = 'InValutazione' where id = @Id and StatoRiga = 'daValutare'
	end

	if @Errore = ''
	begin
		-- rirorna l'id del documento
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END

GO
