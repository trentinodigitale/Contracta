USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_STARTUPDBAPPLICATION_MODULO_OPERATORI_ECONOMICI_ESTAR]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_STARTUPDBAPPLICATION_MODULO_OPERATORI_ECONOMICI_ESTAR]
AS
BEGIN
  
  -----------------------------------------------------------------------------------
  --se sul cliente è attivo il modulo MODULO_OPERATORI_ECONOMICI_ESTAR allora rendo visibili i campi sui modelli di scheda_anagrafica e variazione_anagrafica
  -----------------------------------------------------------------------------------
	IF dbo.PARAMETRI('ATTIVA_MODULO','MODULO_OPERATORI_ECONOMICI_ESTAR','ATTIVA','NO',-1) = 'YES'
		begin

			if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono1' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziTelefono1', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 1 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono1' and Proprieta='HIDE'
				end
		
			if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono2' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziTelefono2', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 1 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono2' and Proprieta='HIDE'
				end
	
			if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziFax' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziFax', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 1 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziFax' and Proprieta='HIDE'
				end
		
			if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziSitoWeb' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziSitoWeb', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 1 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziSitoWeb' and Proprieta='HIDE'
				end
		
			if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_ENTE_TESTATA_OE' and Oggetto='aziFax' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('AZI_ENTE_TESTATA_OE', 'aziFax', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 1 where contesto='AZI_ENTE_TESTATA_OE' and Oggetto='aziFax' and Proprieta='HIDE'
				end

			if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono1' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('VARIAZIONE_ANAGRAFICA_TESTATA', 'aziTelefono1', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 0 where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono1' and Proprieta='HIDE'
				end

		
			if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono2' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('VARIAZIONE_ANAGRAFICA_TESTATA', 'aziTelefono2', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 0 where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono2' and Proprieta='HIDE'
				end	

			if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziSitoWeb' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('VARIAZIONE_ANAGRAFICA_TESTATA', 'aziSitoWeb', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 0 where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziSitoWeb' and Proprieta='HIDE'
				end

			if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_CLASSI' and Oggetto='ATECO' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('VARIAZIONE_ANAGRAFICA_CLASSI', 'ATECO', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = 0 where contesto='VARIAZIONE_ANAGRAFICA_CLASSI' and Oggetto='ATECO' and Proprieta='HIDE'
				end

		end
	else
	begin

		if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono1' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziTelefono1', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 0 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono1' and Proprieta='HIDE'
			end
		
		if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono2' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziTelefono2', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 0 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziTelefono2' and Proprieta='HIDE'
			end

		if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziFax' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziFax', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 0 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziFax' and Proprieta='HIDE'
			end
	
		
		if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziSitoWeb' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE', 'aziSitoWeb', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 0 where contesto='AZI_UPD_SCHEDA_ANAGRAFICA_DATI_OE' and Oggetto='aziSitoWeb' and Proprieta='HIDE'
			end
		
		if not exists (select * from ctl_parametri with(nolock) where contesto='AZI_ENTE_TESTATA_OE' and Oggetto='aziFax' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('AZI_ENTE_TESTATA_OE', 'aziFax', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 0 where contesto='AZI_ENTE_TESTATA_OE' and Oggetto='aziFax' and Proprieta='HIDE'
			end

		if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono1' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('VARIAZIONE_ANAGRAFICA_TESTATA', 'aziTelefono1', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 1 where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono1' and Proprieta='HIDE'
			end	


		if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono2' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('VARIAZIONE_ANAGRAFICA_TESTATA', 'aziTelefono2', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 1 where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziTelefono2' and Proprieta='HIDE'
			end		

		if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziSitoWeb' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('VARIAZIONE_ANAGRAFICA_TESTATA', 'aziSitoWeb', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 1 where contesto='VARIAZIONE_ANAGRAFICA_TESTATA' and Oggetto='aziSitoWeb' and Proprieta='HIDE'
			end

		if not exists (select * from ctl_parametri with(nolock) where contesto='VARIAZIONE_ANAGRAFICA_CLASSI' and Oggetto='ATECO' and Proprieta='HIDE')
			begin
				insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
				   values('VARIAZIONE_ANAGRAFICA_CLASSI', 'ATECO', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
			end
		else
			begin 
				update ctl_parametri set Valore = 1 where contesto='VARIAZIONE_ANAGRAFICA_CLASSI' and Oggetto='ATECO' and Proprieta='HIDE'
			end

	end

END
GO
