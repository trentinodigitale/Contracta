USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ATTIVA_AQ_CREATE_FROM_AQ]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ATTIVA_AQ_CREATE_FROM_AQ] 
	( @idAQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	set @Errore = ''

	SET NOCOUNT ON

	--La make doc from riapre il documento corrente in lavorazione o confermato se esiste altrimenti lo crea nuovo
	select @id=id from CTL_DOC with(nolock) where LinkedDoc=@idAQ and TipoDoc='ATTIVA_AQ' and deleted=0 and StatoFunzionale  in ('InLavorazione','Confermato') 


	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin
		--lo crea solamente se è il RUP altrimenti MSG "Solo il RUP può attivare l'accordo Quadro"
		IF NOT EXISTS ( select UserRUP from Document_Bando_Semplificato_view where Id=@idAQ and UserRUP=@idUser )
		BEGIN
			set @Errore =  dbo.CNV( 'Solo il RUP può attivare l''accordo Quadro' , 'I' )
		END
		ELSE
		BEGIN
			--CREA IL DOCUMENTO
			INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , deleted  ,LinkedDoc,Body,Fascicolo )
				select @idUser, 'ATTIVA_AQ' ,  pfuIdAzi , 0 , id , body ,C.Fascicolo
					from profiliutente P with(NOLOCK)
						inner join CTL_DOC C with(NOLOCK) on C.Id=@idAQ 						
					WHERE P.idpfu = @IdUser	
					
			set @id=SCOPE_IDENTITY()

		END
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
