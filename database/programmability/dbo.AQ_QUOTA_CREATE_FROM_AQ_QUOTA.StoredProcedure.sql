USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AQ_QUOTA_CREATE_FROM_AQ_QUOTA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AQ_QUOTA_CREATE_FROM_AQ_QUOTA] 
	( @idQ int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	set @Errore = ''

	SET NOCOUNT ON
	
	--Se esiste un documento in lavorazione per quell'ente lo riapre altrimenti ne crea uno nuovo copiando dal precedente
	select @id=Q2.id 
		from CTL_DOC Q with(nolock) 
			inner join CTL_DOC Q2 with(nolock) on Q2.Azienda=Q.Azienda and Q2.TipoDoc='AQ_QUOTA' and Q2.deleted=0 and Q2.StatoFunzionale  in ('InLavorazione') 
		where Q.Id=@idQ

	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin		
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu,  TipoDoc , deleted  ,LinkedDoc,Body,Fascicolo,PrevDoc,Titolo ,Azienda)
			select @idUser, 'AQ_QUOTA'  , 0 , LinkedDoc , body ,C.Fascicolo,id,Titolo,Azienda
				from CTL_DOC C with(NOLOCK) 				
				WHERE C.Id=@idQ 		
					
		set @id=SCOPE_IDENTITY()

		insert into Document_Convenzione_Quote ( idHeader , Value_tec__Azi , Importo , Importo_Allocato_Prec,datascadenzaQ )
			select @id , Value_tec__Azi , Importo , Importo,datascadenzaQ
				from Document_Convenzione_Quote 
				where idHeader=@idQ

		insert into CTL_DOC_ALLEGATI ( idHeader , Allegato , Descrizione )
			select @id , Allegato , Descrizione
				from CTL_DOC_ALLEGATI 
				where idHeader=@idQ
				
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
