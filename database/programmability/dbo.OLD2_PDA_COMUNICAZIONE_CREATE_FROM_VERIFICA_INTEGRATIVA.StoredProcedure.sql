USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA] 
	( @idDoc int , @IdUser int  )
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
	declare @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA as nvarchar(4000)
	set @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA=''

	--controllo se esistono fornitori nello stato utile alla comunicazione integrativa
	IF NOT EXISTS ( select * from Document_PDA_OFFERTE 	where idHEader=@idDoc and StatoPda in ('9','22') )
	BEGIN
		select 'ERRORE' as id , 'Non sono presenti offerte il cui stato consente la creazione della comunicazione di verifica integrativa.' as Errore
	END
	ELSE
	BEGIN


			Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc

			set @DataScadenza= NULL -- RIMOSSO IN SEGUITO A RICHIESTA DI NAPOLI DATEADD(hh,23,DATEADD(mi,59,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE() ) ) ) )
			---Insert nella CTL_DOC per creare la comunicazione 
			insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataScadenza,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
			VALUES(@IdUser,'PDA_COMUNICAZIONE','Comunicazione Di Verifica Integrativa',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataScadenza,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-VERIFICA_INTEGRATIVA' )

		
			set @Id = @@identity	

			---inserisco la riga per tracciare la cronologia nella PDA
			declare @userRole as varchar(100)
			select    @userRole= isnull( attvalue,'')
				from ctl_doc d 
					left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
				where id = @id

		
			insert into CTL_ApprovalSteps 
				( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Verifica Integrativa' , @IdUser , @userRole   , 1  , getdate() )
		
			
			
			--inserisco riga nella ctl_doc_value 
			insert into CTL_DOC_VALUE 
				(IdHeader, DSE_ID, Row, DZT_Name, Value)
			values
				(@Id, 'DIRIGENTE','0','RichiestaRisposta','si')
				
			select @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA=ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY='testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA'

			-- lista dei fornitori - creiamo le singole comunicazioni
			insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck,  VersioneLinkedDoc) 
				select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Integrativa',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),dbo.PDA_MICROLOTTI_Esito(o.IdRow) + ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA,'1-VERIFICA_INTEGRATIVA' 
						, case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as VersioneLinkedDoc
					from Document_PDA_OFFERTE o with(nolock)
					left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='Pubblicato' and linkeddoc=idmsg
					left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
					cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

					where o.idHEader=@idDoc and StatoPda in ('9','22')
				UNION 
				--AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
				select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Integrativa',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DF.PARTECIPANTE,getDate(),dbo.PDA_MICROLOTTI_Esito(DF.IdRow) + ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA,'1-VERIFICA_INTEGRATIVA' 
						,Ruolo_Partecipante
					from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DF						
					where StatoPda in ('9','22')
	END

	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id

END







GO
