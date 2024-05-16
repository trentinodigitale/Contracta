USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[STARTUPDBAPPLICATION_AMPIEZZA_DI_GAMMA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STARTUPDBAPPLICATION_AMPIEZZA_DI_GAMMA]
AS
BEGIN
  
  -----------------------------------------------------------------------------------
  --se sul cliente è attivo il modulo MODULO_OPERATORI_ECONOMICI_ESTAR allora rendo visibili i campi sui modelli di scheda_anagrafica e variazione_anagrafica
  -----------------------------------------------------------------------------------
	IF EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'	)
		begin

			if not exists (select * from ctl_parametri with(nolock) where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='PresenzaAmpiezzaDiGamma' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('CONFIG_MODELLI_AMBITO', 'PresenzaAmpiezzaDiGamma', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = '0' where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='PresenzaAmpiezzaDiGamma' and Proprieta='HIDE'
				end		
				

			if not exists (select * from ctl_parametri with(nolock) where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='TipoModelloAmpiezzaDiGamma' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('CONFIG_MODELLI_AMBITO', 'TipoModelloAmpiezzaDiGamma', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = '0' where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='TipoModelloAmpiezzaDiGamma' and Proprieta='HIDE'
				end	
				
			if not exists (select * from ctl_parametri with(nolock) where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='FNZ_UPD' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('CONFIG_MODELLI_AMBITO', 'FNZ_UPD', 'HIDE', '0', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = '0' where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='FNZ_UPD' and Proprieta='HIDE'
				end		
		end

	else

	begin

			if not exists (select * from ctl_parametri with(nolock) where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='PresenzaAmpiezzaDiGamma' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('CONFIG_MODELLI_AMBITO', 'PresenzaAmpiezzaDiGamma', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = '1' where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='PresenzaAmpiezzaDiGamma' and Proprieta='HIDE'
				end		
				
			if not exists (select * from ctl_parametri with(nolock) where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='TipoModelloAmpiezzaDiGamma' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('CONFIG_MODELLI_AMBITO', 'TipoModelloAmpiezzaDiGamma', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = '1' where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='TipoModelloAmpiezzaDiGamma' and Proprieta='HIDE'
				end		

			if not exists (select * from ctl_parametri with(nolock) where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='FNZ_UPD' and Proprieta='HIDE')
				begin
					insert into [dbo].[CTL_Parametri] (Contesto, Oggetto, Proprieta, Valore, ValoriAmmessi, Descrizione )
					   values('CONFIG_MODELLI_AMBITO', 'FNZ_UPD', 'HIDE', '1', '###0###1###', 'Serve per nascondere oppure no il campo')
				end
			else
				begin 
					update ctl_parametri set Valore = '1' where contesto='CONFIG_MODELLI_AMBITO' and Oggetto='FNZ_UPD' and Proprieta='HIDE'
				end		

	end

END
GO
