USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERIFICA_REGISTRAZIONE_FORN_CREATE_FROM_PDA_COMUNICAZIONE_GARA]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[VERIFICA_REGISTRAZIONE_FORN_CREATE_FROM_PDA_COMUNICAZIONE_GARA]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(2000)

	set @Errore = ''

	--cerco una versione precedente
	set @id = null
	select  @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc='VERIFICA_REGISTRAZIONE_FORN'

	 --print ISNULL(@id,0)
	if  ISNULL(@id,0)=0
	BEGIN	
		
	   update ctl_attivita set ATV_Execute='si' where ATV_IdDoc=@idDoc and ATV_DocumentName='PDA_COMUNICAZIONE_GARA'

	   insert into CTL_DOC (IdPfu,Titolo,TipoDoc,LinkedDoc,Azienda,prevDoc,idPfuInCharge,destinatario_user,fascicolo,JumpCheck )
	   select @IdUser,'Modifica Dati Registrazione','VERIFICA_REGISTRAZIONE_FORN',@idDoc,c1.azienda,c1.LinkedDoc,0,c2.idPfuInCharge,c2.fascicolo, 'OE-LIMITATO'
	   from ctl_doc c1
	   inner join ctl_doc c2 on c1.linkedDoc=c2.id --and c2.TipoDoc='VERIFICA_REGISTRAZIONE'
	   where c1.id=@idDoc and c1.TipoDoc='PDA_COMUNICAZIONE_GARA'
	   set @Id = @@identity		

	   insert into CTL_DOC_VALUE (IdHeader, DSE_ID, DZT_Name, Value)
	   select @Id,'SCHEDA_OE',DZT_Name,value
	   from CTL_DOC_VALUE where idheader=(Select LinkedDoc from ctl_doc where id=@idDoc) and DSE_ID='SCHEDA_OE'

	   insert into CTL_DOC_VALUE (IdHeader, DSE_ID, DZT_Name, Value)
	   select @Id,'DATI_RAP_LEG',DZT_Name,value
	   from CTL_DOC_VALUE where idheader=(Select LinkedDoc from ctl_doc where id=@idDoc) and DSE_ID='DATI_RAP_LEG'


	END
	if @Errore = '' and ISNULL(@id,'') <> ''
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id	
	end
	else
	begin
		-- rirorna l'errore
		if  ISNULL(@id,'') = '' and @Errore = ''
		BEGIN
			set @Errore='Non e'' stato trovato un documento di Verifica Registrazione Fornitore nel sistema.'
		END
		select 'Errore' as id , @Errore as Errore
	end

END








GO
