USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RIFERIMENTI_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[RIFERIMENTI_CREATE_FROM_CONVENZIONE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT

	declare @Errore as nvarchar(2000)
	declare @PrevDoc as int
	
	set @Errore = ''

	
	if @Errore = '' 
	begin

		-- cerco una versione precedente inlavorazione del documento legata all'utente
		set @id = null
		select @id = id 
			from CTL_DOC 
			where LinkedDoc = @idDoc and TipoDoc = 'RIFERIMENTI'  and idpfu =@IdUser   
				 and StatoFunzionale= 'InLavorazione' and deleted = 0

		if ISNULL(@id,'') = ''
		begin
			--cerco ultimo confermato a prescindere dall'utente
			set @PrevDoc=0
			select @PrevDoc = id 
				from 
					CTL_DOC 
				where LinkedDoc = @idDoc  and TipoDoc = 'RIFERIMENTI' 
					and StatoFunzionale= 'Confermato' and deleted = 0 

			-- altrimenti lo creo
			INSERT into CTL_DOC (
				IdPfu,  TipoDoc, Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_Azi , PrevDoc
					)
				select 
					@IdUser as idpfu ,
						'RIFERIMENTI' as TipoDoc ,  
					'' as Titolo,
						'' as Body, 
					protocollo as ProtocolloRiferimento, 
					C.id as LinkedDoc			
					,azi_dest
					,isnull(@PrevDoc,0)
				from CTL_DOC C
					inner join Document_Convenzione DC on C.id = DC.id
				where C.id = @idDoc and C.tipodoc='CONVENZIONE'

			set @id = SCOPE_IDENTITY ()
		end

		--adeguo la griglia dei riferimenti dalla convenzione
		delete Document_Bando_Riferimenti where idHeader = @id

		insert into Document_Bando_Riferimenti
				(idHeader,idPfu,RuoloRiferimenti)
			select 
				@id,idPfu,RuoloRiferimenti
				from 
					Document_Bando_Riferimenti 
				where idHeader = @idDoc

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
