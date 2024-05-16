USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_CONSULTAZIONE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[BANDO_CONSULTAZIONE_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;



	declare @Id as INT
	declare @idSorgente as INT
	declare @Jumpcheck as varchar(100)	
	declare @Errore as nvarchar(4000)
	declare @contatore as varchar(50)
	declare @NumOrd as varchar(50)

	set @Errore = ''
	

	   -- altrimenti lo creo
		INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,caption,Azienda )
			select @IdUser  , 'BANDO_CONSULTAZIONE' , @IdUser ,'BANDO_CONSULTAZIONE',pfuIdAzi
			from ProfiliUtente where IdPfu=@IdUser


		set @id = SCOPE_IDENTITY()	
	
		insert into Document_Bando (idHeader,VisualizzaNotifiche)
			Values(@id,'1')

		insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @id,'InfoTec_comune',0,'UserRUP',@IdUser

		insert into Document_Bando_Riferimenti (idHeader,idPfu,RuoloRiferimenti)
			select @Id,@IdUser,'Quesiti'
		
	
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
