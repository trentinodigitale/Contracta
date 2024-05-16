USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_NEW_RISULTATODIGARA_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_NEW_RISULTATODIGARA_CREATE_FROM_PDA_MICROLOTTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	--SE VENGO DAL DOC GEN @iddoc è negativo
	
	SET NOCOUNT ON;

	declare @Id as INT

	declare @IdMsgBando as int
	declare @body as nvarchar(4000)
	declare @tipobando as varchar(100)
	declare @GuidDoc as varchar(500)
	declare @JumpCheck as varchar(100) 
	declare @fascicolo as varchar(100) 
	declare @Errore as nvarchar(2000)
	set @Errore = ''
	
	
	--recupero idmsg del bando
	IF SIGN(@idDoc)=1
	BEGIN
		select @IdMsgBando=@idDoc ,@body=body,@JumpCheck=tipodoc,@fascicolo=Fascicolo from ctl_doc where id=@idDoc 		
	END
	ELSE
	BEGIN
		--VENGO DAL DOC GEN
		select @IdMsgBando=-IdMsg, @body=Object_Cover1, @JumpCheck='DOC_GEN', @fascicolo=ProtocolBG from TAB_MESSAGGI_FIELDS where IdMsg=@idDoc*-1
	END
	IF SIGN(@idDoc)=1
	BEGIN
		--verifica se l'utente che sta creando il documento è utente rup oppure riferimento oppure URP (permesso 150) quando non sono RDO
		IF NOT EXISTS ( select * from ctl_doc C1 
							inner join Document_Bando DB on DB.idHeader=C1.id
							left join Document_Bando_Riferimenti  DR on C1.id=DR.idHeader and DR.RuoloRiferimenti='Bando' 
							left join CTL_DOC_Value CV on CV.IdHeader=c1.id and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP' 
							left join ProfiliUtente P on P.IdPfu=@idUser
							where C1.id=@IdMsgBando and ( ISNULL(DR.idpfu,0) = @idUser or ISNULL(CV.Value,0) = @idUser or ( SUBSTRING(P.pfuFunzionalita,150,1) = '1' and isnull( DB.TipoProceduraCaratteristica , '' ) <> 'RDO' )) 
					  )
		BEGIN
			set @Errore='Operazione non possibile utente non abilitato. Gli utenti fra i riferimenti del bando come "Bando/Invito" ed il responsabile del procedimento possono creare il documento.'
		END
	END
	ELSE
	BEGIN
		IF NOT EXISTS ( Select * from TAB_MESSAGGI_FIELDS where IdMsg=@idDoc*-1 and IdMittente=@IdUser or  dbo.GetField_NEW('UtenteIncaricato',@idDoc*-1)=@IdUser  )
		BEGIN
			set @Errore='Operazione non possibile utente non abilitato. L''utente che ha creato la gara oppure il responsabile del procedimento possono creare il documento.'
		END		
	END

	-- verifica l'esistenza di un documento salvato la ricerca viene fatta anche per l'idpfu
	set @id = 0 
	
	select @id=ID  from CTL_DOC where LinkedDoc =@IdMsgBando and TipoDoc='NEW_RISULTATODIGARA' and StatoFunzionale='InLavorazione' and Deleted=0  and idpfu = @IdUser
	
	if isnull( @id , 0 ) = 0 and  @errore=''
	begin
		--Insert nella document_chiarimenti per creare la nuova risposta
		insert into CTL_DOC ( idpfu,LinkedDoc  ,TipoDoc,Fascicolo,JumpCheck ,Body   )
			values (@IdUser, @IdMsgBando  , 'NEW_RISULTATODIGARA',@fascicolo,@JumpCheck,@body)
			
		set @Id = SCOPE_IDENTITY()	

		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
			values ( @Id,'TESTATA','Oggetto',@body )

   end
	
	
	
	
	
	if @Errore = ''
	begin
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END








GO
