USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AQ_RICHIESTAQUOTA_CREATE_FROM_AQ]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[AQ_RICHIESTAQUOTA_CREATE_FROM_AQ] 
	( @idAQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	set @Errore = ''

	SET NOCOUNT ON

	
	select @id=id 
		from CTL_DOC with(nolock) 
		where LinkedDoc=@idAQ and TipoDoc='AQ_RICHIESTAQUOTA' 
			and deleted=0 and StatoFunzionale   in ('InLavorazione') 
				and IdPfu=@idUser


	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin		
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu,  TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo ,Azienda)
			select @idUser, 'AQ_RICHIESTAQUOTA'  , 0 , id , body ,C.Fascicolo,P.pfuidazi
				from CTL_DOC C with(NOLOCK) 
					inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser				
				WHERE C.Id=@idAQ 		
					
			set @id=SCOPE_IDENTITY()

			INSERT INTO Document_Convenzione_Quote ( idHeader ) SELECT @ID
		
	end

	

		
		if @Errore = '' and ISNULL(@id,0) <> 0
		begin
			-- rirorna l'id del doc da aprire
			select @Id as id
				
		end
		else
		begin

			select 'Errore' as id , @Errore as Errore

		end



END

	
GO
