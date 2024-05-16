USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_TS_GET_RDA_WINNER_ALYANTE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_TS_GET_RDA_WINNER_ALYANTE] ( @idDoc int , @IdUser int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @IdPdaOff int
	declare @NumLotto int
	declare @IdPda int
	declare @IdRdo int
	declare @IdRDA int
	declare @IdOff int
	declare @IdAziForn int
	declare @IdAziBuyer int

	declare @strHead varchar(100)
	declare @strEnd varchar(100)

	--set @strHead = '<DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql">'
	--set @strEnd = '</DataSet>'
	set @strHead = '<AFLINK>'
	set @strEnd = '</AFLINK>'

	-- legge id della Document_PDA_OFFERTE e lotto
	select @IdPdaOff=IdHeader ,@NumLotto=NumeroLotto  from Document_MicroLotti_Dettagli with (nolock) where id = @idDoc

	-- legge id della PDA e offerta
	select @IdPda=IdHeader,@IdOff=idmsg,@IdAziForn=idAziPartecipante   from Document_PDA_OFFERTE with (nolock) where idrow = @IdPdaOff

	-- legge id della RDO
	select @IdRdo=linkeddoc from ctl_doc with (nolock) where id = @IdPda and TipoDoc = 'PDA_MICROLOTTI'

	-- legge id della RDA
	select @IdRDA=linkeddoc,@IdAziBuyer = azienda from ctl_doc with (nolock) where id = @IdRdo and TipoDoc = 'BANDO_GARA' and JumpCheck = 'FROM_RDA'


	--- SELECT CHE RITORNA I DATI FINALI COME RS 'Name', 'Value'


	--<DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><Company CompanyId="0" MnemonicId="AF_LINK|08032310156" Description="GARC S.p.A." CodeStructureType="Nested"/></DataSet>
	--dati buyer
	select 'Company' as 'Name', @strHead + ( 
									select 0 as 'CompanyId', 'AF_LINK|' + vatvalore_ft as 'MnemonicId', aziRagioneSociale as 'Description', 'Nested' as 'CodeStructureType'
										from 
											(
											select * from aziende with (nolock)
												inner join DM_Attributi with (nolock) on idapp=1 and lnk=idazi and dztNome = 'codicefiscale'
													where idazi = @IdAziBuyer
											) as Company 	for xml auto
								) + @strEnd as 'Value'


	union
	--<DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><Nominative CompanyId="0" NominativeId="0" IsCustomer="0" MnemonicId="AF_LINK" Description="COVER.TECH SRL" FiscalCode="03194070367         " /></DataSet>
	--dati fornitore
	select 'Nominative' as 'Name', @strHead + ( 
									select 0 as 'CompanyId', 0 as 'NominativeId', 'False' as 'IsCustomer', 'AF_LINK' as 'MnemonicId', aziRagioneSociale as 'Description', vatValore_FT  as 'FiscalCode'
										from 
											(
											select * from aziende with (nolock)
												inner join DM_Attributi with (nolock) on idapp=1 and lnk=idazi and dztNome = 'codicefiscale'
													where idazi = @IdAziForn 
											) as Nominative 	for xml auto
								) + @strEnd as 'Value'

	union
	-- righe rda
	-- <DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><PurchaseRequestMeasurement CompanyId="0" ProjectId="METEL" PurchaseRequestId="202100000896" PurchaseRequestMeasurement="1" WorkBreakdownElementId="METEL-01" CatalogType="MAG" CatalogId="" ProductParentId="" ProductId="ZUM70437607" CatalogProjectId="" DeliveryDate="2021-07-30T00:00:00" Amount="15300.00" DescriptionText="" Quantity="12.000" Discount1="0.000" Discount2="0.000" Discount3="0.000" Discoun4="0.000" NetPrice="1275.00000000000000000" /><PurchaseRequestMeasurement CompanyId="0" ProjectId="METEL" PurchaseRequestId="202100000896" PurchaseRequestMeasurement="2" WorkBreakdownElementId="METEL" CatalogType="MAG" CatalogId="" ProductParentId="" ProductId="00015" CatalogProjectId="" DeliveryDate="2021-09-30T00:00:00" Amount="72000.00" DescriptionText="" Quantity="50.000" NetPrice="1440.00000000000000000"  /></DataSet>
	--select a.*,b.*,x.* from document_pr a with (nolock)
	select 'PurchaseRequestMeasurement' as 'Name', @strHead + (
						select 0 as 'CompanyId',ProjectId as 'ProjectId',numerodocumento as 'PurchaseRequestId',PurchaseRequestMeasurementId as 'PurchaseRequestMeasurement',
								 ERPWorkBreakdownElementId as 'WorkBreakdownElementId', CatalogType as 'CatalogType',CatalogId as 'CatalogId',ProductParentId as 'ProductParentId',
								 ProductId as 'ProductId',CatalogProjectId as 'CatalogProjectId', DeliveryDate as 'DeliveryDate',ltrim(str(PrezzoUnitario*Quantita,15,2)) as 'Amount',
								 DescriptionText as 'DescriptionText',ltrim(str(Quantita,14,3)) as 'Quantity',0 as 'Discount1',0 as 'Discount2',0 as 'Discount3',0 as 'Discount4',
								 ltrim(str(PrezzoUnitario,17,6)) as 'NetPrice',ERPProductId as 'ReferenceProductId'
								 from 
										(
											select isnull(ProjectId,'') as ProjectId ,isnull(ERPProjectId,'') as ERPProjectId ,
													isnull(PurchaseRequestMeasurementId,'') as PurchaseRequestMeasurementId,
													isnull(ERPWorkBreakdownElementId,'') as ERPWorkBreakdownElementId , isnull(CatalogType,'') as CatalogType ,
													isnull(CatalogId,'') as CatalogId ,isnull(ProductParentId,'') as ProductParentId ,
													isnull(ProductId,'') as ProductId ,isnull(CatalogProjectId,'') as CatalogProjectId , 
													isnull(DeliveryDate,'') as DeliveryDate ,isnull(x.PREZZO_OFFERTO_PER_UM,0) as PrezzoUnitario,
													isnull(Quantita,0) as Quantita,isnull(DescriptionText,'') as DescriptionText ,
													isnull(numerodocumento,'') as numerodocumento,
													isnull(ERPProductId,'') as ERPProductId 
														from document_pr a with (nolock)
															inner join document_pr_product b with (nolock) on a.idheader = b.idheader 
															inner join ctl_doc c with (nolock) on c.id = a.idheader and c.TipoDoc = 'PURCHASE_REQUEST'
															inner join Document_MicroLotti_Dettagli x with (nolock) on x.TipoDoc = 'PDA_OFFERTE' and x.IdHeader = @IdPdaOff
																															and x.NumeroLotto = @NumLotto and x.Voce <> 0
																															and b.ProductId = x.CodiceProdotto
													where c.id = @IdRDA 
										) as PurchaseRequestMeasurement 	for xml auto

									) + @strEnd as 'Value'

		union
		-- testata rda
		--<DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><PurchaseRequest CompanyId="0" ProjectId="METEL" PurchaseRequestId="202100000896" GenerationDate="2021-06-24T00:00:00" NominativeId="0" CurrencyId="EURO" DocumentTypeId="22" DeliveryDate="" Notes="NOTE INTERNE" /></DataSet>
		select 'PurchaseRequest' as 'Name', @strHead + (
				select 0 as 'CompanyId',isnull(ProjectId,'') as 'ProjectId',isnull(NumeroDocumento,'') as 'PurchaseRequestId',
										Data as 'GenerationDate',0 as 'NominativeId',
										'EURO' as 'CurrencyId',isnull(DocumentTypeId ,'' ) as 'DocumentTypeId',deliverydate as 'DeliveryDate',
										isnull(Note ,'') as 'Notes',
										'CPM' as 'Applicant','PurchaseOrder' as 'PurchaseRequestType','Added' as 'EntityState'

										
										 from 
												(
													select a.*,pp1.deliverydate,c.data,c.Note,c.NumeroDocumento  from document_pr a with (nolock)
														inner join ctl_doc c with (nolock) on c.id = a.idheader and c.TipoDoc = 'PURCHASE_REQUEST'
														inner join (
																		select min(idrow) as minidrow,idheader as myidheader
																			from document_pr_product with (nolock)
																				group by idheader
																	) zzz on zzz.myidheader = c.id
														inner join document_pr_product pp1 with (nolock) on pp1.idRow = zzz.minidrow and pp1.idheader = c.id
															where c.id = @IdRDA 

												) as PurchaseRequest 	for xml auto

														) + @strEnd as 'Value'

					
		union
		-- Project
		--<DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><Project CompanyId="0" ProjectId="METEL" Description="COMMESSA PER LISTINO METEL" /></DataSet>
		select 'Project' as 'Name', @strHead + (
				select 0 as 'CompanyId',isnull(ProjectId,'') as 'ProjectId',isnull(ProjectDescription ,'') as 'Description'
										
										 from 
												(
													select * from document_pr a with (nolock)
														inner join ctl_doc c with (nolock) on c.id = a.idheader and c.TipoDoc = 'PURCHASE_REQUEST'
															where c.id = @IdRDA 

												) as Project 	for xml auto

														) + @strEnd as 'Value'
	
	union
	-- Product
	-- <DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><Product CompanyId="0" CatalogType="MAG" CatalogProjectId="" CatalogId="" ProductId="ZUM70437607" ProductParentId="" Description="ECOOS ID V SET 1000" UnitId="NR"/><Product CompanyId="0" CatalogType="MAG" CatalogProjectId="" CatalogId="" ProductId="00015" ProductParentId="" Description="AUTOTRENO GRU VG" UnitId="NR"/></DataSet>
	--select a.*,b.*,x.* from document_pr a with (nolock)
	select 'Product' as 'Name', @strHead + (
						select 0 as 'CompanyId',CatalogType as 'CatalogType',CatalogProjectId as 'CatalogProjectId',CatalogId as 'CatalogId',
								ProductId as 'ProductId',ProductParentId as 'ProductParentId',ProductDescription as 'Description',UnitId as 'UnitId',
								ERPProductId as 'ReferenceProductId'
						
						
								 from 
										(
											select isnull(ProjectId,'') as ProjectId ,isnull(ERPProjectId,'') as ERPProjectId ,
													isnull(PurchaseRequestMeasurementId,'') as PurchaseRequestMeasurementId,
													isnull(ERPWorkBreakdownElementId,'') as ERPWorkBreakdownElementId , isnull(CatalogType,'') as CatalogType ,
													isnull(CatalogId,'') as CatalogId ,isnull(ProductParentId,'') as ProductParentId ,
													isnull(ProductId,'') as ProductId ,isnull(CatalogProjectId,'') as CatalogProjectId , 
													isnull(DeliveryDate,'') as DeliveryDate ,isnull(x.PREZZO_OFFERTO_PER_UM,0) as PrezzoUnitario,
													isnull(Quantita,0) as Quantita,isnull(DescriptionText,'') as DescriptionText ,
													isnull(ProductDescription,'') as ProductDescription,isnull(ProductUnitId,'') as UnitId,
													isnull(ERPProductId,'') as ERPProductId 
														from document_pr a with (nolock)
															inner join document_pr_product b with (nolock) on a.idheader = b.idheader 
															inner join ctl_doc c with (nolock) on c.id = a.idheader and c.TipoDoc = 'PURCHASE_REQUEST'
															inner join Document_MicroLotti_Dettagli x with (nolock) on x.TipoDoc = 'PDA_OFFERTE' and x.IdHeader = @IdPdaOff
																															and x.NumeroLotto = @NumLotto and x.Voce <> 0
																															and b.ProductId = x.CodiceProdotto
													where c.id = @IdRDA 
										) as Product 	for xml auto

									) + @strEnd as 'Value'

	
	union
	-- WorkBreakdownElement
	-- <DataSet xmlns:sql="urn:schemas-microsoft-com:xml-sql"><WorkBreakdownElement CompanyId="0" ProjectId="METEL" WorkBreakdownElementId="METEL-01" Description="NODO 01 METEL" NodeTypeId=""/><WorkBreakdownElement CompanyId="0" ProjectId="METEL" WorkBreakdownElementId="METEL" MnemonicId="METEL" Description="COMMESSA PER LISTINO METEL" ParentId=" " NodeTypeId=""/></DataSet>
	--select a.*,b.*,x.* from document_pr a with (nolock)
	select  'WorkBreakdownElement' as 'Name', @strHead + (
						select 0 as 'CompanyId',ProjectId as 'ProjectId',ERPWorkBreakdownElementId as 'WorkBreakdownElementId',
								ProjectDescription as 'Description',NodeTypeId as 'NodeTypeId'				
												
								 from 
										(
											--select  isnull(ProjectId,'') as ProjectId ,isnull(ERPProjectId,'') as ERPProjectId ,
											--		isnull(PurchaseRequestMeasurementId,'') as PurchaseRequestMeasurementId,
											--		isnull(ERPWorkBreakdownElementId,'') as ERPWorkBreakdownElementId , isnull(CatalogType,'') as CatalogType ,
											--		isnull(CatalogId,'') as CatalogId ,isnull(ProductParentId,'') as ProductParentId ,
											--		isnull(ProductId,'') as ProductId ,isnull(CatalogProjectId,'') as CatalogProjectId , 
											--		isnull(DeliveryDate,'') as DeliveryDate ,isnull(x.PREZZO_OFFERTO_PER_UM,0) as PrezzoUnitario,
											--		isnull(Quantita,0) as Quantita,isnull(DescriptionText,'') as DescriptionText ,
											--		isnull(ProductDescription,'') as ProductDescription,isnull(ProductUnitId,'') as UnitId,
											--		isnull(ProjectDescription,'') as ProjectDescription,
											--		isnull(NodeTypeId ,'') as NodeTypeId
											select distinct isnull(ProjectId,'') as ProjectId ,
															isnull(ERPWorkBreakdownElementId,'') as ERPWorkBreakdownElementId,
															isnull(ProjectDescription,'') as ProjectDescription,
															isnull(NodeTypeId ,'') as NodeTypeId

														from document_pr a with (nolock)
															inner join document_pr_product b with (nolock) on a.idheader = b.idheader 
															inner join ctl_doc c with (nolock) on c.id = a.idheader and c.TipoDoc = 'PURCHASE_REQUEST'
															inner join Document_MicroLotti_Dettagli x with (nolock) on x.TipoDoc = 'PDA_OFFERTE' and x.IdHeader = @IdPdaOff
																															and x.NumeroLotto = @NumLotto and x.Voce <> 0
																															and b.ProductId = x.CodiceProdotto
													where c.id = @IdRDA 
										) as WorkBreakdownElement 	for xml auto

									) + @strEnd as 'Value'


	/*

	select * from document_pr_product
	--- legge i prodotti
	select   * from Document_MicroLotti_Dettagli with (nolock)
		where TipoDoc = 'PDA_OFFERTE'
		and IdHeader = 16
		and NumeroLotto = 1
		and Voce <> 0

	select * from document_pr_product

	select * from ctl_doc where id = 83567

	select * from Document_MicroLotti_Dettagli 
	where IdHeader = 16
	and TipoDoc = 'PDA_OFFERTE'
	--and Graduatoria = 0
	order by id

	select * from aziende where idazi=35152033

	select * from Document_MicroLotti_Dettagli 
	where TipoDoc = 'PDA_OFFERTE'
	and IdHeader = 16
	and NumeroLotto = 1
	and Voce <> 0

	select * from Document_PDA_OFFERTE
	order by 1 desc

-- Per capire da quali campi prendere i dati è stato usato come esempio il modello configurato sulla 062 "Modello di acquisto per le RdA di beni e servizi provenienti da CPM"

	select 	isnull(prp.PurchaseRequestMeasurementId,0) as PurchaseRequestMeasurementId,
			isnull(prp.ProductId,'') as ProductId ,
			isnull(m.Quantita,0) as Quantity,
			m.DATA_CONSEGNA as DeliveryDate,
			isnull(prp.DescriptionText,'') as DescriptionText,
			isnull(m.PREZZO_OFFERTO_PER_UM,0) as UnitCost			
		from CTL_DOC a with(nolock) -- documento di offerta
				inner join Document_MicroLotti_Dettagli m with(nolock) on m.IdHeader = a.Id and m.TipoDoc = a.TipoDoc
				inner join CTL_DOC b with(nolock) on b.Id = a.LinkedDoc and b.TipoDoc = 'BANDO_GARA' --RDO
				inner join CTL_DOC c with(nolock) on c.Id = b.LinkedDoc and c.TipoDoc = 'PURCHASE_REQUEST' --RDA
				--inner join document_pr pr with(nolock) on pr.idheader = c.id
				inner join document_pr_product prp with(nolock) on prp.idheader = c.id and prp.ProductId = m.CodiceProdotto
		where a.Id = @idDoc
				
		*/


END






GO
