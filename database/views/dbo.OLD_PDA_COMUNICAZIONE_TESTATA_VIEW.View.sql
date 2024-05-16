USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_COMUNICAZIONE_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_PDA_COMUNICAZIONE_TESTATA_VIEW] as
Select 
	C1.*, 
	case  Right(C1.JumpCheck,len(C1.JumpCheck)-2) 
		--NELLE COM ESCLUSIONE NON E' AMMESSA LA RISPOSTA
		when 'ESCLUSIONE' then ' DataScadenza , RichiestaRisposta '
		when 'ESCLUSIONE_MANIFESTAZIONE' then ' DataScadenza , RichiestaRisposta '
		when 'VERIFICA_INTEGRATIVA' then ' RichiestaRisposta '
		--NELLE COM VERIFICA_REQUISITI se presenti destinatari blocco il campo NumeroAziendeSort
		when 'VERIFICA_REQUISITI' then
			case when ISNULL(v.num,0) <> 0 then ' RichiestaRisposta , NumeroAziendeSort ' else ' RichiestaRisposta ' end			
		else
			case Left(C1.JumpCheck,1) when '1' then '' else ' DataScadenza ' end
	end as NotEditable,
	
	C2.value as UserDirigente,


	case Right(C1.JumpCheck,len(C1.JumpCheck)-2) when 'COMUNICAZIONE_FORNITORE_CONVENZIONE' then C33.Value 
				when 'BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA' then 
								case when C33.Value is null then
																case Left(C1.JumpCheck,1)
																	when '1' then 'si'
																	else 'no'
																end
								else C33.Value
								end
	else
		case Left(C1.JumpCheck,1)
			when '1' then 'si'
			else C3.value
		end
	end as RichiestaRisposta,	
	--C4.value as CIG,

	case isnull(C4.value,'')
		when '' then
			case C1.TipoDoc
				when 'PDA_COMUNICAZIONE_GARA' then
					case left(C9.tipodoc,5)
						 when 'BANDO' then DB.CIG
						 --else ''
						 else
							case C8.Linkeddoc
								when 0 then isnull(DB1.CIG,'')
							else ''
						end
					end 					
				else
					case left(C8.tipodoc,5)
						 when 'BANDO' then DB1.CIG
						 else ''
					end 
			 end
		 else ''

	end as CIG,


	--C5.value as CUP,
	case isnull(C5.value,'')
		when '' then
			case C1.TipoDoc
				when 'PDA_COMUNICAZIONE_GARA' then
					case left(C9.tipodoc,5)
						 when 'BANDO' then DB.CUP
						 --else ''
						 else
							case C8.Linkeddoc
								when 0 then isnull(DB1.CUP,'')
							else ''
						end
					end 
				else
					case left(C8.tipodoc,5)
						 when 'BANDO' then DB1.CUP
						 else ''
					end 
			 end
		 else C5.value

	end as CUP,


	 C6.Value as AggiudicazioneCondizionata
	,C7.tipodoc as TipoDoc_LinkedDoc
	,C11.Value as NumeroAziendeSort
	
	--COLONNA AGGIUNTA PER AGGIUNGERE LA GESTIONE DEL NOTEDITABLE SUL DOCUMENTO PDA_COMUNICAZIONE_GARA 
	--LA VISTA E' USATA ANCHE SU ALTRI DOCUMENTI
	,case  Right(C1.JumpCheck,len(C1.JumpCheck)-2) 
		when 'COMUNICAZIONE_FORNITORE_CONVENZIONE' then ' '  
		when 'BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA' then ' Titolo '	
		when 'VERIFICA_INTEGRATIVA' then ' Titolo , RichiestaRisposta '	
		else ' Titolo , DataScadenza ' 
	end as Not_Editable,
	--COLONNA AGGIUNGA PER NASCONDERE ELENCO DESTINATARI SULLA COMUNICAZIONE
	case 
		when C1.JumpCheck in ( '0-REVOCA_BANDO','0-SOSPENSIONE_GARA' )then dbo.ATTIVA_ELENCO_DEST_PROCEDURA(C1.linkeddoc) 
		else 'si'
	end	as ATTIVO_VIS_DEST ,

	--PER LE COMUNICAZIONE_RICHIESTA_STIPULA_CONTRATTO RECUPERO IL VALORE DEL PARAMETRO
	--PER LE ALTRE FISSO A NO
	case  
		when len(C1.JumpCheck) > 2  and Right(C1.JumpCheck,len(C1.JumpCheck)-2) = 'RICHIESTA_STIPULA_CONTRATTO' then	dbo.PARAMETRI('COMUNICAZIONE_RICHIESTA_STIPULA_CONTRATTO','AREA_FIRMA','ATTIVA','NO',-1) 
		else 'NO'
	  end as VISUALIZZA_AREA_FIRMA,

	  '' as StatoGd  --questa colonna viene utilizzata dal documento pda_comunicazione_gara e mentre sulla versione vb6 non causa un errore in c# si, quindi è stata aggiunta
						-- come stringa vuota per preservare il comportamento precedente

