USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ATTIVA_AQ_CREATE_FROM_ATTIVA_AQ]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ATTIVA_AQ_CREATE_FROM_ATTIVA_AQ] 
	( @idATTIVA_AQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @idAQ int		
	declare @Errore as nvarchar(4000)
	set @Errore = ''

	SET NOCOUNT ON

	select @idAQ=LinkedDoc from CTL_DOC with(nolock) where id=@idATTIVA_AQ 


	--verifica lo stato funzionale del documento di partenza sia confermato altrimenti MSG "Operazione non consentita per lo stato del documento"
	IF NOT EXISTS ( select id from CTL_DOC with(nolock) where id=@idATTIVA_AQ and TipoDoc='ATTIVA_AQ' and deleted=0 and StatoFunzionale  in ('Confermato')  )
	BEGIN
		set @Errore =  dbo.CNV( 'Operazione non consentita per lo stato del documento' , 'I' )
	END


	IF NOT EXISTS ( select UserRUP from Document_Bando_Semplificato_view where Id=@idAQ and UserRUP=@idUser ) and @Errore = ''
	BEGIN
		set @Errore =  dbo.CNV( 'Solo il RUP può attivare l''accordo Quadro' , 'I' )
	END

	--verifica se esiste un documento in lavorazione lo riapre
	select @id=id from CTL_DOC with(nolock) where LinkedDoc=@idAQ and TipoDoc='ATTIVA_AQ' and deleted=0 and StatoFunzionale  in ('InLavorazione') 


	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin		
			--CREA IL DOCUMENTO
			INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , deleted  ,LinkedDoc,Body,Fascicolo,PrevDoc)
				select @idUser, 'ATTIVA_AQ' ,  pfuIdAzi , 0 , id , body ,C.Fascicolo,@idATTIVA_AQ
					from profiliutente P with(NOLOCK)
						inner join CTL_DOC C with(NOLOCK) on C.Id=@idAQ 						
					WHERE P.idpfu = @IdUser	
					
			set @id=SCOPE_IDENTITY()

			--RICOPIO IL CONTENUTO
			update N set N.Titolo=O.Titolo,N.DataScadenza=O.DataScadenza
				from CTL_DOC O
					inner join  CTL_DOC N on N.Id=@id
					where O.Id=@idATTIVA_AQ

			insert into CTL_DOC_ALLEGATI (idHeader,Descrizione,Allegato)
				select @id,Descrizione,Allegato
					from CTL_DOC_ALLEGATI
						where idHeader=@idATTIVA_AQ

		
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
