USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODIFICA_CONTRATTO_CREATE_FROM_CONTRATTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROCEDURE [dbo].[MODIFICA_CONTRATTO_CREATE_FROM_CONTRATTO] 
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
			from 
				CTL_DOC with (nolock)
			where LinkedDoc = @idDoc and TipoDoc = 'MODIFICA_CONTRATTO'  
				 and StatoFunzionale= 'InLavorazione' and deleted = 0
				 and JumpCheck =@TipoDocSource
		
		if ISNULL(@id,'') = ''
		begin
			
			--cerco ultimo inviato 
			set @PrevDoc=0
			select @PrevDoc = max( id )
				from 
					CTL_DOC  with (nolock)
				where LinkedDoc = @idDoc  and TipoDoc = 'MODIFICA_CONTRATTO' 
					and StatoFunzionale= 'Confermato' and deleted = 0 
			
			-- altrimenti lo creo
			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, Titolo, Body, ProtocolloRiferimento, fascicolo, LinkedDoc,azienda, Destinatario_Azi , PrevDoc, jumpcheck
					)
				select 
					@IdUser as idpfu ,
					'MODIFICA_CONTRATTO' as TipoDoc ,  
					'' as Titolo,
					'' as Body, 
					protocollo as ProtocolloRiferimento, 
					fascicolo,
					C.id as LinkedDoc,	
					Azienda,		
					Destinatario_Azi, 
					isnull(@PrevDoc,0) as PrevDoc,
					@TipoDocSource as JumpCheck
					from 
						CTL_DOC C with (nolock)
					
					where C.id = @idDoc 

			set @id = SCOPE_IDENTITY ()

			--riporto data stipula e data scadenza sulla modifica
			insert into CTL_DOC_Value
					(IdHeader , DSE_ID,Row, DZT_Name , Value)
				select
					@id , 'DATE' as DSE_ID , 0, DZT_Name , Value
					from
						CTL_DOC_Value with (nolock)
					where 
						IdHeader = @idDoc and DSE_ID='CONTRATTO' and DZT_Name in ('DataScadenza','DataStipula')
						


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
