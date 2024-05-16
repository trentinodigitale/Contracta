USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Verifica_Azienda_For_ToDelete]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[Verifica_Azienda_For_ToDelete] 
(
	@idazi						INT
)
as
begin	
SET NOCOUNT ON
	declare @esito as varchar(10)
	declare @aziIdDscFormaSoc as varchar(100)

	set @esito = 'KO' -- i campi sono uguali
	
	--se azienda ha la forma societaria tra queste allora propongo la cancellazione
	--Consorzio
	--Consorzio con attività esterna
	--Consorzio di cui al dlgs 267/2000
	--Consorzio stabile
	--Contratto di rete dotato di soggettività giuridica
	--Cooperativa sociale
	--Fondazione
	--Fondazione impresa
	--Gruppo Europeo Di Interesse Economico
	--Impresa individuale
	--Istituto religioso
	--Mutua assicurazione
	--Piccola società cooperativa a responsabilità limitata
	--Società a responsabilità limitata
	--Società a responsabilità limitata a capitale ridotto
	--Società a responsabilità limitata con unico socio
	--Società a responsabilità limitata semplificata
	--Società consortile a responsabilità limitata
	--Società consortile cooperativa a responsabilità limitata
	--Società consortile in accomandita semplice
	--Società consortile in nome collettivo
	--Società consortile per azioni
	--Società cooperativa
	--Società cooperativa a responsabilità illimitata
	--Società cooperativa a responsabilità limitata
	--Società cooperativa consortile
	--Società costituita in base a leggi di altro stato
	--Società di fatto
	--Società Europea
	--Società in accomandita semplice
	--Società in nome collettivo
	--Società per azioni
	--Società per azioni con socio unico
	--Società semplice
	--Società in accomandita per azioni

	
	--recupero codice della forma societaria dell'azienda
	select @aziIdDscFormaSoc = aziIdDscFormaSoc from Aziende where IdAzi = @idazi
	
	--se non esiste la relazione oppure esiste entrata nella relazione allora posso procedere con la proposta di cancellazione
	if not exists (select top 1 * from CTL_Relations with (nolock) where REL_Type='AZI_TO_DELETED' and REL_ValueInput ='aziIdDscFormaSoc') 
		or 
		exists (select * from CTL_Relations with (nolock) where REL_Type='AZI_TO_DELETED' and REL_ValueInput ='aziIdDscFormaSoc' and REL_ValueOutput =@aziIdDscFormaSoc )
		set @esito ='OK'

	select @esito as Esito

end






GO
