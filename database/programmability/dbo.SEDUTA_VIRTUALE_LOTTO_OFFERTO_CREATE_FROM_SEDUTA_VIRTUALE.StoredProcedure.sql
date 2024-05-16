USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SEDUTA_VIRTUALE_LOTTO_OFFERTO_CREATE_FROM_SEDUTA_VIRTUALE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[SEDUTA_VIRTUALE_LOTTO_OFFERTO_CREATE_FROM_SEDUTA_VIRTUALE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @info as nvarchar(2000)
	declare @num_massimo_doc as int
	declare @num_tot_doc as int
	declare @numero_doc_inseriti as int
	declare @id_off INT
	
	declare @numero_doc_prog as int


	set @Errore = ''
	set @info = ''

	set @Id=@idDoc

	--SE NON LO TROVO ASSEGNO IL MODELLO ECONOMICO DELL'OFFERTA 
	select @id_off=IdMsg
		from Document_MicroLotti_Dettagli DM with(NOLOCK)
			inner join Document_PDA_OFFERTE DO with(NOLOCK) on DO.IdRow=DM.IdHeader
		where DM.id=@idDoc

	IF NOT EXISTS ( select * from CTL_DOC_SECTION_MODEL where IdHeader=@idDoc and DSE_ID='SEDUTA_VIRTUALE_LOTTO_OFFERTO_ECONOMICA' )
	BEGIN
		insert into CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
			select @idDoc,'SEDUTA_VIRTUALE_LOTTO_OFFERTO_ECONOMICA',MOD_Name from CTL_DOC_SECTION_MODEL where IdHeader=@id_off and  DSE_ID='BUSTA_ECONOMICA'
	END 

	if @Errore = ''
	begin
		
		IF @info = ''
		BEGIN

			-- rirorna l'id della nuova comunicazione appena creata
			select @Id as id

		END
		ELSE
		BEGIN
			
			select 'INFO' as id, @info as Errore

		END
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END





GO
