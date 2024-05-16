USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_MODULO_PBM]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_MODULO_PBM]
AS
BEGIN

	/**************************************************************/
	/* Nascondo il campo 'Tipo Soggetto' se modulo PBM non attivo */
	/**************************************************************/

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_GARA_TESTATA'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_GARA_TESTATA' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_GARA_TESTATA','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_GARA_TESTATA_ACCORDOQUADRO'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_GARA_TESTATA_ACCORDOQUADRO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_GARA_TESTATA_ACCORDOQUADRO','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_GARA_TESTATA_AVVISO'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_GARA_TESTATA_AVVISO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_GARA_TESTATA_AVVISO','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_GARA_TESTATA_COTTIMO'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_GARA_TESTATA_COTTIMO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_GARA_TESTATA_COTTIMO','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_GARA_TESTATA_RDO'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_GARA_TESTATA_RDO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_GARA_TESTATA_RDO','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_SEMPLIFICATO_TESTATA'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_SEMPLIFICATO_TESTATA' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_SEMPLIFICATO_TESTATA','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end

	-- Gestione campo 'Tipo Soggetto' nel modello BANDO_SEMPLIFICATO_TESTATA'
	if not exists (select id from CTL_Parametri where Contesto = 'BANDO_SEMPLIFICATO_TESTATA2' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE') 
	begin 	

	insert into CTL_Parametri (Contesto,Oggetto,Proprieta,Valore,DataLastUpdate,Deleted,ValoriAmmessi,Descrizione) 	
		values ('BANDO_SEMPLIFICATO_TESTATA2','TIPO_SOGGETTO_ART','HIDE','1',GETDATE(),0,'###0###1###','Nasconde o visualizza il campo Tipo Soggetto') 

	end


	/* Controllo se devo rendere il campo visibile o nasconderlo */
	IF ((select dbo.ISPBMInstalled()) = 1)
	BEGIN
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_GARA_TESTATA' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_GARA_TESTATA_ACCORDOQUADRO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_GARA_TESTATA_AVVISO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_GARA_TESTATA_COTTIMO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_GARA_TESTATA_RDO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_SEMPLIFICATO_TESTATA' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 0 where Contesto = 'BANDO_SEMPLIFICATO_TESTATA2' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
	END
	ELSE
	BEGIN
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_GARA_TESTATA' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_GARA_TESTATA_ACCORDOQUADRO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_GARA_TESTATA_AVVISO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_GARA_TESTATA_COTTIMO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_GARA_TESTATA_RDO' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_SEMPLIFICATO_TESTATA' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
		update CTL_Parametri set Valore = 1 where Contesto = 'BANDO_SEMPLIFICATO_TESTATA2' and Oggetto = 'TIPO_SOGGETTO_ART' and Proprieta = 'HIDE'
	END

END
GO
