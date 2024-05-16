USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA_LOTTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD2_PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA_LOTTI] 
	( @idDocLotto int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @idDoc int
	declare @crlf  varchar(20)
	set @crlf  = '
'

	select @idDoc = idHeader From Document_MicroLotti_Dettagli where id = @idDocLotto


	Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc
	set @DataScadenza=DATEADD(hh,13,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE())))
	---Insert nella CTL_DOC per creare la comunicazione 
	insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataScadenza,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
	VALUES(@IdUser,'PDA_COMUNICAZIONE','Comunicazione Di Verifica Integrativa Lotto',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataScadenza,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-VERIFICA_INTEGRATIVA' )

		
	set @Id = @@identity	

    ---inserisco la riga per tracciare la cronologia nella PDA
	declare @userRole as varchar(100)
	select    @userRole= isnull( attvalue,'')
		from ctl_doc d 
			left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
		where id = @id

		
	insert into CTL_ApprovalSteps 
		( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Verifica Integrativa Lotto' , @IdUser , @userRole   , 1  , getdate() )
		
		
				
		
	-- lista dei fornitori - creiamo le singole comunicazioni
	insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck) 
		select @IdPfu,'PDA_COMUNICAZIONE_GARA', left( 'Comunicazione di Verifica Integrativa Lotto Numero ' + l.NumeroLotto + ' - ' + l.Descrizione , 100 ) ,@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),'Si richedono verifiche per il lotto numero ' + l.NumeroLotto + ' - ' + l.Descrizione + ' per i motivi di seguito indicati' + @crlf + @crlf + cast( c.Body as nvarchar(4000)),'1-VERIFICA_INTEGRATIVA' 
				from Document_PDA_OFFERTE o
					inner join 	Document_MicroLotti_Dettagli b on o.IdHeader = b.idheader and b.tipodoc = 'PDA_MICROLOTTI' and b.Voce = 0
					inner join 	Document_MicroLotti_Dettagli l on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
					inner join	ctl_doc c on c.tipodoc = 'ESITO_LOTTO_VERIFICA' and c.StatoDoc = 'Sended' and c.StatoFunzionale = 'Confermato' and c.LinkedDoc = l.id
				where l.StatoRiga = 'inVerifica' and b.id = @idDocLotto


	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id

END

GO
