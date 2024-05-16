USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COMUNICAZIONE_OE_RISP_CREATE_FROM_COMUNICAZIONE_OE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[COMUNICAZIONE_OE_RISP_CREATE_FROM_COMUNICAZIONE_OE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(max)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @Destinatario_azi as INT
	declare @jumpcheck as varchar(50)
	declare @Titolo as nvarchar(150)
	declare @TipoComumincazione as varchar(50)
	declare @BodyPrec as nvarchar(max)
	declare @NotePrec as nvarchar(max)
	declare @PrevDoc as int

	set @Id=0
	
	Select @IdPfu=IdPfu,@Destinatario_azi=Destinatario_azi,@Fascicolo=Fascicolo,		
			@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Note,@azienda=azienda
	from CTL_DOC where id=@idDoc and TipoDoc='COMUNICAZIONE_OE' and Statodoc='Sended'
	
	
	set @Titolo='Risposta al Fornitore'
	
	
	

	
	select @Id= ISNULL(id ,0)
	   from CTL_DOC 
	   where LinkedDoc=@idDoc
		  and TipoDoc in  ( 'COMUNICAZIONE_OE_RISP')
		  and StatoDoc = 'Saved'
		  and idPfu = @IdUser	

	
	IF @Id = 0
	BEGIN
		---Insert nella CTL_DOC per creare la comunicazione risposta
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,Destinatario_user,Destinatario_Azi)
		values (@IdUser,'COMUNICAZIONE_OE_RISP',@Titolo,@Fascicolo,@Body,@ProtocolloRiferimento,@idDoc,@azienda,@IdPfu,@Destinatario_azi)	
		set @Id = SCOPE_IDENTITY()	
	END
	
	

	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id

END






GO
