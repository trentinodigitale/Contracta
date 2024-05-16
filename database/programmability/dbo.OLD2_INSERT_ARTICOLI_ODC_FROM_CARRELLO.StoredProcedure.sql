USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_INSERT_ARTICOLI_ODC_FROM_CARRELLO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD2_INSERT_ARTICOLI_ODC_FROM_CARRELLO] 
	( @IdOrdinativo int  , @IdConvenzione int,  @IdPfu int )
AS
BEGIN

	declare @IdModello as int
	declare @CodiceModelloConvenzione as varchar(200)
	declare @DztNameQT as varchar(200)
	declare @DztNamePRZ as varchar(200)
	declare @DztNameVALACC as varchar(200)
	declare @strInsert as varchar(max)
	declare @SQL as varchar(4000)
	declare @ColToEscludere varchar(1000)

	--recupero idconvenzione dall'ordinativo
	if @IdConvenzione=-1
		select @IdConvenzione=Id_Convenzione from document_odc with(nolock) where rda_id=@IdOrdinativo

	select @CodiceModelloConvenzione=value 
		from ctl_doc_value with(nolock)
		where idheader=@IdConvenzione and dse_id='TESTATA_PRODOTTI' and dzt_name='Tipo_Modello_Convenzione'


	--recupero doc di tipo MODELLO con titolo questocodice
	set @IdModello=-1
	select @IdModello=id from ctl_doc with(nolock) where 
	 tipodoc='CONFIG_MODELLI' and deleted=0 
	 and linkeddoc=@IdConvenzione
	 --and statofunzionale='Pubblicato'
	 --and titolo=@CodiceModelloConvenzione

	 --se modello non trovato per le convenzioni migrate su puglia lo prende in questo modo
	if @IdModello = -1
	begin
		select 
			@IdModello=value 
			from 
				CTL_DOC_Value with (nolock)
			where IdHeader=@IdConvenzione and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='id_modello' and Row=0
	end

	--recupero nome attributo quantità
	set @DztNameQT=''
	select @DztNameQT=value from ctl_doc_value  with(nolock)
	where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_QTY' and Row=0

	--recupero nome attributo quantità
	set @DztNamePRZ=''
	select @DztNamePRZ=value from ctl_doc_value  with(nolock)
	where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_PRZ' and Row=0

	--recupero nome attributo quantità
	set @DztNameVALACC=''
	select @DztNameVALACC=value from ctl_doc_value   with(nolock)
	where dse_id='EXTRA' and idheader=@IdModello and dzt_name='DZT_NAME_VALACC' and Row=0

	--inserisco nella  document_ODC_product
	--le 2 colonne tecniche di lavoro sono
	--qty la quantita
	--ValoreEconomico contiene il prezzo

	--------------------------------------------------------------------------------
	-- CANCELLO PRIMA DI INSERIRE PER NON AVERE DUPLICATI SULL'ODC				  --
	-- BASANDO IL RAGIONAMENTO DELLA CHIAVE SUL NUMERO RIGA DELLA CONVENZIONE	 ---
	--------------------------------------------------------------------------------
	delete document_microlotti_dettagli
		where	idheader=@IdOrdinativo 
					and TipoDoc = 'ODC'
					and idHeaderLotto in ( select D.id
											 from carrello C with(nolock)
														inner join document_microlotti_dettagli D with(nolock) on C.id_product = D.Id and D.Tipodoc='CONVENZIONE' and D.Idheader = c.id_convenzione
														inner join document_microlotti_dettagli D2 with(nolock) on d2.NumeroRiga = D.NumeroRiga and  D2.Tipodoc='ODC' and D2.IdHeader = @IdOrdinativo
												where C.idpfu=@IdPfu and c.id_convenzione=@IdConvenzione
											
											 )
			--and codice_regionale in (select codice from carrello where id_convenzione=@IdConvenzione and idpfu=@IdPfu)
				
    --copio le informazioni di servizio dal carrello (controllando che l'articolo si apresente sulla convenzione)
    insert into document_microlotti_dettagli
	    ( IdHeader, TipoDoc, QTY, IdHeaderLotto, ValoreEconomico, ValoreAccessorioTecnico)
	    select @IdOrdinativo, 'ODC', C.QTDISP,  C.id_product, C.prezzoUnitario, C.ValoreAccessorioTecnico
		    from carrello C with(nolock)
					    inner join document_microlotti_dettagli D with(nolock) on C.id_product= D.Id and D.Tipodoc='CONVENZIONE' and c.id_convenzione=D.Idheader
			    where C.idpfu=@IdPfu and c.id_convenzione=@IdConvenzione
    
     --aggiorno i campi viusuali con i valori dei campi tecnici
	--KPF 528643 -- con la vecchia piattaforma se non aveva recuperato @DztNameQT non andava in eccezione, con la nuova l'errore risale bene
	--ho messo questi if per far continuare a fare quello che facevano prima

	-- set @strInsert=	'update document_microlotti_dettagli	set ' + @DztNameQT + '=QTY,' + @DztNamePRZ + '=ValoreEconomico  	where IdHeader=	' + cast(@IdOrdinativo as varchar(100)) + ' and tipodoc=''ODC'''
	--exec (@strInsert)
	if @DztNameQT <> ''
	begin
		set @strInsert=	'update document_microlotti_dettagli	set ' + @DztNameQT + ' = QTY where IdHeader=	' + cast(@IdOrdinativo as varchar(100)) + ' and tipodoc=''ODC'''
		exec (@strInsert)
		--print @strInsert
	end

	if @DztNamePRZ <> ''
	begin
		set @strInsert=	'update document_microlotti_dettagli	set ' + @DztNamePRZ + ' = ValoreEconomico  	where IdHeader=	' + cast(@IdOrdinativo as varchar(100)) + ' and tipodoc=''ODC'''
		exec (@strInsert)
		--print @strInsert
	end

	if @DztNameVALACC <> ''
	begin
		set @strInsert=	'update document_microlotti_dettagli	set ' +@DztNameVALACC+'=ValoreAccessorioTecnico	where IdHeader=	' + cast(@IdOrdinativo as varchar(100)) + ' and tipodoc=''ODC'''
		exec (@strInsert)
		--print @strInsert
	end	
	
	--ricopio tutte le info dalla convenzione sull'ordinativo tranne le colonne di servizio che sono state copiate dal carrello
	--set @SQL='select c.id,o.id from 
	--	document_microlotti_dettagli c 
	--		inner join document_microlotti_dettagli o on c.codice_regionale=o.codice_regionale and c.statoriga=o.statoriga
	
	set @SQL='select c.id,o.id from 
		document_microlotti_dettagli c  with(nolock)
			inner join document_microlotti_dettagli o with(nolock) on c.Id=o.IdHeaderLotto 
	where 
		c.idheader=' + cast(@IdConvenzione as varchar(100)) + '
		and c.Tipodoc=''CONVENZIONE''
		and o.idheader=' + cast(@IdOrdinativo as varchar(100)) + '
		and o.tipodoc=''ODC'''
	
	--set @ColToEscludere = ',IdHeaderLotto,QTY,ValoreEconomico,ValoreAccessorioTecnico,statoriga,' + @DztNameQT + ',' + @DztNamePRZ 
	set @ColToEscludere = ',IdHeaderLotto,QTY,ValoreEconomico,ValoreAccessorioTecnico,' + @DztNameQT + ',' + @DztNamePRZ 
	if @DztNameVALACC <> ''
		set @ColToEscludere = @ColToEscludere + ',' + @DztNameVALACC
	

	--aggiungo chiamamata per copiare tutte le colonne
	exec COPY_DETTAGLI_MICROLOTTI  @SQL , @ColToEscludere

	--cancello gli articoli della convenzione dal carrello
	delete carrello where id_convenzione=@IdConvenzione  and idpfu=@IdPfu

END






GO
