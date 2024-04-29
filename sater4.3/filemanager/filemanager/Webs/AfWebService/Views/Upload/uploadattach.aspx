<%@ Page Title="" Language="VB"  Inherits="System.Web.Mvc.ViewPage" %>
<%="" %>

 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title>Files Uploader</title>

        <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" /> <!--EDGE è per IE10+ -->
		
		<link rel="stylesheet"  href="../../assets/style.css?nid=<%=Guid.NewGuid.ToString%>"/>
		
		<!--per funzionamento modale-->
		<link rel="stylesheet"  href="../../assets/jquery-ui.css?nid=<%=Guid.NewGuid.ToString%>"/>
		
		<script src="..<%=Model.virtualdirapp%>/ctl_library/JScript/ExecFunction.js?v=<%=Guid.NewGuid.ToString%>" type="text/javascript"></script>		
		<script src="..<%=Model.virtualdirapp%>/ctl_library/JScript/main.js?v=<%=Guid.NewGuid.ToString%>" type="text/javascript"></script>
		
		<script src="..<%=Model.virtualdirapp%>/ctl_library/JScript/field/ck_attach.js?v=<%=Guid.NewGuid.ToString%>" type="text/javascript"></script>
		
		<script src="js/jquery/jquery-3.6.0.min.js?nid=<%=Guid.NewGuid.ToString%>"></script>
		
        <script src="scripts/aftoolkit.js?nid=<%=Guid.NewGuid.ToString%>"></script>
        <script src="js/plupload/js/plupload.full.min.js?nid=<%=Guid.NewGuid.ToString%>"></script>
        <script src="js/plupload/js/i18n/it.js"></script>
        
		
		<!--per funzionamento modale-->
		<script src="js/jquery/jquery-ui.min.js?v=<%=Guid.NewGuid.ToString%>" type="text/javascript"></script>
		
		
        <script>
            var ml_alert_maxsizefilename = '<%=Replace(CTLDB.DatabaseManager.gettranslation(Model.language, "Attenzione, il nome del file selezionato supera il limite di X caratteri definito nel sistema, per proseguire e' necessario rinominare il file prima di selezionarlo"), "'", "\'")%>';
            var param_maxsizefilename = '<%=Replace(CTLDB.DatabaseManager.gettranslation(Model.language, "PROP.Upload.file.MAX_FILE_NAME"), "'", "\'")%>';
            var applicationroot = '<%=Model.virtualdirapp%>';
        </script>

    </head>


    <body id="drop_panel_id">

        <input type="hidden" value="<%=Model.format%>" id="format" />
        <input type="hidden" value="<%=Model.techvalue%>" id="tech_value"/>
        <input type="hidden" value="<%=Model.virtualdirapp%>" id="virtualdirapp"/>
        <input type="hidden" value="<%=Model.path%>" id="path"/>
		<input type="hidden" value="<%=Model.fieldid%>" id="fieldid"/>
		
	
		
        <div class="uploaderoverlay">
    	    <p class="DragIcon"><%=CTLDB.DatabaseManager.gettranslation(Model.language, "Rilascia il file per procedere al caricamento")%></p>
        </div>

        <%If Not String.IsNullOrWhiteSpace(Model.postpage) %>
            <form id="form_post_upload" enctype="multipart/form-data" action="<%=Model.postpage%>" method="POST">                
                <input id="post_upload_file" type="file" name="file" style="display:none;" accept="<%=Model.postpage

#End ExternalSource

