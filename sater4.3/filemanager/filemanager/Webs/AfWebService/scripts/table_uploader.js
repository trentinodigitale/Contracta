
//<%=clng(application("AVVISO_SESSIONE_MINUTI"))-1%>;
var applicationroot = null;
function initgriduploader(applicationroot_sys, UploadServiceRotoUrl_sys, sizeAttach, estensioniUpload) {
   
    if (sizeAttach != '' || sizeAttach != null)
    {
        sizeAttach = sizeAttach + 'mb'
    }
    
        UploadServiceRootUrl = UploadServiceRotoUrl_sys;
        applicationroot = applicationroot_sys;

        $("div.DIV_ATTACH_CONTAINER:not(.initialized)").each(function (i, maincontainer) {
            var maincontainerid = $(maincontainer).attr("id");
            var abutton = $(maincontainer).find("input.Attach_button");
            var buttonlink = $(abutton).attr("onclick");
			var left_conteiner = PosLeft(getObj(maincontainerid).parentNode);			
			var top_conteiner = PosTop(getObj(maincontainerid).parentNode);	
            var tmpMlg = CNV(pathRoot, 'DRAG FILE HERE');
            
			var table_grid_id = $(maincontainer).parent().closest(".Grid").attr('id');           
            
            //var res = preparecellupload('BB4CCC04-D054-4B66-ABB5-0266045CAF9A', buttonlink);
            var dragid = getrandom();
            
            //variabile che identifica se il documento è in read only
            var irReadOnly = 0;

            //ottengo la format della griglia
            var replace_maincontainer = maincontainerid.replace('DIV_', '') + '_V_BTN';
            var btn_maincontainer = "";
            var strPatternFormat = "";
            try
            {
                btn_maincontainer = getObj(replace_maincontainer).parentElement;
            }
            catch
            {
                btn_maincontainer = '';
            }
            //var btn_maincontainer = getObj(replace_maincontainer).parentElement;
            if (btn_maincontainer != "")
            {          
                var onclick = btn_maincontainer.innerHTML;
                var nposStartFormat = onclick.indexOf('&amp;FORMAT=');
                var strOnclick = onclick.substring(nposStartFormat+12, nposStartFormat+100);
                var nposEndParametri = strOnclick.indexOf('\' ');
                var nposEndFormat = strOnclick.indexOf('&amp;');
                if (nposEndFormat == -1)
                {
                    nposEndFormat = nposEndParametri
                }
                var strHeadFormat =  strOnclick.substring(0 , nposEndFormat);
                strPatternFormat = decodeURI(strHeadFormat);
		    }
            
            if (!strPatternFormat.includes('M') && strPatternFormat != "")
            {
                //area posizionale
                if (table_grid_id == undefined)
                {
                    $(maincontainer).parent().append("<div id='" + dragid + "' class='celluploadoverlay_testata'>"+ tmpMlg +"</div>");          
                }
                else //area griglia
                {
                    $(maincontainer).parent().append("<div id='" + dragid + "' class='celluploadoverlay'>"+ tmpMlg +"</div>");   
                }
                
                getObj(dragid).style.left=left_conteiner;
                getObj(dragid).style.top=top_conteiner;
                //IF PER CAPIRE SE SONO SULLE GRIGLIE ELSE SONO SULLA CAPTION
                if ( getObj(maincontainerid).parentNode.offsetWidth <= 0)
                {
                    getObj(dragid).style.width="calc(100% + 0px)";
                }
                else
                {
                    getObj(dragid).style.width=getObj(maincontainerid).parentNode.offsetWidth  + "px";
                }
                
                getObj(dragid).style.height=getObj(maincontainerid).parentNode.style.height;
                //+ res.pid,
                var fuploader = createTableUploader(buttonlink, dragid, maincontainerid, UploadServiceRootUrl + "chunkupload/1.0/?pid=", 'pdf', sizeAttach, null, 'Uploading...', table_grid_id);
                fuploader.init();


                //SET EFFECTS
                //DRAG OVERLAY SECTION

                if (table_grid_id != undefined)
                {
                    $(maincontainer).on("dragenter", function () {
                        $(this).parent().find(".celluploadoverlay").addClass("active");
                    });

                    $(maincontainer).parent().find(".celluploadoverlay").on("dragenter", function () {
                        $(this).addClass("active");
                    });

                    $(maincontainer).parent().find(".celluploadoverlay").on("dragleave", function () {
                        $(this).removeClass("active");
                    });

                    $(maincontainer).parent().find(".celluploadoverlay").on("drop", function (evt) {
                        evt.preventDefault();
                    });  
                }
                else
                {
                    $(maincontainer).on("dragenter", function () {
                        $(this).parent().find(".celluploadoverlay_testata").addClass("active");
                    });

                    $(maincontainer).parent().find(".celluploadoverlay_testata").on("dragenter", function () {
                        $(this).addClass("active");
                    });

                    $(maincontainer).parent().find(".celluploadoverlay_testata").on("dragleave", function () {
                        $(this).removeClass("active");
                    });

                    $(maincontainer).parent().find(".celluploadoverlay_testata").on("drop", function (evt) {
                        evt.preventDefault();
                    });
                }


                $(maincontainer).addClass("initialized");
            }

           

        });

}


//initgriduploader();

