USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONTRATTO_ESTENSIONE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  PROCEDURE [dbo].[CONTRATTO_ESTENSIONE_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT

	declare @Errore as nvarchar(2000)
	declare @TipoDocSource as varchar(200)
	declare @PrevDoc as int
	

	set @Errore = ''

	
	if @Errore = '' 
	begin
		
		select @TipoDocSource=Tipodoc from CTL_DOC with (nolock) where Id = @idDoc
		
		-- cerco una versione precedente inlavorazione del documento 
		set @id = null
		select @id = id 
			from CTL_DOC with (nolock)
			where LinkedDoc = @idDoc and TipoDoc = 'CONTRATTO_ESTENSIONE'  
				 and StatoFunzionale= 'InLavorazione' and deleted = 0
				 and JumpCheck =@TipoDocSource
		
		if ISNULL(@id,'') = ''
		begin
			
			--cerco ultimo inviato 
			set @PrevDoc=0
			select @PrevDoc = max( id )
				from 
					CTL_DOC with (nolock)
				where LinkedDoc = @idDoc  and TipoDoc = 'CONTRATTO_ESTENSIONE' 
					and StatoFunzionale= 'Confermato' and deleted = 0 

			-- altrimenti lo creo
			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, Titolo, Body, ProtocolloRiferimento, fascicolo, LinkedDoc,azienda, Destinatario_Azi , PrevDoc, jumpcheck
					)
				select 
						@IdUser as idpfu ,
						'CONTRATTO_ESTENSIONE' as TipoDoc ,  
						'' as Titolo,
						'' as Body, 
						protocollo as ProtocolloRiferimento, 
						fascicolo,
						C.id as LinkedDoc,	
						Azienda,		
						Destinatario_Azi 
						,isnull(@PrevDoc,0)  as PrevDoc
						,@TipoDocSource as JumpCheck
					from CTL_DOC C
					
					where C.id = @idDoc 

			set @id = SCOPE_IDENTITY ()

			--riporto il valore del contratto sull'estensione
			insert into CTL_DOC_Value
					(IdHeader , DSE_ID,Row, DZT_Name , Value)
				select
					@id , 'VALORI' as DSE_ID , 0, 'Vaue_Originario' , Value
					from
						CTL_DOC_Value with (nolock)
					where 
						IdHeader = @idDoc and DSE_ID='CONTRATTO' and DZT_Name = 'NewTotal'
						
			--riporto il valore del contratto sull'estensione
			insert into CTL_DOC_Value
					(IdHeader , DSE_ID,Row, DZT_Name , Value)
				select
					@id , 'VALORI' as DSE_ID , 0, 'Total' , Value
					from
						CTL_DOC_Value with (nolock)
					where 
						IdHeader = @idDoc and DSE_ID='CONTRATTO' and DZT_Name = 'NewTotal'
						

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
