USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_CERTIFICAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_CERTIFICAZIONE]
AS
BEGIN
	declare @strForzaDisattivazione as varchar(max)
	--SE E' ATTIVO IL MODULO E_FORMS, quindi la certificazione è attiva, andiamo ad abilitare tutti i flag della certificazione
	IF EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,E_FORMS,%'	)		
	BEGIN
		update ctl_parametri set Valore='1'  where contesto='CERTIFICATION' 
					and Oggetto in ('certification_req_33134','certification_req_33215','certification_req_33216','certification_req_33245','certification_req_33223')
		update ctl_parametri set Valore='YES'  where contesto='CERTIFICATION' and Oggetto in ('certification_req_33254','certification_req_33214')
		update ctl_parametri set Valore = 'YES' where contesto='ATTIVA_MODULO' and Oggetto='PCP'

	END
	ELSE
	BEGIN
		update ctl_parametri set Valore='0'  where contesto='CERTIFICATION' 
					and Oggetto in ('certification_req_33134','certification_req_33215','certification_req_33216','certification_req_33245','certification_req_33223')
		update ctl_parametri set Valore='NO'  where contesto='CERTIFICATION' and Oggetto in ('certification_req_33254','certification_req_33214')
		update ctl_parametri set Valore = 'NO' where contesto='ATTIVA_MODULO' and Oggetto='PCP'
	END

	set @strForzaDisattivazione=''
	select @strForzaDisattivazione=isnull(REL_ValueOutput,'')  from ctl_relations where rel_type='FLAG_CERTIFICATION' and REL_ValueInput='FORZA_DISATTIVAZIONE'
	
	if @strForzaDisattivazione <> ''
	BEGIN
		set @strForzaDisattivazione = ',' + @strForzaDisattivazione + ','
		if CHARINDEX( ',certification_req_33215,' , @strForzaDisattivazione ) > 0
		BEGIN
			update ctl_parametri set Valore='0'  where contesto='CERTIFICATION'  and Oggetto in ('certification_req_33215')
		END
	END

	
	-- Per il modulo sulla certificazione verifico che la proprietà ATTIVA sia a YES
	-- se è verificata la condizione allora faccio l'update sulla ctl_parametri aggiungendo gli altri stati di attivazione per l'esportazione del fascicolo di gara!
	if exists (select id from ctl_parametri with(nolock) where Contesto = 'CERTIFICATION' and Oggetto = 'certification_req_33254' 
				and Proprieta = 'ATTIVA' and VALORE = 'YES')
	begin
		update ctl_parametri 
			set Valore = '###InEsame###InAggiudicazione###Chiuso###InRettifica###PresOfferte###Pubblicato###Revocato###' 
			
			where Proprieta = 'Stati_Per_Attivazione' and Contesto = 'FASCICOLO_DI_GARA' and Oggetto = 'EsportazioneFascicolo'
	end
	else
	begin
		update ctl_parametri 
			set Valore = '###Chiuso###' 
			where Proprieta = 'Stati_Per_Attivazione' and Contesto = 'FASCICOLO_DI_GARA' and Oggetto = 'EsportazioneFascicolo'
	end

	--------------------------------------------------------------------------------------------
	-- Vado a controllare se attivo o meno il flag del requisito 3.3.1.3-4 e nascondo o visualizzo dei campi sui modelli


	--Nascondo di default il Fascicolo nel modello
	if not exists (select id from CTL_Parametri with(nolock) where Contesto = 'viewer_consultazione_loggriglia'
						and Oggetto = 'Fascicolo' and Proprieta = 'HIDE')
	begin
		insert into CTL_Parametri
			(Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione)
		values
			('viewer_consultazione_loggriglia','Fascicolo','HIDE','1',GETDATE(),0,'###0###1###','Indica se nascondere o meno il campo Fascicolo nel modello')
	end

	--Nascondo di default il Fascicolo nel modello
	if not exists (select id from CTL_Parametri with(nolock) where Contesto = 'viewer_consultazione_loggriglia'
						and Oggetto = 'Protocollo' and Proprieta = 'HIDE')
	begin
		insert into CTL_Parametri
			(Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione)
		values
			('viewer_consultazione_loggriglia','Protocollo','HIDE','1',GETDATE(),0,'###0###1###','Indica se nascondere o meno il campo Protocollo nel modello')
	end

	--Nascondo di default il campo IP nel modello
	if not exists (select id from CTL_Parametri with(nolock) where Contesto = 'viewer_consultazione_loggriglia'
						and Oggetto = 'Ip' and Proprieta = 'HIDE')
	begin
		insert into CTL_Parametri
			(Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione)
		values
			('viewer_consultazione_loggriglia','Ip','HIDE','1',GETDATE(),0,'###0###1###','Indica se nascondere o meno il campo Ip nel modello')
	end

	--Nascondo di default il Fascicolo nel modello
	if not exists (select id from CTL_Parametri with(nolock) where Contesto = 'viewer_consultazione_logfiltro'
						and Oggetto = 'Fascicolo' and Proprieta = 'HIDE')
	begin
		insert into CTL_Parametri
			(Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione)
		values
			('viewer_consultazione_logfiltro','Fascicolo','HIDE','1',GETDATE(),0,'###0###1###','Indica se nascondere o meno il campo Fascicolo nel modello')
	end

	--Nascondo di default il Fascicolo nel modello
	if not exists (select id from CTL_Parametri with(nolock) where Contesto = 'viewer_consultazione_logfiltro'
						and Oggetto = 'Protocollo' and Proprieta = 'HIDE')
	begin
		insert into CTL_Parametri
			(Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione)
		values
			('viewer_consultazione_logfiltro','Protocollo','HIDE','1',GETDATE(),0,'###0###1###','Indica se nascondere o meno il campo Protocollo nel modello')
	end

	
	if exists (select id from CTL_Parametri with(nolock) where Contesto = 'CERTIFICATION'and Oggetto = 'certification_req_33134' and Proprieta = 'Visible' and Valore = 1)
	begin
		update CTL_PARAMETRI set Valore = 0 where Contesto = 'viewer_consultazione_loggriglia' and Oggetto = 'Fascicolo' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 0 where Contesto = 'viewer_consultazione_loggriglia' and Oggetto = 'Protocollo' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 0 where Contesto = 'viewer_consultazione_loggriglia' and Oggetto = 'Ip' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 0 where Contesto = 'viewer_consultazione_logfiltro' and Oggetto = 'Fascicolo' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 0 where Contesto = 'viewer_consultazione_logfiltro' and Oggetto = 'Protocollo' and Proprieta = 'HIDE'
	end
	else
	begin
		update CTL_PARAMETRI set Valore = 1 where Contesto = 'viewer_consultazione_loggriglia' and Oggetto = 'Fascicolo' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 1 where Contesto = 'viewer_consultazione_loggriglia' and Oggetto = 'Protocollo' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 1 where Contesto = 'viewer_consultazione_loggriglia' and Oggetto = 'Ip' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 1 where Contesto = 'viewer_consultazione_logfiltro' and Oggetto = 'Fascicolo' and Proprieta = 'HIDE'
		update CTL_PARAMETRI set Valore = 1 where Contesto = 'viewer_consultazione_logfiltro' and Oggetto = 'Protocollo' and Proprieta = 'HIDE'
	end

	-- Per il modulo sulla certificazione verifico che la proprietà ATTIVA sia a YES
	-- se è verificata la condizione allora faccio l'update sulla ctl_parametri rendendo visibile l'attributo ControlloFirmaBuste in piattaforma
	if exists (select id from CTL_Parametri with(nolock)  where Contesto = 'CERTIFICATION' and Oggetto = 'certification_req_33214' 
				and Proprieta = 'ATTIVA' and VALORE = 'YES')
	begin
		update ctl_parametri set Valore = 0 where Contesto = 'OFFERTA_TESTATA' and Oggetto = 'ControlloFirmaBuste' and Proprieta = 'HIDE'
		update ctl_parametri set Valore = 0 where Contesto = 'OFFERTA_BUSTA_TEC_TESTATA' and Oggetto = 'ControlloFirmaBuste' and Proprieta = 'HIDE'
		update ctl_parametri set Valore = 0 where Contesto = 'OFFERTA_BUSTA_ECO_TESTATA' and Oggetto = 'ControlloFirmaBuste' and Proprieta = 'HIDE'
	end
	else
	begin 
		update ctl_parametri set Valore = 1 where Contesto = 'OFFERTA_TESTATA' and Oggetto = 'ControlloFirmaBuste' and Proprieta = 'HIDE'
		update ctl_parametri set Valore = 1 where Contesto = 'OFFERTA_BUSTA_TEC_TESTATA' and Oggetto = 'ControlloFirmaBuste' and Proprieta = 'HIDE'
		update ctl_parametri set Valore = 1 where Contesto = 'OFFERTA_BUSTA_ECO_TESTATA' and Oggetto = 'ControlloFirmaBuste' and Proprieta = 'HIDE'
	end

	-- Visibilità campi Requisito 3.3.2.2-3
	
	--Nascondo di default "Art.36 Comma 2" nel modello
	if not exists (select  id from CTL_Parametri with(nolock)  where Contesto = 'PDA_MICROLOTTI_OFFERTE_ECO' and Oggetto = 'FNZ_CONTROLLI_2' and Proprieta = 'HIDE')
	begin
		insert into CTL_Parametri
			(Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione)
		values
			('PDA_MICROLOTTI_OFFERTE_ECO','FNZ_CONTROLLI_2','HIDE','1',GETDATE(),0,'###0###1###','Indica se nascondere o meno il campo FNZ_CONTROLLI_2 nel modello')
	end

	if exists (select id from CTL_Parametri with(nolock)  where Contesto = 'CERTIFICATION'and Oggetto = 'certification_req_33223' and Proprieta = 'Visible' and Valore = 1)
	begin
		update CTL_PARAMETRI set Valore = 0 where Contesto = 'PDA_MICROLOTTI_OFFERTE_ECO' and Oggetto = 'FNZ_CONTROLLI_2' and Proprieta = 'HIDE'
	end
	else
	begin
		update CTL_PARAMETRI set Valore = 1 where Contesto = 'PDA_MICROLOTTI_OFFERTE_ECO' and Oggetto = 'FNZ_CONTROLLI_2' and Proprieta = 'HIDE'
	end



END
GO