from 
	CTL_DOC C1 with(nolock) --PDA_COMUNICAZIONE_GARA
	
	left outer join CTL_DOC C7 with(nolock) on C7.id=c1.linkedDoc --CAPOGRUPPO
	
	left outer join CTL_DOC C8 with(nolock) on C8.id=C7.linkeddoc --PDA
	
	left outer join CTL_DOC C9 with(nolock) on C9.id=C8.linkeddoc --BANDO

	left outer join document_bando DB with(nolock) on DB.idheader=C9.id --DETTAGLIO BANDO

	left outer join document_bando DB1 with(nolock) on DB1.idheader=C8.id --DETTAGLIO BANDO

	left outer join CTL_DOC_VALUE C2 with(nolock) on C1.id = C2.idheader
					 and C2.DSE_ID='DIRIGENTE' and C2.DZT_NAME='UserDirigente' and C2.Row=0
	
	left outer join CTL_DOC_VALUE C3 with(nolock) on C1.id = C3.idheader
					 and C3.DSE_ID='DIRIGENTE' and C3.DZT_NAME='RichiestaRisposta' and C3.Row=0

	left outer join CTL_DOC_VALUE C33 with(nolock) on C1.id = C33.idheader
					 and C33.DSE_ID='TESTATA_RISPOSTA' and C33.DZT_NAME='RichiestaRisposta' and C33.Row=0

	left outer join CTL_DOC_VALUE C4 with(nolock) on C1.id = C4.idheader
					 and C4.DSE_ID='DIRIGENTE' and C4.DZT_NAME='CIG' and C4.Row=0

	left outer join CTL_DOC_VALUE C5 with(nolock) on C1.id = C5.idheader and C5.Row=0
					 and C5.DSE_ID='DIRIGENTE' and C5.DZT_NAME='CUP'

	left outer join CTL_DOC_VALUE C6  with(nolock) on C1.id = C6.idheader
					 and C6.DSE_ID='DIRIGENTE' and C6.DZT_NAME='AggiudicazioneCondizionata' and C6.Row=0
	
	left outer join CTL_DOC_VALUE C11 with(nolock)  on C1.id = C11.idheader
					 and C11.DSE_ID='DIRIGENTE' and C11.DZT_NAME='NumeroAziendeSort' and C11.Row=0

	left join (  select count(*) as num ,linkeddoc from VIEW_PDA_COMUNICAZIONE_DETTAGLI  where OPEN_DOC_NAME='PDA_COMUNICAZIONE_GARA' group by linkeddoc ) V on V.LinkedDoc=C1.id and C1.TipoDoc='PDA_COMUNICAZIONE_GENERICA' 


	left outer join Document_Convenzione DC with(nolock) on DC.id=C1.LinkedDoc --DETTAGLIO CONVENZIONE
GO
