USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_CAN_CONFERMA_AUTOMATICA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD2_DASHBOARD_SP_CAN_CONFERMA_AUTOMATICA] ( @IdDoc INT  , @out as varchar(20) output )
AS
BEGIN 
 	set nocount on

	declare @idprev int
	declare @can_conferma as varchar(10)
	declare @value_old as nvarchar(MAX)
	declare @value_new as nvarchar(MAX)
	declare @blocco as int
	declare @id_template_contest as int
	declare @UUID as nvarchar(1000)
	declare @field as varchar(500)
	declare @tipodoc as varchar(100)
	declare @jumpcheck_bando as varchar(100)
	declare @idazi as int
	declare @value as nvarchar(MAX)
	set @blocco=0
	set @idprev=0
	set @out='NO'

	---RECUPERO ID DELLA PRECEDENTE ISTANZA
		select 
			@idprev=i.PrevDoc,
			@tipodoc=i.TipoDoc,
			@idazi=i.azienda,
			@jumpcheck_bando=
			case 
				when b.TipoDoc='BANDO_SDA' then 'BANDO_SDA'
				when b.TipoDoc='BANDO' and ISNULL(b.jumpcheck,'')=''  then 'ME'
				else b.jumpcheck
			end 
		from ctl_doc i
			inner join ctl_doc b on b.id=i.LinkedDoc
		where i.id=@IdDoc 

	--SE ESISTE UN PRECEDENTE DOCUMENTO ISTANZA FACCIO I CONTROLLI PER VERIFICARE SE POSSO INNESCARE LA CONFERMA AUTOMATICA
	IF @idprev > 0
	BEGIN		

		--CONTROLLO SE POSSO FARE LA CONFERMA IN BASE ALLA PRECEDENTE ISTANZA LOGICHE RIPRESE DALLA VISTA PER ATTIVARE IL BOTTONE CONFERMA AUTO SIA SDA CHE ME
		Select @can_conferma=case
			when 	ds.value is null
				and d.StatoFunzionale in ( 'Confermato','ConfermatoParz' ) then 'si'
			when (
					dateadd( month , isnull( ab.NumMaxPerConferma , 0 ) , /*d.datascadenza*/ cast(  ds.value as datetime )   ) >= getdate() 
					or 
					DATEDIFF(day,getDate(),dateadd( day,1,cast(  ds.value as datetime ))) > 0
				)
				and d.StatoFunzionale in ( 'Confermato','ConfermatoParz' )  then 'si'
			else 'no'
		end 
			from ctl_doc d
			left outer join ctl_doc b on b.id = d.linkeddoc and ( left( b.tipodoc , 5 ) = 'BANDO' )
			left outer join ctl_doc_value ds on d.id = ds.idHeader and  ds.dzt_name = 'DataScadenzaIstanza' and ds.dse_id = 'SCADENZA_ISTANZA'
			left outer join Document_Parametri_Abilitazioni ab on ab.deleted = 0 and 
					(
						( ab.TipoDoc = 'SDA' and b.TipoDoc = 'BANDO_SDA' and ab.idheader = b.id )
						or
						( ab.TipoDoc = 'ALBO' and b.TipoDoc = 'BANDO' )
					)
			where d.id=@idprev
			--print @can_conferma			
		 ---FINE CONTROLLO SE POSSO FARE LA CONFERMA IN BASE ALLA PRECEDENTE ISTANZA

		IF @can_conferma='si'
		BEGIN

			--CONTROLLI PER LE ISTANZE DEL ME
			if @jumpcheck_bando = 'ME'
			BEGIN
				--CHIAMA LA STORED PER CONTROLLO SUGLI ALLEGATI
				exec CONFERMA_AUTOMATICA_CONTROLLO_ALLEGATI @IdDoc,@idprev,@can_conferma output
				
				--CHIAMATA ALLA FUNZIONE PER CONTROLLO CAMPI CHIAVE
				if @can_conferma='si'  
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CAMPI_CHIAVE  ( @IdDoc ,@idprev )		
				
				--CHIAMATA ALLA FUNZIONE PER CONTROLLI CLASSI ISCRIZIONE 		
				if @can_conferma='si'  and  @TipoDoc  in ('ISTANZA_AlboOperaEco','ISTANZA_Albo_ME_2','ISTANZA_Albo_ME_RL')
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CLASSI_ISCRIZ  ( @IdDoc ,@idprev,@idazi )		

				--CHIAMATA ALLA FUNZIONE PER CONTROLLI ISTANZA ME_3 ( Soresa )
				if @can_conferma='si' and @tipodoc = 'ISTANZA_Albo_ME_3'
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CAMPI_ISTANZA_ME_3 ( @IdDoc ,@idprev )	
				
				--CHIAMATA ALLA FUNZIONE PER CONTROLLI ISTANZA ME_4 ( Soresa_NEW_2018 controlla anche le classi)
				if @can_conferma='si' and @tipodoc in ( 'ISTANZA_Albo_ME_4')
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CAMPI_ISTANZA_ME_4 ( @IdDoc ,@idprev )

				--CHIAMATA ALLA FUNZIONE PER CONTROLLI ISTANZA_ALBOLAVORI_2 ( Soresa_NEW_2018 controlla anche le categorie)
				if @can_conferma='si' and @tipodoc in ( 'ISTANZA_ALBOLAVORI_2')
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CAMPI_ISTANZA_ALBOLAVORI_2 ( @IdDoc ,@idprev )

				--CHIAMATA ALLA FUNZIONE PER CONTROLLI ISTANZA_AlboFornitori_2 ( Soresa_NEW_2018 controlla anche le classi)
				if @can_conferma='si' and @tipodoc in ( 'ISTANZA_AlboFornitori_2')
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CAMPI_ISTANZAFORNITORI_2 ( @IdDoc ,@idprev )

			 END

			--CONTROLLI PER LE ISTANZE DEL BANDO_SDA
			if @jumpcheck_bando = 'BANDO_SDA'
			BEGIN
				--CHIAMA LA STORED PER CONTROLLO SUGLI ALLEGATI
				exec CONFERMA_AUTOMATICA_CONTROLLO_ALLEGATI @IdDoc,@idprev,@can_conferma output
				
				--CHIAMATA ALLA FUNZIONE PER CONTROLLO CAMPI CHIAVE
				if @can_conferma='si'  
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CAMPI_CHIAVE  ( @IdDoc ,@idprev )		

				--CHIAMATA ALLA FUNZIONE PER CONTROLLO CATEGORIE SE PREVISTE
				if @can_conferma='si'  
					set @can_conferma=[dbo].CONFERMA_AUTOMATICA_CONTROLLO_CATEGORIE  ( @IdDoc ,@idprev )		
				--PER ISTANZA_SDA_2 ( ATTUALMENTE SOLO DI SORESA ) NON CONOSCENDO I CAMPI CHIAVE DA 
				--CONTROLLARE PER ADESSO NON PASSIAMO PER LA CONFERMA AUTOMATICA
				if @can_conferma='si' and @tipodoc = 'ISTANZA_SDA_2'
					set @can_conferma ='no'
								
			END

			--CONTROLLI PER LE ISTANZE DEI BANDI_FORNITORI
			if @jumpcheck_bando = 'BANDO_ALBO_FORNITORI'
			BEGIN
				set @can_conferma ='no'   -----NON PREVISTA, NON ABBIAMO I DATI DA CONTROLLARE
			END

			--CONTROLLI PER LE ISTANZE DEI BANDO_ALBO_LAVORI
			if  @jumpcheck_bando = 'BANDO_ALBO_LAVORI'
			BEGIN
				set @can_conferma ='no'   -----NON PREVISTA, NON ABBIAMO I DATI DA CONTROLLARE
			END

			--CONTROLLI PER LE ISTANZE DEL BANDO_ALBO_PROFESSIONISTI
			if @jumpcheck_bando = 'BANDO_ALBO_PROFESSIONISTI'
			BEGIN
				set @can_conferma ='no'   -----NON PREVISTA, NON ABBIAMO I DATI DA CONTROLLARE
			END

		END

		IF @can_conferma ='si'
		BEGIN			
			set @out = 'SI'
		END

	END
	ELSE  ---SE NON TROVA IL PREV DOC ALLORA NON CI SONO LE CONDIZIONI	 
	BEGIN
		set @out = 'no'
	END

END







GO
