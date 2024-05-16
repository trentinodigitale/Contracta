USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_ANAG_DOC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















------------------------------------------------------------------
-- ***** stored generica che controlla l'accessibilita ai documenti nuovi ****
-- *****          Applica le seguente regole  *******
-- Ti permetto l'apertura del documento : 
--	1)   Se il tuo idpfu coincide con l'owner del documento ( ctl_doc.idpfu ) 
--  2)   Se il tuo idpfu coincide con l'idpfu dell'utente che ha in carico il documento ctl_doc.idPfuInCharge
--  3)   Se la tua azienda è la stessa azienda dell'owner del documento 
--  4)   Se fai parte dell'azienda dell'ente, cioè dell'azienda master
--  5)   Se fai parte dell'azienda destinataria
--  6)   Se è un documento nuovo (si sta creando un documento, quindi idDoc NEW )
--  7)   Se la procedura è aperta (come un albo) puoi visualizzarne il dettaglio
--  8)   Se 'BANDO_GARA' o 'BANDO_SDA' e EvidenzaPubblica = 1
------------------------------------------------------------------
--Versione=2&data=2014-28-10&Attivita=62090&Nominativo=Sabato
--Versione=3&data=2014-10-24&Attivita=64680&Nominativo=Federico
--Versione=4&data=2015-02-26&Attivita=70503&Nominativo=Enrico
CREATE proc [dbo].[DOCUMENT_PERMISSION_ANAG_DOC]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin

	SET NOCOUNT ON


	if (  ( upper( substring( @idDoc, 1, 3 ) ) = 'NEW' or @idDoc = '' )  and dbo.GetPos( ISNULL( @param , '' ) , '@@@' , 1 ) = ''  )
		or	
		exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue in ('Direttore', 'Amministratore', 'ADMIN' ) and idPfu = @idPfu )
	begin
		select 1 as bP_Read , 1 as bP_Write
	end
	else
	begin
		select 0 as bP_Read , 0 as bP_Write
	end
	
end






















GO
