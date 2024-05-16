USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COMUNICAZIONE_OE_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[COMUNICAZIONE_OE_CREATE_FROM_BANDO_GARA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	declare @Id as INT
	declare @Errore as nvarchar(2000)
	declare @idazi as nvarchar(20)
	declare @ProtocolloBAndo as varchar(40)
	declare @Fascicolo as varchar(50)
	declare @Body as nvarchar(2000)
	declare @azienda_bando as varchar(50)
	declare @User_rup as INT
	

	set @Id = 0
	set @Errore=''

	--VERIFICO SE PER CASO ESISTE UN DOCUMENTO IN CORSO
	select @id=id 
		from ctl_doc with(nolock) 
			where TipoDoc='COMUNICAZIONE_OE' and Deleted=0 and IdPfu=@IdUser 
				  and LinkedDoc=@idDoc and StatoFunzionale='InLavorazione'

	--CREAZIONE COMUNICAZIONE
	if @Errore='' and @Id = 0
	BEGIN

		select @idazi=pfuidazi from ProfiliUtente with(nolock) where idpfu=@IdUser
		
		--recupero campi per inserire sulla nuova comunicazione
		Select 
			@Fascicolo=Fascicolo,
			@ProtocolloBAndo=Protocollo,
			@Body=Body,
			@azienda_bando=azienda,
			@User_rup=CV.value
		from CTL_DOC with(nolock) 
			inner join CTL_DOC_Value CV with(nolock) on CV.IdHeader=id and CV.DSE_ID='InfoTec_comune' and CV.DZT_Name='UserRUP'
			where id=@idDoc
	

		Insert into CTL_DOC (IdPfu,TipoDoc,StatoDoc,Data,Titolo,Body,
							 Azienda,ProtocolloRiferimento,Fascicolo,LinkedDoc,Destinatario_Azi,Destinatario_User)
			select	@IdUser,'COMUNICAZIONE_OE','Saved',getdate(),'Comunicazione verso l''ente',@Body,
							@idazi,@ProtocolloBAndo,@Fascicolo,@idDoc,@azienda_bando,@User_rup			

			
		set @id=SCOPE_IDENTITY()	
					

	END


	if @Errore=''
	begin

		select @Id as id , @Errore as Errore
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore
	end

END




GO
