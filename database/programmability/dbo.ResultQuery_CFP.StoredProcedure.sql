USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ResultQuery_CFP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procedure [dbo].[ResultQuery_CFP] (@Scelta char(1))
as 
   /*
	autore: Albanese Michele
	data:   2004-04-16
	c=configurazione   
	f =fields
	p=processi
   */
   if @scelta not in ('c','f','p')	 
			goto err
   if @scelta = 'c' 
		begin 
			---------
			--query 1 
			---------
			select document,companytab,companyarea,mpmodelli,dizionarioattributi,
				      functions_area,tabprops,functions_tab,functions_doc
			from (
			select 1 'join' ,cast(dcmisubtype as varchar(10))+' - '+dcmdescription document,
			       cast(ct.idct as varchar(10))+' - '+cttabname companytab,
			       cast(ca.idca as varchar(10))+' - '+caareaname companyarea,
			       cast(idmpmod as varchar(10))+' - '+mpmdesc mpmodelli,
			       cast(iddzt as varchar(10))+' - '+dztnome dizionarioattributi,'' functions_area,'' tabprops,'' functions_tab,'' functions_doc
			from document d ,companytab ct,companyarea ca,mpmodelli m,mpmodelliattributi mp,dizionarioattributi dz
			where (d.dcmitype = ct.ctitype  and  d.dcmisubtype = ct.ctisubtype)  and 
			       ct.idct = ca.caidct  and ca.caidmpmod = m.idmpmod and 
			       m.idmpmod = mp.mpmaidmpmod and mp.mpmaiddzt = dz.iddzt and 
			       dcmdeleted = 0 and ctdeleted = 0 and cadeleted = 0 and mpmdeleted= 0 and mpmadeleted =0 and dztdeleted = 0
			union all 
			select 2 'join',cast(dcmisubtype as varchar(10))+' - '+dcmdescription document, 
				cast(ct.idct as varchar(10))+' - '+cttabname companytab,
			        cast(ca.idca as varchar(10))+' - '+caareaname companyarea,'','',
				cast(idfnc as varchar(10))+' - '+fnccommand+' - '+fncparam,
				'','','' 
			from document d ,companytab ct,companyarea ca,functionsgroups fg,functions f
			where (d.dcmitype = ct.ctitype  and  d.dcmisubtype = ct.ctisubtype)  and 
			       ct.idct = ca.caidct and ca.caidgrp = fg.idgrp and fg.idgrp = f.fncidgrp and 
			       dcmdeleted = 0 and ctdeleted = 0 and cadeleted = 0  and fncdeleted = 0 and grpdeleted = 0
			union all
			select 3 'join',cast(dcmisubtype as varchar(10))+' - '+dcmdescription document, 
				cast(ct.idct as varchar(10))+' - '+cttabname companytab,
				'','','','',cast(idtp as varchar(10))+' - '+tpattrib+' - '+tpvalue,'',''
			from document d ,companytab ct,tabprops ps
			where (d.dcmitype = ct.ctitype  and  d.dcmisubtype = ct.ctisubtype) and 
			      ct.idct =  ps.tpidct and dcmdeleted = 0 and ctdeleted = 0 and tpdeleted = 0
			union all
			select 4 'join',cast(dcmisubtype as varchar(10))+' - '+dcmdescription document, 
				cast(ct.idct as varchar(10))+' - '+cttabname companytab,
				'','','','','',cast(idfnc as varchar(10))+' - '+fnccommand+' - '+fncparam,'' 
			from document d ,companytab ct,functionsgroups fg,functions f
			where (d.dcmitype = ct.ctitype  and  d.dcmisubtype = ct.ctisubtype) and 
				ct.ctidgrp = fg.idgrp and fg.idgrp = f.fncidgrp and 
				dcmdeleted = 0 and ctdeleted = 0 and fncdeleted = 0 and grpdeleted = 0
			union all 
			select 5 'join','','','','','','','','',cast(idfnc as varchar(10))+' - '+fnccommand+' - '+fncparam
			from document d,functionsgroups fg,functions f
			where d.dcmidgrp = fg.idgrp and fg.idgrp = f.fncidgrp and 
			      dcmdeleted = 0 and fncdeleted = 0 and grpdeleted = 0   
				) x 
			order by [join],document,companytab,companyarea,mpmodelli,dizionarioattributi,
				      functions_area,tabprops,functions_tab,functions_doc
		end 
	else if @scelta = 'f' 
		begin
			---------
			--query 2 
			---------
			select cast(dcmisubtype as varchar(10))+' - '+dcmdescription document,
			       cast(m.mpifISubTypeDest as varchar(10))+' - '+mpifFieldNameSource+' - '+mpifFieldNameDest MPInheritFields,
			       dfFieldName DocumentFields 	 
			from document d,MPInheritFields m,DocumentFields df
			where d.dcmIType = mpifITypeSource and d.dcmIsubType = mpifISubTypeSource and d.dcmitype = df.dfIType and d.dcmIsubType = dfISubtype
				and dcmdeleted = 0 and mpifdeleted = 0 
			order by document,MPInheritFields,DocumentFields
		end 
	else if @scelta = 'p'
		begin
			---------
			--query 3 
			---------
			select  cast(dcmisubtype as varchar(10))+' - '+dcmdescription document,
				cast(pp.idpa as varchar(10))+' - '+pp.prpattrib+' - '+pp.prpvalue actionprop,
				cast(pp.idact as varchar(10))+' - '+pp.actprogid actions,cast(panag.IdProcess as varchar(10))+ ' - '+ panag.descr processanag
			from document d,process p,(select ap.idpa,ap.prpattrib,ap.prpvalue,a.idact,a.actprogid,pa.idprocess
						   from actions a,processactions pa,actionprop ap 
						   where a.idact = pa.idact and pa.idpa = ap.idpa) pp,processanag panag
			where d.dcmitype = p.prcITypeSource and d.dcmisubtype = p.prcISubtypeSource  and 
			       p.prcidprocess = pp.idprocess and p.prcidprocess = panag.IdProcess and d.dcmdeleted = 0 
			order by document,actionprop,actions,processanag		
		end 
	goto ext	
	err:
		raiserror ('Errore Parametro deve essere c-f-p',16,1)
	ext:
GO