#ExternalSource ("E:\.NET\FileManager\Webs\AfWebService\Views\Upload\uploadattach.aspx", 32)
                    __o = Model.fileextensions%>" />
            </form>
        <%End If %>

        <div id="selector_area" class="SelectFile">    
            
             <%if Model.certification_req_33215 = "0" And Model.showextensions %>

    	        <p>
                    <%=CTLDB.DatabaseManager.gettranslation(Model.language,"Selezionare un file tra le seguenti estensioni ammesse")%>:
	            </p>
                <p class="EstensioniAmmesse"><span id="extensions"><%:Model.fileextensions%></span></p>

             <%End if %>

           <%-- <%If Model.showextensions %>
            
                 <%if Model.certification_req_33215 = "0" %>

    	            <p>
                        <%=CTLDB.DatabaseManager.gettranslation(Model.language,"Selezionare un file tra le seguenti estensioni ammesse")%>:
	                </p>
                    <p class="EstensioniAmmesse"><span id="extensions"><%:Model.fileextensions%></span></p>

                <%End if %>

            <%End if %>--%>

    	    <p>
	            <a id="uploader_button"><%=CTLDB.DatabaseManager.gettranslation(Model.language, "Selezionare un file tra le seguenti estensioni ammesse")%></a>
                <span class="DragDrop" id="DragIcon"><%=Model.language, "Trascina qui il tuo file")%></span>
                
				<%'--if not String.IsNullOrWhiteSpace(Model.clearvalue)%>
				   <a onclick="set_clear_value(this);" id="clear_button" >
                        <%=CTLDB.DatabaseManager.gettranslation(Model.language,"Pulisci Selezione")%>
                    </a>                
                <%'--End If %>
	        </p>
            <table class="MsgTable">
        	    <tbody>
            	    <tr>
                	    <th class="Warning"><img src="assets/img/3.png" /></th>
                        <td class="Message">
                          <%  
						  
						  Dim GiroFirma = Model.GiroFirma
						  
						  Dim StrKey_DescUpload = "Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione del file"
						  
						  if not String.IsNullOrWhiteSpace(Model.format)  Then
								  
								  
                                  Dim strFormatLocal = Model.format.ToString.ToUpper
                                  Dim ainfo = strFormatLocal.split("EXT:")
								  
								  		  
                                  'If ainfo(0).Contains("B") or GiroFirma = "1" Then
                                  '    Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, "Il file richiesto deve essere con firma digitale"))
									  
                                  'End If
								  
								  
								 
  								  If ainfo(0).Contains("B") or GiroFirma = "1" Then
									StrKey_DescUpload = "info firma Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione del file"
							      End if
								  
								  Dim StrKey_DescMultiUpload = "Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione dei file multivalore"
								  
								  If ainfo(0).Contains("B") or GiroFirma = "1" Then
									StrKey_DescMultiUpload = "info firma Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione dei file multivalore"
							      End if
									  
									  
                                  If ainfo(0).Contains("M") Then
									  
                                      Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, StrKey_DescMultiUpload ))
                                  Else
								      
                                      Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, StrKey_DescUpload))
                                  End If
								  
                              else
							  
								  If GiroFirma = "1" Then
									StrKey_DescUpload = "info firma Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione del file"
							      End if
								  
								  Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, StrKey_DescUpload ))
								  
                              end if
                         %>
                        </td>
                    </tr>
                </tbody>
            </table>
			
            <%if Model.certification_req_33215 = "1" and Model.showextensions %>

			    <table class="MsgTable">
        	        <tbody>
            	        <tr>
                	        <th class="Warning"><img src="assets/img/3.png" /></th>
                            <td class="Message">
                            <p>
							    <%=CTLDB.DatabaseManager.gettranslation(Model.language,"Selezionare un file tra le seguenti estensioni ammesse")%>:
						    </p>
						    <p class="EstensioniAmmesse"><span id="extensionsFile"><%:Model.fileextensions%></span></p>
                            </td>
                        </tr>
                    </tbody>
                </table>
			
            <%End if %>

        </div>
		
		<legend id="ElencoFile" class="legend_ElencoFile">
			<%=CTLDB.DatabaseManager.gettranslation(Model.language,"Elenco File")%>                     
        </legend>
		<div id="DIV_GRID_ATTACH_MULTIVALUE" class="ELENCO_FILE"></div>
		<p id="Sep_Elenco_File" class="Sep_Elenco_File">&nbsp;</p>
		<div id="finestra_modale"></div>
		
		<form id="form1" runat="server">
            <div>
                <fieldset>
                    <legend>
                        <%=CTLDB.DatabaseManager.gettranslation(Model.language, "Informazioni di Caricamento")%>                     
                    </legend>
                    <div  class="report">
                        <table class="reporting-table">
                            <tbody>
                            	<tr class="FileName">
                                    <th>
                                        <%=CTLDB.DatabaseManager.gettranslation(Model.language, "Nome File")%>:
                                    </th>
                                    <td><span id="filename"></span></td>
                                </tr>
                                <tr class="StageProgress">
                                    <th>
                                        <%=CTLDB.DatabaseManager.gettranslation(Model.language, "Avanzamento")%>
                                    </th>
                                    <td>
                                        <div class="progress-div">
                                            <div class="progress-bar">
                                                <span id="progress"></span>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                           		<tr class="UploaderIpaddress">
                                    <th>Uploader Ipaddress:</th>
                                    <td><span id="ipaddress"></span></td>
                                </tr> 
                                <tr class="TransmissionId">
                                    <th>Transmission Id:</th>
                                    <td><span id="tid"></span></td>
                                </tr>                            
                                <tr class="RemainingTime">
                                    <th><%=CTLDB.DatabaseManager.gettranslation(Model.language, "Tempo Rimanente")%>:</th>
                                    <td><span id="remaining"></span></td>
                                </tr>
                                <tr class="TotalBytes">
                                    <th>Bytes Totali:</th>
                                    <td><span id="totalbytes"></span></td>
                                </tr>
                                <tr class="SentBytes">
                                    <th>Bytes Inviati:</th>
                                    <td><span id="uploadedbytes"></span></td>
                                </tr>
                                <tr class="RemainingBytes">
                                    <th>Bytes Rimanenti:</th>
                                    <td><span id="remainingbytes"></span></td>
                                </tr>
                                <tr class="CurrentStage">
                                    <th><%=CTLDB.DatabaseManager.gettranslation(Model.language, "Stato Corrente")%>:</th>
                                    <td><span id="action"></span></td>
                                </tr>
                                <tr class="StageElapsed">
                                    <th>Stage Elapsed:</th>
                                    <td><span id="elapsed"></span></td>
                                </tr>
                                <tr class="TotalTime">
                                    <th><%=CTLDB.DatabaseManager.gettranslation(Model.language, "Tempo Totale")%>:</th>
                                    <td><span id="total_elapsed"></span></td>
                                </tr>
                                
                                <tr class="Output">
                                    <th>Output:</th>
                                    <td><span id="output"></span></td>
                                </tr>
                                <tr id="error_container" class="Error">
                                    <th>Errori:</th>
                                    <td class="tdErrorMessage"><span id="error_message"></span></td>
                                </tr>
                            </tbody>                        
                        </table>
                        
                        <div class="lock-div">
                            <span class="lock-title">
                                <%=CTLDB.DatabaseManager.gettranslation(Model.language.ToString, "Elaborazione in corso...")%>                                
                            </span>
                            <p>
                                <%=CTLDB.DatabaseManager.gettranslation(Model.language.ToString, "Attendere la fine delle operazioni prima di chiudere la pagina")%>                                 
                            </p>
                            <p>
                                <%=CTLDB.DatabaseManager.gettranslation(Model.language.ToString, "La chiusura della pagina annullerà tutte le operazioni in corso")%>                                                                 
                            </p>
                        </div>
                    </div>
                </fieldset>
            </div>
        </form>
        

        <script type="text/javascript">

            function update_progress(data, action) {
                $("#action").html(action);
                if (data == null) {
                    $("#tid").html("");
                    $("#progress").html("");
                    $(".progress-bar").css("width", "0%");
                    $("#remaining").html("");
                    $("#elapsed").html("");
                    $("#total_elapsed").html("");
                    $("#totalbytes").html("");
                    $("#uploadedbytes").html("");
                    $("#remainingbytes").html("");
                    $("#filename").html("");
                    $("#ipaddress").html("");
                    $("#pdf_content_hash").html("");
                    $("#error_message").html("");
                    $("#output").html("");


                } else {
                    $("#tid").html(data.tid);
                    $("#progress").html(data.percentage);
                    $(".progress-bar").css("width", data.percentage);
                    $("#remaining").html(data.remaining);
                    $("#elapsed").html(data.elapsed);
                    $("#total_elapsed").html(data.elapsed);
                    $("#totalbytes").html(data.totalbytes);
                    $("#uploadedbytes").html(data.uploadedbytes);
                    $("#remainingbytes").html(data.remainingbytes);
                    $("#filename").html(data.filename);
                    $("#ipaddress").html(data.ipaddress);

                }
            }


            var fuploader = null;
            var bIE = false;


            try {

                if (isIE()) {
                    bIE = true;
                }

            } catch (e) { }



            <%If Not String.IsNullOrWhiteSpace(Model.postpage)%>
            $(function () {

                $('#uploader_button').on('click', function (e) {
                    $('#post_upload_file').trigger('click');
                });

                $('#post_upload_file').on('change', function () {
                    $("#uploader_button").hide();
                    setmarquee("Operazione in corso...");
                    setTimeout(function () {
                        $("#form_post_upload").submit();
                    }, 500);
                });


                if (bIE == false) {
                    var dropContainer = document.getElementById('drop_panel_id');
                    var fileInput = document.getElementById('post_upload_file');

                    dropContainer.ondragover = dropContainer.ondragenter = function (evt) {
                        evt.preventDefault();
                    };

                    dropContainer.ondrop = function (evt) {

                        fileInput.files = evt.dataTransfer.files; //Non funziona con IE
                        evt.preventDefault();

                        document.getElementById('form_post_upload').submit();
                    };
                }
                else {
                    $("#DragIcon").hide();

                }

                //nascondo sempre il pulisci quando arriva il parametro postpage
                //prima non c'era bisogno in quanto non era proprio presente mentre adesso con la gestion emultivalore
                //è presente sempre
                $('#clear_button').hide();


            });
            <%Else%>

            //alert('enrico mettiti qui per l\'onload della pagina e per fare la griglia. la funzione JS farla qui : scripts\aftoolkit.js');
            // se format contiene M disegno la griglia
            strFormat = document.getElementById('format').value;
            //alert(document.getElementById('tech_value').value);
            if (strFormat.indexOf("M") != -1) {

                Build_Grid_Attach_Multivalue();


            }

            if (document.getElementById('tech_value').value == '') {
                $('#clear_button').hide();
            }


            // Initialize the widget when the DOM Is ready
            $(function () {
                fuploader = createuploader("uploader_button", "#selector_area", "drop_panel_id", "../chunkupload/1.0/?pid=<%:Request.QueryString("pid")%>", '<%=Model.fileextensions.Replace(";",",")%>', '<%:Model.maxsize%>', null,'<%:CTLDB.DatabaseManager.gettranslation(Model.language,"Uploading").Replace("'","\'")%>...');
                    fuploader.init();
                });
            <%End If%>


            function set_clear_value(sender) {
                do_opener_update("<%=Model.fieldid%>", "<%=Model.clearvalue%>", "", true, false, null, null);
            }



            var IsOperationProgress = false;
            window.onbeforeunload = function () {
                if (IsOperationProgress == true) {
                    return "<%=CTLDB.DatabaseManager.gettranslation(Model.language, "Seleziona file")

#End ExternalSource

#ExternalSource ("E:\.NET\FileManager\Webs\AfWebService\Views\Upload\uploadattach.aspx", 39)
            __o = CTLDB.DatabaseManager.gettranslation(Model.language, "Trascina qui il tuo file")%>";
                }
            }

            <%If Not String.IsNullOrWhiteSpace(Model.postpage)%>
            if (bIE == false) {
			<%end if%>

                //DRAG OVERLAY SECTION
                $("#drop_panel_id").on("dragenter", function () {
                    $(".uploaderoverlay").addClass("active");

                });

                $(".uploaderoverlay").on("dragenter", function () {
                    $(".uploaderoverlay").addClass("active");

                });

                $(".uploaderoverlay").on("dragleave", function () {
                    $(".uploaderoverlay").removeClass("active");

                });

            <%If Not String.IsNullOrWhiteSpace(Model.format) Then


                Dim strFormatLocal = Model.format.ToString.ToUpper
                Dim ainfo = strFormatLocal.Split("EXT:")


                'If ainfo(0).Contains("B") or GiroFirma = "1" Then
                '    Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, "Il file richiesto deve essere con firma digitale"))

                'End If



                If ainfo(0).Contains("B") Or GiroFirma = "1" Then
                    StrKey_DescUpload = "info firma Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione del file"
                End If

                Dim StrKey_DescMultiUpload = "Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione dei file multivalore"

                If ainfo(0).Contains("B") Or GiroFirma = "1" Then
                    StrKey_DescMultiUpload = "info firma Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione dei file multivalore"
                End If


                If ainfo(0).Contains("M") Then

                    Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, StrKey_DescMultiUpload))
                Else

                    Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, StrKey_DescUpload))
                End If

            Else

                If GiroFirma = "1" Then
                    StrKey_DescUpload = "info firma Premendo sul bottone ""Sfoglia..."" si apre la finestra che consente la selezione del file"
                End If

                Response.Write(CTLDB.DatabaseManager.gettranslation(Model.language, StrKey_DescUpload))

            End If


#End ExternalSource

#ExternalSource ("E:\.NET\FileManager\Webs\AfWebService\Views\Upload\uploadattach.aspx", 44)
            If Model.certification_req_33215 = "1" And Model.showextensions Then

#End ExternalSource

#ExternalSource ("E:\.NET\FileManager\Webs\AfWebService\Views\Upload\uploadattach.aspx", 45)
                __o = CTLDB.DatabaseManager.gettranslation(Model.language, "Selezionare un file tra le seguenti estensioni ammesse")%>
            }
			<%end if%>

            function isIE() {
                const ua = window.navigator.userAgent; //Check the userAgent property of the window.navigator object
                const msie = ua.indexOf('MSIE '); // IE 10 or older
                const trident = ua.indexOf('Trident/'); //IE 11

                return (msie > 0 || trident > 0);
            }

        </script>
        
        
        
        
               
    </body>
</html>
