USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONTRATTO_GARA_CREATE_FROM_INIZIATIVA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CONTRATTO_GARA_CREATE_FROM_INIZIATIVA] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as int
	declare @IdCom as int
	declare @IdAggiudicatario as int
	declare @EnteAggiudicatrice as int
	declare @IdPda as int
	declare @IdBando as int
	declare @ProtocolloBando as varchar(50)
	declare @DataBando as datetime
	declare @Fascicolo as varchar(50)
	declare @DataRiferimentoInizio as datetime
	declare @DataScadenzaOfferta as datetime
	declare @ProtocolloOfferta as varchar(50)
	declare @DataOfferta as datetime
	declare @TotaleAggiudicato as float
	declare @OggettoBando as nvarchar(max)
	declare @ModelloBando as varchar(500)
	declare @ModelloContratto as varchar(4000)
	declare @IdOfferta as int
	declare @Testo as nvarchar(max)
	declare @idpfuOfferta as int
	declare @cig as varchar(100)
	declare @NumRow as int
	declare @TipoDocBando as varchar(500)
	declare @DivisioneLotti as varchar(10)

	declare @errore varchar(1000)
	declare @righeSelezionate varchar(1000)
	declare @totRipetizioni INT
	declare @numero_enti INT

	SET @NumRow=1	

	--DEVONO POTERSI SCEGLIERE L'ENTE ( SE UNICO NEL SISTEMA ATTIVARLO COME DEFAULT E TOGLIERE I COMANDI DI SCELTA )
    select @numero_enti=COUNT( distinct P.pfuIdAzi) 
		from Aziende A with(NOLOCK)
		inner join ProfiliUtente P with(NOLOCK) on A.IdAzi=P.pfuIdAzi and P.IdPfu > 0 and P.pfuDeleted=0
	where aziAcquirente=3 and aziVenditore=0 and aziDeleted=0
	
	IF @numero_enti = 1
	BEGIN
		 select  top 1  @EnteAggiudicatrice = P.pfuIdAzi
			from Aziende A with(NOLOCK)
			inner join ProfiliUtente P with(NOLOCK) on A.IdAzi=P.pfuIdAzi and P.IdPfu > 0 and P.pfuDeleted=0
		where aziAcquirente=3 and aziVenditore=0 and aziDeleted=0 		
	END

	SET @errore = ''

	IF @errore = ''
	BEGIN	
		set @Id = -1		
		if @Id = -1 
		begin
			insert into CTL_DOC ( IdPfu,Titolo, TipoDoc, Azienda ,idPfuInCharge ,Destinatario_Azi,Destinatario_User) 
				values ( @IdUser,'Contratto', 'CONTRATTO_GARA', @EnteAggiudicatrice   , @IdUser  ,NULL,NULL)   

			set @Id = SCOPE_IDENTITY()

			--inserisco una riga su ctl_doc_value con utente che ha presentato l'offerta
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value)
				values ( @Id, 'DOCUMENT', '0', 'FROM_INIZIATIVA' , 1)

			
			--insert into CTL_DOC_ALLEGATI (idHeader,Descrizione,NotEditable,Obbligatorio,FirmeRichieste)
			--	select @Id,'Contratto',' Descrizione , FirmeRichieste ','1','ente_oe'
			--INSERISCO LE RIGHE DI DFAULT NELLA SEZIONE DOCUMENTAZIONE TRAMITE UNA RELAZIONE
			exec INIT_DOCUMENTI_CONTRATTO  @Id, @IdUser 

			--inserisco la riga nella ctl_approvalStep
			insert into ctl_approvalsteps (APS_Doc_Type,APS_ID_DOC,APS_State,APS_Note,APS_Allegato,APS_UserProfile,APS_Idpfu,APS_IsOld)
				select top 1 'CONTRATTO_GARA',@Id,'Compiled','','',isnull( attvalue,''),@IdUser,0 
				from profiliutenteattrib p  with(nolock)
				where  p.idpfu = @IdUser and dztnome = 'UserRoleDefault'		

		end
	
	END

	
	IF @Errore = ''
	BEGIN
		select @Id as id
	END
	ELSE
	BEGIN
		select 'Errore' as id , @Errore as Errore
	END

END





GO
