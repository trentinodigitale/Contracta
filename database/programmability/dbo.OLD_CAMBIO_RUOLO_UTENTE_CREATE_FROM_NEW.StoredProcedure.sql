USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CAMBIO_RUOLO_UTENTE_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[OLD_CAMBIO_RUOLO_UTENTE_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @Id as INT
	declare @Errore as nvarchar(4000)

	declare @nomeUtente as nvarchar(4000)
	declare @Nome as nvarchar(4000)
	declare @Cognome as nvarchar(4000)
	declare @codicefiscale as nvarchar(4000)
	declare @LinguaAll as nvarchar(4000)
	declare @Telefono as nvarchar(4000)
	declare @Cellulare as nvarchar(4000)
	declare @Email as nvarchar(4000)

	declare @po varchar(100)
	declare @pi varchar(100)
	declare @rup varchar(100)
	declare @rup_pdg varchar(100)

	declare @respPeppol varchar(10)

	declare @sceltaAOO varchar(500)
	declare @UfficioAppartenenza nvarchar(1000)
	
	declare @UserRoleDefault varchar(500)

	declare @DocNome as nvarchar(4000)
	declare @DocCognome as nvarchar(4000)
	declare @DocCodicefiscale as nvarchar(4000)
	declare @DocTelefono as nvarchar(4000)
	declare @DocCellulare as nvarchar(4000)
	declare @DocEmail as nvarchar(4000)

	declare @AttoDiNomina_idoneita as nvarchar(1000)

	set @po='0'
	set @pi='0'
	set @rup='0'
	set @rup_pdg = '0'
	set @respPeppol = '0'

	set @sceltaAOO = ''
	set @UfficioAppartenenza = ''

	set @UserRoleDefault = ''

	set @Errore = ''
	set @nomeUtente = ''
	set @Nome = ''
	set @Cognome = ''
	set @codicefiscale = ''
	set @LinguaAll = ''
	set @Telefono = ''
	set @Cellulare = ''
	set @Email = ''

	-- cerco una versione precedente del documento in carico all'utente collegato e con stato InLavorazione
	set @id = null

	select @id = doc.id ,
			@docnome = isnull(a.value,''),
			@DocCognome = isnull(b.value,''),
			@DocCodicefiscale = isnull(c.value,''),
			@DocTelefono = isnull(d.value,''),
			@DocCellulare = isnull(e.value,''),
			@DocEmail = isnull(f.value,'')
		from CTL_DOC doc with(nolock)
				left join ctl_doc_value A with(nolock) on a.idheader = doc.id and a.DSE_ID = 'UTENTE' and a.DZT_Name = 'Nome'
				left join ctl_doc_value B with(nolock) on B.idheader = doc.id and B.DSE_ID = 'UTENTE' and B.DZT_Name = 'Cognome'
				left join ctl_doc_value C with(nolock) on C.idheader = doc.id and C.DSE_ID = 'UTENTE' and C.DZT_Name = 'codicefiscale'
				left join ctl_doc_value D with(nolock) on D.idheader = doc.id and D.DSE_ID = 'UTENTE' and D.DZT_Name = 'Telefono'
				left join ctl_doc_value E with(nolock) on E.idheader = doc.id and E.DSE_ID = 'UTENTE' and E.DZT_Name = 'Cellulare'
				left join ctl_doc_value F with(nolock) on F.idheader = doc.id and F.DSE_ID = 'UTENTE' and F.DZT_Name = 'Email'
		where doc.deleted = 0 and doc.TipoDoc = 'CAMBIO_RUOLO_UTENTE' and doc.StatoFunzionale in ( 'InLavorazione' ) and doc.idPfuInCharge = @IdUser


	-- recupero i dati utente sia per aggiungerli al documento in creazione
	-- sia per verificare se sono cambiati rispetto alla versione salvata
	select top 1 @nomeUtente = pfu.pfuLogin,
			@Nome = pfu.pfuNomeUtente,
			@Cognome = isnull(pfu.pfuCognome,''),
			@codicefiscale = isnull(pfu.pfuCodiceFiscale,''),
			@LinguaAll = pfu.pfuIdLng,
			@Telefono = isnull(pfu.pfuTel,''),
			@Cellulare = isnull(pfu.pfuCell,''),
			@Email = isnull(pfu.pfuE_Mail,''),

			@UfficioAppartenenza = attr5.attValue,
			@sceltaAOO = attr6.attValue,

				@pi =   case when isnull(attr1.idUsAttr,0) > 0 then '1'
							else '0'
						end,

				@po =   case when isnull(attr2.idUsAttr,0) > 0 then '1'
							else '0'
						end,

				@rup =   case when isnull(attr3.idUsAttr,0) > 0 then '1'
							else '0'
						end,

				@rup_pdg =   case when isnull(attr4.idUsAttr,0) > 0 then '1'
							else '0'
						end,

				@respPeppol = case when rp.IdUsAttr is null then '0' else '1' end,
	
				@UserRoleDefault = attr7.attValue

		from profiliutente pfu with(nolock)
				LEFT JOIN ProfiliUtenteAttrib attr1 with(nolock) ON pfu.idpfu = attr1.idpfu and attr1.dztNome = 'UserRole' and attr1.attValue = 'PI'
				LEFT JOIN ProfiliUtenteAttrib attr2 with(nolock) ON pfu.idpfu = attr2.idpfu and attr2.dztNome = 'UserRole' and attr2.attValue = 'PO'
				LEFT JOIN ProfiliUtenteAttrib attr3 with(nolock) ON pfu.idpfu = attr3.idpfu and attr3.dztNome = 'UserRole' and attr3.attValue = 'RUP'
				LEFT JOIN ProfiliUtenteAttrib attr4 with(nolock) ON pfu.idpfu = attr4.idpfu and attr4.dztNome = 'UserRole' and attr4.attValue = 'RUP_PDG'

				LEFT JOIN ProfiliUtenteAttrib attr5 with(nolock) ON pfu.idpfu = attr5.idpfu and attr5.dztNome = 'AreaDiAppartenenza' and isnull(attr5.attValue,'') <> ''
				LEFT JOIN ProfiliUtenteAttrib attr6 with(nolock) ON pfu.idpfu = attr6.idpfu and attr6.dztNome = 'aoo' and isnull(attr6.attValue,'') <> ''

				LEFT JOIN ProfiliUtenteAttrib attr7 with(nolock) ON pfu.idpfu = attr7.idpfu and attr7.dztNome = 'UserRoleDefault' and isnull(attr7.attValue,'') <> ''

				LEFT JOIN ProfiliUtenteAttrib rp with(nolock) on rp.IdPfu = pfu.idpfu and rp.dztNome = 'UserRole' and rp.attValue = 'RESPONSABILE_PEPPOL'

		where pfu.idpfu = @IdUser

	IF ISNULL(@id,'') = ''
	BEGIN


		INSERT into CTL_DOC (IdPfu,idPfuInCharge,TipoDoc, Titolo,SIGN_LOCK)
			values ( @IdUser ,@IdUser,'CAMBIO_RUOLO_UTENTE' ,'Modifica ruolo utente',0 )

		set @id = SCOPE_IDENTITY()

		-- popolamento dati per la sezione 'UTENTE'
		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','NomeUtente',@nomeUtente,0 )
				
		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','Nome',@Nome,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','Cognome',@Cognome,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','codicefiscale',@codicefiscale,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','LinguaAll',@LinguaAll,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','Telefono',@Telefono,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','Cellulare',@Cellulare,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'UTENTE','Email',@Email,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','PI',@pi,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','PO',@po,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','scelta_RUP',@rup,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','scelta_RUP_PDG',@rup_pdg,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','ResponsabilePEPPOL',@respPeppol,0 )
			

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','UserRoleDefault',@UserRoleDefault,0 )
		

		-- popolamento dati per la sezione 'SCELTA_RUOLO2'
		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO2','SceltaAOO',@sceltaAOO,0 )

		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','AreaDiAppartenenza',@UfficioAppartenenza,0 )

       ---recupero i precenti RESPONSABILE assegnati
		declare @IdUsAttr INT
		declare @row as int
		set @row=0

		declare CurProg Cursor Static for 
			select IdUsAttr
				from ProfiliUtenteAttrib with(nolock)
				where IdPfu=@IdUser and dztNome='pfuResponsabileUtente'
				order by IdUsAttr

		open CurProg

			FETCH NEXT FROM CurProg INTO @IdUsAttr
			WHILE @@FETCH_STATUS = 0
			BEGIN

				insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
					select @id,'RESPONSABILE','FNZ_DEL','',@row
					from ProfiliUtenteAttrib with(nolock)
					where IdUsAttr=@IdUsAttr
					
				insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
					select @id,'RESPONSABILE','pfuResponsabileUtente',attValue,@row
					from ProfiliUtenteAttrib with(nolock)
					where IdUsAttr=@IdUsAttr
				  	set @row=@row+1		 
					 
				FETCH NEXT FROM CurProg  INTO @IdUsAttr

			END 

		CLOSE CurProg
		DEALLOCATE CurProg


		-- aggiungo la spunta per i ruoli di Stella -- anche se specifica del cliente
		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'RESPONSABILE_RPA','pfuResponsabileUtente',attValue,ROW_NUMBER ( )  over ( order by IdUsAttr asc ) -1
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'pfuResponsabileUtenteRPA' 
				order by IdUsAttr

		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'RESPONSABILE_RPS','pfuResponsabileUtente',attValue,ROW_NUMBER ( )  over ( order by IdUsAttr asc ) -1
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'pfuResponsabileUtenteRPS' 
				order by IdUsAttr

		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'PLANT','Plant',attValue,0
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'PLANT' 



		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'SCELTA_RUOLO_PRO_AMM','PI','1',0
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'UserRole' and attValue = 'PRO_PA'

		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'SCELTA_RUOLO_PRO_AMM','PO','1',0
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'UserRole' and attValue = 'PRO_RPA'


		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'SCELTA_RUOLO_PRO_STR','PI','1',0
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'UserRole' and attValue = 'PRO_PS'

		insert into CTL_DOC_Value (idheader, DSE_ID,DZT_Name,Value,row)
			select @id,'SCELTA_RUOLO_PRO_STR','PO','1',0
				from ProfiliUtenteAttrib with(nolock)
				where idpfu =  @idUSer and dztnome = 'UserRole' and attValue = 'PRO_RPS'

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, row, dzt_name, value )
			select @Id, 'IPA', (ROW_NUMBER() OVER(ORDER BY attvalue ASC)) -1 , dztnome, attvalue 
				from ProfiliUtenteAttrib with(nolock) 
				where idpfu = @idUser and dztNome = 'CodiceIPA'
		
		--se esiste recupero AttoDiNomina_idoneita dall'ultimo doc inviato
		set @AttoDiNomina_idoneita = ''
		select 
				top 1 @AttoDiNomina_idoneita = isnull(value,'')
			from 
				ctl_doc with (nolock)
					inner join ctl_doc_value with (nolock) on IdHeader = id and dse_id='SCELTA_RUOLO' and dzt_name='AttoDiNomina_Idoneita' and value <>''
			where
				idpfu = @IdUser and tipodoc='CAMBIO_RUOLO_UTENTE' and Deleted = 0  and StatoFunzionale = 'Inviato'
			order by DataInvio desc
		
		insert into ctl_doc_value (idheader, DSE_ID,DZT_Name,Value,row)
			values ( @id,'SCELTA_RUOLO','AttoDiNomina_Idoneita',@AttoDiNomina_idoneita,0 )
		--fine riporto AttoDiNomina_idoneita


	END
	ELSE
	BEGIN


		-- Se esiste gia un documento nello stato di salvato
		-- passo a verificare se i dati utente sono cambiati. 
		-- se è così, li aggiorno e metto il documento nello stato di 'genera pdf' (così da costringerlo a rigenerare il pdf se l'avesse gia fatto )
		-- per avere un pdf aggiornato con gli ultimi dati
		IF @DocCellulare <> @Cellulare or @DocCodicefiscale <> @codicefiscale
			or @DocCognome <> @Cognome or @DocEmail <> @Email or @DocNome <> @nome or @DocTelefono <> @Telefono 
		BEGIN

			UPDATE ctl_doc_value 
				SET VALUE = @nome
			WHERE idheader = @id and DSE_ID = 'UTENTE' and DZT_Name = 'Nome'

			UPDATE ctl_doc_value 
				SET VALUE = @Cognome
			WHERE idheader = @id and DSE_ID = 'UTENTE' and DZT_Name = 'Cognome'

			UPDATE ctl_doc_value 
				SET VALUE = @codicefiscale
			WHERE idheader = @id and DSE_ID = 'UTENTE' and DZT_Name = 'codicefiscale'

			UPDATE ctl_doc_value 
				SET VALUE = @Telefono
			WHERE idheader = @id and DSE_ID = 'UTENTE' and DZT_Name = 'Telefono'

			UPDATE ctl_doc_value 
				SET VALUE = @Cellulare
			WHERE idheader = @id and DSE_ID = 'UTENTE' and DZT_Name = 'Cellulare'

			UPDATE ctl_doc_value 
				SET VALUE = @Email
			WHERE idheader = @id and DSE_ID = 'UTENTE' and DZT_Name = 'Email'

			UPDATE ctl_doc
				set SIGN_HASH = '', SIGN_LOCK = 0, SIGN_ATTACH = ''
			where id = @id

		END

	END





	if @Errore = ''
	begin
		-- rirorna l'id del nuovo documento
		select @Id as id
	end
	else
	begin
		-- rirorna l'errore
		select -1 as id , @Errore as Errore
	end




END





GO
