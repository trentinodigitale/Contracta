USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AQ_QUOTA_CREATE_FROM_AQ]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AQ_QUOTA_CREATE_FROM_AQ] 
	( @idAQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	set @Errore = ''

	SET NOCOUNT ON

	--La make doc from riapre il documento se lo trova in lavorazione altrimenti lo crea nuovo
	select @id=id from CTL_DOC with(nolock) where LinkedDoc=@idAQ and TipoDoc='AQ_QUOTA' and deleted=0 and StatoFunzionale  in ('InLavorazione') 


	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin		
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu,  TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo )
			select @idUser, 'AQ_QUOTA'  , 0 , id , body ,C.Fascicolo
				from CTL_DOC C with(NOLOCK) 				
				WHERE C.Id=@idAQ 		
					
			set @id=SCOPE_IDENTITY()

		
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
