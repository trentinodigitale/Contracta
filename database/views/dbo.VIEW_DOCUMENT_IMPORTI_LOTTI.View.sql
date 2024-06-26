USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_IMPORTI_LOTTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW  [dbo].[VIEW_DOCUMENT_IMPORTI_LOTTI]
as
	select --distinct
	CL.IdRow as Id
	,CL.* 
	,'CONVENZIONE_IMPORTI_LOTTO_ENTE' as OPEN_DOC_NAME
	,
	case Importo
		when 0 then null
		else	(Impegnato/Importo) * 100 
	end  as PercErosione	
	,C.Titolo
	,C.Protocollo
	,C.DataInvio
	,CV.Azi_dest
	,CV.NumOrd
	,CV.DataFine
	,CV.DescrizioneEstesa
	,isnull(rda_total,0) as rda_total
	from
		document_convenzione_lotti	CL
			inner join ctl_doc C on	C.id=CL.idheader and Tipodoc='CONVENZIONE' and c.deleted = 0 
				inner join document_convenzione CV on C.id=CV.id
					left join 
					--(
					--		SELECT 
					--		C.Linkeddoc as IdHeader,sum(rda_total) as rda_total
					--			from ctl_doc C
		 		--					inner join document_odc O on C.ID=O.RDA_ID
					--				where 
					--					C.tipodoc = 'ODC' and C.jumpcheck <> 'STORNATO' and C.statofunzionale in ('Inviato','InApprove','Accettato')
					--		group by C.Linkeddoc
					--) OC on OC.IdHeader=CV.id

					(	select C.Linkeddoc as IdHeader ,NumeroLotto,
								case when TipoImporto = 'ivainclusa'
									then  isnull( sum ( qty*valoreeconomico + isnull(ValoreAccessorioTecnico,0)/ ( 1.00 + aliquotaiva/100) ) , 0)   
									else  sum ( qty*valoreeconomico + isnull(ValoreAccessorioTecnico,0) )  
									end
									as rda_total  --sum (qty*valoreeconomico) as rda_total 

								from ctl_doc C 
										inner join  document_microlotti_dettagli O on C.id=O.IdHeader
										inner join document_convenzione co on co.id = C.Linkeddoc -- dalla convenzione recupera tipoimporto e aliquotaiva

									where C.tipodoc = 'ODC' and C.jumpcheck = 'IMPEGNATO' and C.statofunzionale in ('Inviato','InApprove','Accettato') and c.deleted = 0 
									--where C.tipodoc = 'ODC' and C.jumpcheck <> 'STORNATO' and C.statofunzionale in ('Inviato','InApprove','Accettato') and c.deleted = 0 
						group by C.Linkeddoc,numerolotto , TipoImporto	
					) OC on OC.IdHeader=CV.id and OC.NumeroLotto=CL.NumeroLotto



GO
