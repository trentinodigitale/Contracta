USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_COMUNICAZIONE_RISP_CREATE_FROM_PDA_COMUNICAZIONE_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_PDA_COMUNICAZIONE_RISP_CREATE_FROM_PDA_COMUNICAZIONE_GARA] 
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
	
	Select @IdPfu=IdPfu,@DataScadenza=DataScadenza,@Destinatario_azi=Destinatario_azi,@Fascicolo=Fascicolo,
			@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,
			@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Note,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale,@jumpcheck=JumpCheck
	from CTL_DOC where id=@idDoc and TipoDoc='PDA_COMUNICAZIONE_GARA' and Statodoc='Sended'
	
	set @BodyPrec = @Body
	set @NotePrec = ''

	set @Titolo='Risposta Verifica Amministrativa'
	
	set @TipoComumincazione = substring(@JumpCheck,3,len(@JumpCheck)-2)	

	if @TipoComumincazione <> ''
		set @Titolo= dbo.CNV( 'Risposta ' + @TipoComumincazione , 'I')
	

	--recupero la precedente fatta dallostesso utente se esiste
	set @PrevDoc = -1

	select @Id= ISNULL(max(id) ,0)
	   from CTL_DOC 
	   where LinkedDoc=@idDoc
		  and TipoDoc in  ( 'PDA_COMUNICAZIONE_RISP')
		  and StatoDoc = 'Saved'
		  and idPfu = @IdUser	

	select @PrevDoc= ISNULL(max(id) ,0)
	   from CTL_DOC 
	   where LinkedDoc=@idDoc
		  and TipoDoc in  ( 'PDA_COMUNICAZIONE_RISP')
		  and StatoDoc = 'Sended'
		  and idPfu = @IdUser	

	--recupero contenuto della precedente se esiste
	if @PrevDoc <> -1
       select @BodyPrec = Body , @NotePrec = note from ctl_doc where id = @PrevDoc
    
	IF @Id = 0
	BEGIN
		---Insert nella CTL_DOC per creare la comunicazione risposta
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,StrutturaAziendale,Destinatario_user,JumpCheck,DataScadenza,note)
		values (@IdUser,'PDA_COMUNICAZIONE_RISP',@Titolo,@Fascicolo,@BodyPrec,@ProtocolloRiferimento,@idDoc,@Destinatario_azi,@StrutturaAziendale,@IdPfu,'0-COMUNICAZIONE_RISPOSTA',@DataScadenza,@NotePrec)	
		set @Id = SCOPE_IDENTITY()	
	END
	
	

	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id

END





GO
