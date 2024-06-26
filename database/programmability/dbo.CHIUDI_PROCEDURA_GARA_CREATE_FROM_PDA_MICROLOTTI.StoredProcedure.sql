USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHIUDI_PROCEDURA_GARA_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CHIUDI_PROCEDURA_GARA_CREATE_FROM_PDA_MICROLOTTI] 
	( @iddoc int  , @idUser int )
AS
BEGIN
	declare @id int		
	
	declare @Errore as nvarchar(4000)
	
	set @Errore = ''

	SET NOCOUNT ON

	--VERIFICA SE ESISTE UN DOCUMENTO IN LAVORAZIONE E LO RIAPRE
	select @id=id 
		from CTL_DOC with(nolock) 
			where LinkedDoc=@iddoc and TipoDoc='CHIUDI_PROCEDURA_GARA' 
			and deleted=0 --and StatoFunzionale   in ('InLavorazione') 

	--VERIFICHIAMO SE I LOTTI SONO IN UNO STATO TERMINALE
	IF ISNULL(@id,0)=0
	BEGIN
		--VERIFICHIAMO SE I LOTTI SONO IN UNO STATO TERMINALE
		IF EXISTS ( select id from Document_MicroLotti_Dettagli with(nolock) where TipoDoc='PDA_MICROLOTTI' and IdHeader=@iddoc and Voce=0 and StatoRiga not in ('AggiudicazioneDef','interrotto','NonGiudicabile','Revocato','Deserta') )
		BEGIN
			set @Errore='Operazione non possibile. I lotti devono essere in uno stato terminale'
		END
	END

	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin	
			
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu, Titolo , TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo ,Azienda,ProtocolloRiferimento)
			select @idUser, 'Chiusura Procedura di Gara' ,'CHIUDI_PROCEDURA_GARA'  , 0 , id , body ,C.Fascicolo,P.pfuidazi,ProtocolloRiferimento
				from CTL_DOC C with(NOLOCK) 
					inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser				
				WHERE C.Id=@iddoc 		
					
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
