USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NOTIER_ANNULLA_ISCRIZ_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_NOTIER_ANNULLA_ISCRIZ_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int, @jumpCheck varchar(1000) = '' )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @caption varchar(500)
	declare @idNoter varchar(500)

	declare @cfAzi varchar(100)

	set @Id = 0
	set @Errore=''
	set @idNoter = ''
	set @caption = ''

	select @IdAzi=pfuidazi 
			, @idNoter = isnull(dm2.vatValore_FT,'')
			, @cfAzi = isnull(dm1.vatvalore_ft,'')
		from profiliutente with(nolock)
				left join aziende with(nolock) ON pfuidazi=idazi and pfudeleted=0 
				left join DM_Attributi dm1 with(nolock) ON dm1.lnk = idazi and dm1.dztNome = 'codicefiscale' and dm1.idApp = 1
				left join DM_Attributi dm2 with(nolock) ON dm2.lnk = idazi and dm2.dztNome = 'IDNOTIER' and dm2.idApp = 1
		where idpfu=@idUser  

--exec NOTIER_ISCRIZ_PA_ADD_IPA_PEPPOL 35158966, 45730, '99TRIK', 'SATER-PA-001_XX','0201:99TRIK', '00304260409','IT00304260409','Denominazioe Ufficio','Via Ufficio 123','123123','r.galdo@afsoluzioni.it','Raffaella Galdo','r.galdo@afsoluzioni.it',1,1,1,1
--	select * from DM_Attributi where lnk = 35158966
--	select * from profiliutente inner join aziende on idazi = pfuidazi where idpfu = 45730
--	select top 10 * from ctl_doc order by 1 desc

	IF @idNoter <> '' -- per gli OE
		or
	   exists ( select id from Document_NoTIER_Destinatari a with(nolock) inner join ProfiliUtenteAttrib b with(nolock) on b.IdPfu = @idUser and b.dztNome = 'CodiceIPA_Notier' and b.attValue = a.ID_IPA where piva_cf = @cfAzi and bDeleted = 0 ) --per gli enti
	BEGIN

		-- riapro un documento di annulla iscrizione in lavorazione della stessa azienda
		SELECT @Id = id
			from ctl_doc with(nolock) 
			where tipodoc = 'NOTIER_ANNULLA_ISCRIZ' and azienda = @IdAzi 
				and StatoFunzionale = 'InLavorazione' and deleted = 0 and isnull(jumpcheck,'') = @jumpCheck

	END
	ELSE
	BEGIN
		set @Errore = 'Annullamento iscrizione non possibile. Id Notier non presente'
	END

	IF @Id = 0 and @Errore=''
	BEGIN

		declare @idPrimaIscrizione INT
		declare @cfDaControllare nvarchar(500)

		set @idPrimaIscrizione = -1
		set @cfDaControllare = ''

		set @caption = (
			case  
				when @jumpcheck = 'FATTURE' then 'Annulla Iscrizione Fatture Peppol'		
				when @jumpcheck = 'ISCRIZ_PA' then 'Annulla Iscrizione PEPPOL'	
				else 'Annulla Iscrizione Ordini e DDT Peppol'
			end
		)
		
		--inserisco nella ctl_doc		
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck, Caption)
			values			( @idUser, 'NOTIER_ANNULLA_ISCRIZ', 'Saved' , 'Annullamento iscrizione NoTI-ER' , '' , @IdAzi , null,''  , '' ,NULL,'InLavorazione', @idUser , @jumpCheck, @caption)

		set @Id = SCOPE_IDENTITY()
		
		insert into Document_dati_protocollo (idHeader)	values	(@id)	

	END
	
	if @Errore=''
	begin
		select @Id as id , @Errore as Errore, 'NOTIER_ANNULLA_ISCRIZ' as TYPE_TO
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END











GO
