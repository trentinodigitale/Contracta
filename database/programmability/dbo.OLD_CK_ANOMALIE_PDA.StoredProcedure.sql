USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_ANOMALIE_PDA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_CK_ANOMALIE_PDA]( @idPda int )
AS
begin
	
	declare @IdBando as int
	declare @ListaAlbi as varchar(500)
	declare @IdAzi as int
	declare @Idmsg as int
	declare @IdRowOfferta as int
	declare @Warning as nvarchar(max)

	set @Warning=''

	--recupero id del bando
	select @IdBando=linkeddoc from ctl_doc with (nolock) where id=@idPda

	--recupero ListaAlbi dal bando (sono gli id dei bandi separati da ###)
	select @ListaAlbi=isnull(ListaAlbi,'') from document_bando with (nolock) where idheader=@IdBando
	

	--select substring(',1,3,',2,len(',1,3,')-2)
	--select * from dbo.split('1,3',',')

	--per ogni albo verifico se i fornitori risultano non più iscritti
	if @ListaAlbi = '###'
		set @ListaAlbi = ''

	if @ListaAlbi <> '' 
	begin

		set @ListaAlbi =  replace(@ListaAlbi,'###',',')
		set @ListaAlbi = substring(@ListaAlbi,2,len(@ListaAlbi)-2)

		
		--resetto le anomalie 
		update Document_PDA_OFFERTE 
				set Warning = ''
			where 
				idheader=@idPda

		--per tutte le aziende verifico se non è iscritto all'albo
		
		DECLARE crsAziende CURSOR STATIC FOR 
		
			select 
				distinct O.idRow,isnull(idazi,O.IdAziPartecipante) as IdAzi,idmsg 
				from Document_PDA_OFFERTE O with (nolock)
					left join ctl_doc OP with (nolock) on O.idmsg=OP.linkeddoc and OP.TipoDoc='OFFERTA_PARTECIPANTI'
					left join document_offerta_partecipanti DOP with (nolock) on DOP.idheader=OP.id and tiporiferimento in ('RTI','ESECUTRICI')
				where O.idheader=@idPda

		OPEN crsAziende

		FETCH NEXT FROM crsAziende INTO @IdRowOfferta,@IdAzi,@Idmsg
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			
			
			--cancello le anomalie precedenti del fornitore
			delete Document_Pda_Offerte_Anomalie where IdRowOfferta=@IdRowOfferta and idfornitore=@IdAzi  and isnull( TipoAnomalia , '' ) = ''

			--controllo che risultano ancora iscritti
			--inserisco la riga nella tabella Document_Pda_Offerte_Anomalie
			if not exists( select * from Document_Pda_Offerte_Anomalie with (nolock) where idheader=@idPda and idrowofferta=@IdRowOfferta)
			begin

				insert into Document_Pda_Offerte_Anomalie
					(IdHeader, IdRowOfferta, IdDocOff, IdFornitore, Descrizione)
				
				--lista degli albi a cui un fornitore non è più iscritto
				select 
						@idPda,@IdRowOfferta, @Idmsg,@IdAzi,
						case 
							when tipodoc = 'BANDO' then 'l''azienda risulta nello stato di "' + dbo.GetCodDom2DescML('StatoIscrizione',StatoIscrizione,'I') +'" per l''Albo - '
							when tipodoc = 'BANDO_SDA' then 'l''azienda risulta nello stato di "' + dbo.GetCodDom2DescML('StatoIscrizione',StatoIscrizione,'I')+'" per lo SDA - '
							else ''
						end + cast( Body as varchar(150)) as Descrizione 
					from 
						ctl_doc_destinatari with (nolock) 
							inner join ctl_doc with (nolock) on idheader=id

					where idHeader in ( select items from dbo.split(@ListaAlbi,',')  )  and StatoIscrizione <> 'Iscritto' and idazi=@IdAzi and isnull(statoiscrizione,'')<>''

				

				----recupero tutti i warning della riga offerta corrente
				--select @Warning=@Warning + ' - ' + Descrizione from Document_Pda_Offerte_Anomalie where IdRowOfferta=@IdRowOfferta
				
				----print @Warning
				--set @Warning = substring(@Warning,4,len(@Warning))

				----se presente aggiorna colonna riepilogativa su offerta
				--if @Warning <> ''
				--begin
				--	update Document_PDA_OFFERTE 
				--		set Warning = '<img src="../images/Domain/State_Warning.png" alt="' + @Warning + '" title="' + @Warning + '">'
				--	where 
				--		idRow=@IdRowOfferta
				--end
				
				
			end

			



		FETCH NEXT FROM crsAziende INTO  @IdRowOfferta,@IdAzi,@Idmsg
		END

		CLOSE crsAziende 
		DEALLOCATE crsAziende 	

	end
		
	--INSERISCO WARNING per evidenziare la presenza di offerte fuori termini
	if exists(
			select * 
				from Document_PDA_OFFERTE D WITH(NOLOCK) 
					inner join CTL_DOC_Value CV WITH(NOLOCK) on D.IdMsg=CV.IdHeader and CV.DSE_ID='OFFERTA' and CV.DZT_Name='FUORI_TERMINI' and CV.Value='1' and cv.Row=0
				where D.idheader=@idPda 
			)
	BEGIN
		--INSERISCE L'ANOMALIA PER OFFERTA FUORI TERMINE	
		insert into Document_Pda_Offerte_Anomalie
			(IdHeader, IdRowOfferta, IdDocOff, IdFornitore, Descrizione,TipoAnomalia)													
			select @idPda,D.IdRow,W.id,D.idAziPartecipante,'Invio fuori termine , Offerta riammessa' , 'RIAMMISSIONE_OFFERTA' 
				from Document_PDA_OFFERTE D WITH(NOLOCK) 
					inner join CTL_DOC_Value CV WITH(NOLOCK) on D.IdMsg=CV.IdHeader and CV.DSE_ID='OFFERTA' and CV.DZT_Name='FUORI_TERMINI' and CV.Value='1' and cv.Row=0
					--RECUPERO IL DOCUMENTO DI RIAMMISSIONE CHE HA PORTATO IL FORNITORE AD INVIO OFFERTA FUORI TERMINE
					inner join ( 
									select C.id , Destinatario_Azi
										from  ctl_doc C with(NOLOCK)
											left join Document_Pda_Offerte_Anomalie with(NOLOCK) on IdDocOff=C.id and TipoAnomalia='RIAMMISSIONE_OFFERTA' --and IdFornitore=idAziPartecipante					
										where C.LinkedDoc=@IdBando and C.TipoDoc='RIAMMISSIONE_OFFERTA' and  StatoFunzionale='Inviato'
											and IdRowOfferta IS NULL										
								) as W on Destinatario_Azi=idAziPartecipante 
				where D.idheader=@idPda 

	END	

	-- aggiorno il warning ( spostato per accentrare la logica di composizione )
	exec PDA_UPD_WARNING @idPda 

end

GO
