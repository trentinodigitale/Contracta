var UploadServiceRootUrl = null;

function preparecellupload(acckey, buttonlink) {
    return getajax("proxy/1.0", "preparecellupload?acckey=" + acckey, { buttonlink: buttonlink }, function () {
        //ON ERROR
    }, null, false);
}


function GetAccessBarrier() {
    var token = null;
    $.ajax({
        type: 'GET',
        url: applicationroot + "/ctl_library/accessbarrier.asp?AJAX=1",
        async: false,
        data: {},
        success: function (result) {
            token = result;
        },
        error: null,
        cache: false
    });
    return token;
}


function getajax(action, fx, params, onerror, onsuccess, async) {
    if (async == null) {
        async = false;
    }
    var response = null;
    if (onerror == null) {
        onerror = function (xhr, ajaxOptions, thrownError) {
            response = xhr.responseText;
        };
    }

    if (onsuccess == null) {
        onsuccess = function (result) {
            response = result;
        };
    }

    var GetAjaxPostUrl = action;
    if (UploadServiceRootUrl != null) {
        GetAjaxPostUrl = UploadServiceRootUrl + action;
    }

    if (async == true) {
        return $.ajax({
            type: 'POST',
            url: GetAjaxPostUrl + "/" + fx,
            async: async,
            data: params,
            success: onsuccess,
            error: onerror,
            cache: false
        });
    } else {
        $.ajax({
            type: 'POST',
            url: GetAjaxPostUrl + "/" + fx,
            async: async,
            data: params,
            success: onsuccess,
            error: onerror,
            cache: false
        });
        if (response.gotologin == true) {
            document.location = response.loginurl;
        }
        return response;
    }
}




function getrandom() {
    var p1 = Math.floor((Math.random() * 10000000000000000) + 1);
    var p2 = Math.floor((Math.random() * 1000000000000000) + 1);
    var ret = p1.toString() + p2.toString();
    return "r" + ret;
}



//FILE UPLOADER

//buttonlink è l'href del bottone nella cella che contiene i dati da cui il sistema recupera i parametri
function createTableUploader(buttonlink, droppanelid, datapanelid, uploadurl, extensions, maxsize, afterselectioncallback, uploadingtext, table_grid_id) {
    console.log("Debug: sono in start createTableUploader");
    var progressid = getrandom();
    var oldcnt = null;

    var droppanel = $("#" + droppanelid);
    var pid = null;     //PID PER L'UPLOAD

    if (maxsize == null) {
        maxsize = '1024mb';
    }
    var fileuploader = new plupload.Uploader({
        runtimes: 'html5,flash,silverlight,html4',
        drop_element: droppanelid,
        multi_selection: false,
        url: uploadurl,
        max_file_count: 100,
        multipart: true,
        multipart_params: { 'tid': '', 'Size': 0 },
        chunk_size: '512kb',

        filters: {
            max_file_size: maxsize,
            mime_types: [
                { title: "Files", extensions: extensions }
            ]
        },
        // Flash settings
        flash_swf_url: 'js/plupload/js/js/Moxie.swf',
        // Silverlight settings
        silverlight_xap_url: 'js/plupload/js/js/Moxie.xap',
        init: {
            PostInit: function () {
                console.log("Debug: sono in PostInit di plupload.Uploader in createTableUploader");
                /*document.getElementById(buttonid).onclick = function () {
                    fileuploader.start();
                    return false;
                };*/
            },
            FilesAdded: function (up, files) {
                console.log("Debug: sono in start FilesAdded di plupload.Uploader in createTableUploader");
                if (pid == null) {
                    var abarrier = GetAccessBarrier();
                    var res = preparecellupload(abarrier, buttonlink);
                    if (res.esit == true) {
                        pid = res.pid;
                        up.settings.url = uploadurl + pid;
                    }
                }

                if (table_grid_id != undefined) {
                    //area posizionale 
                    $(droppanel).parent().find(".celluploadoverlay").removeClass("active")
                    //$(droppanel).parent().find(".celluploadoverlay").removeClass("active").addClass("disabled");
                }
                else {
                    //area griglia
                    $(droppanel).parent().find(".celluploadoverlay_testata").removeClass("active");
                    //$(droppanel).parent().find(".celluploadoverlay_testata").removeClass("active").addClass("disabled");
                }


                var datapanel = $("#" + datapanelid);
                oldcnt = $(datapanel).html();
                $(datapanel).html("<div id='" + progressid + "' class='pb-upload-cell'><div></div><label></label></div>");

                clear_error();
                var totalsize = 0;
                $(files).each(function (index, value) {
                    totalsize += value.size;
                });

                up.settings.multipart_params = { 'tid': '', 'Size': totalsize };
                if (afterselectioncallback == null) {
                    setpagelock(true);
                    up.start();
                } else {
                    afterselectioncallback(files);
                }
                console.log("Debug: sono in end FilesAdded di plupload.Uploader in createTableUploader");
            },

            ChunkUploaded: function (up, files, dataFromServer) {
                console.log("Debug: sono in start ChunkUploaded di plupload.Uploader in createTableUploader");
                dataFromServer.response = dataFromServer.response.replace('<pre>', '');
                dataFromServer.response = dataFromServer.response.replace('</pre>', '');
                var data = JSON.parse(dataFromServer.response);
                if (data.esit == true) {
                    var totalsize = 0;
                    $(files).each(function (index, value) {
                        totalsize += value.size;
                    });
                    up.settings.multipart_params = { 'tid': data.tid, 'Size': totalsize };
                }
                else {
                    alert(data.message);
                    if (table_grid_id != undefined) {
                        //area posizionale 
                        $(droppanel).parent().find(".celluploadoverlay").removeClass("active").removeClass("disabled");
                    }
                    else {
                        //area griglia
                        $(droppanel).parent().find(".celluploadoverlay_testata").removeClass("active").removeClass("disabled");
                    }
                    up.stop();
                }
                console.log("Debug: sono in end ChunkUploaded di plupload.Uploader in createTableUploader");
            },

            UploadProgress: function (up, file) {
                $("#" + progressid).find("div").css("width", file.percent + "%");
                $("#" + progressid).find("label").html("uploading...");
            },
            UploadComplete: function (up, files) {
                $("#" + progressid).find("label").html("Upload complete...");
                pid = null;
            },
            FileUploaded: function (up, files, dataFromServer) {
                console.log("Debug: sono in FileUploaded di plupload.Uploader in createTableUploader");
                up.settings.multipart_params = { 'tid': '', 'Size': 0 };
                dataFromServer.response = dataFromServer.response.replace('<pre>', '');
                dataFromServer.response = dataFromServer.response.replace('</pre>', '');
                var data = JSON.parse(dataFromServer.response);
                if (data.esit == true) {
                    RunInTablePostUpload(data.tid, progressid, oldcnt, table_grid_id);
                }
                else {
                    //showdialog("Upload Error", "Message : " + data.message);
                    alert(data.message);
                    up.stop();
                    if (table_grid_id != undefined) {
                        //area posizionale 
                        $(droppanel).parent().find(".celluploadoverlay").removeClass("active").removeClass("disabled");
                    }
                    else {
                        //area griglia
                        $(droppanel).parent().find(".celluploadoverlay_testata").removeClass("active").removeClass("disabled");
                    }
                }
            },

            Error: function (up, err) {
                pid = null;
                console.error(up, err);
                up.stop();
                alert(err.message);
                if (table_grid_id != undefined) {
                    //area posizionale 
                    $(droppanel).parent().find(".celluploadoverlay").removeClass("active").removeClass("disabled");
                }
                else {
                    //area griglia
                    $(droppanel).parent().find(".celluploadoverlay_testata").removeClass("active").removeClass("disabled");
                }
            }
        }
    });
    console.log("Debug: sono in end createTableUploader");
    return fileuploader;
}



function createuploader(buttonid, ButtonareaSelector, droppanelid, uploadurl, extensions, maxsize, afterselectioncallback, uploadingtext) {
    console.log("Debug: sono in start createuploader");
    if (maxsize == null) {
        maxsize = '1024mb';
    }

    var fileuploader = new plupload.Uploader({
        runtimes: 'html5,flash,silverlight,html4',
        browse_button: buttonid,
        drop_element: droppanelid,
        multi_selection: false,
        url: uploadurl,
        max_file_count: 100,
        multipart: true,
        multipart_params: { 'tid': '', 'Size': 0 },
        chunk_size: '512kb',

        filters: {
            max_file_size: maxsize,
            mime_types: [
                { title: "Files", extensions: extensions }
            ],
            max_file_name: param_maxsizefilename
        },
        // Flash settings
        flash_swf_url: 'js/plupload/js/js/Moxie.swf',
        // Silverlight settings
        silverlight_xap_url: 'js/plupload/js/js/Moxie.xap',
        init: {
            PostInit: function () {
                console.log("Debug: sono in PostInit di plupload.Uploader in createuploader");
                //document.getElementById(buttonid).onclick = function () {
                //    fileuploader.start();
                //    return false;
                //};
            },
            FilesAdded: function (up, files) {
                console.log("Debug: sono in start FilesAdded di plupload.Uploader in createuploader");
                $(".uploaderoverlay").removeClass("active");
                $("#" + buttonid).hide();
                if (ButtonareaSelector != null) {
                    $(ButtonareaSelector).hide();
                    $("#DIV_GRID_ATTACH_MULTIVALUE").hide();
                    $("#ElencoFile").hide();
                }
                clear_error();
                var totalsize = 0;
                $(files).each(function (index, value) {
                    totalsize += value.size;
                });

                up.settings.multipart_params = { 'tid': '', 'Size': totalsize };
                update_progress(null, uploadingtext);
                if (afterselectioncallback == null) {
                    setpagelock(true);
                    up.start();
                } else {
                    afterselectioncallback(files);
                }
            },

            ChunkUploaded: function (up, files, dataFromServer) {
                dataFromServer.response = dataFromServer.response.replace('<pre>', '');
                dataFromServer.response = dataFromServer.response.replace('</pre>', '');
                var data = JSON.parse(dataFromServer.response);
                if (data.esit == true) {
                    var totalsize = 0;
                    $(files).each(function (index, value) {
                        totalsize += value.size;
                    });
                    up.settings.multipart_params = { 'tid': data.tid, 'Size': totalsize };

                    update_progress(data, uploadingtext);

                }
                else {
                    alert(data.message);
                    $(".uploaderoverlay").removeClass("active");
                    up.stop();
                }
            },

            UploadProgress: function (up, file) {
                //$("#progress").html(file.percent + "%");
                //document.getElementById(file.id).getElementsByTagName('b')[0].innerHTML = '<span>' + file.percent + "%</span>";
            },
            UploadComplete: function (up, files) {

                // Called when all files are either uploaded or failed
                //$("#" + buttonid).html(button_html);
                //$("#" + buttonid).html("Select File");
                //$("#" + buttonid).show();
            },
            FileUploaded: function (up, files, dataFromServer) {
                up.settings.multipart_params = { 'tid': '', 'Size': 0 };
                dataFromServer.response = dataFromServer.response.replace('<pre>', '');
                dataFromServer.response = dataFromServer.response.replace('</pre>', '');
                var data = JSON.parse(dataFromServer.response);
                if (data.esit == true) {

                    update_progress(data, "Processing...");
                    RunPostUpload(data.tid, buttonid);
                }
                else {
                    //showdialog("Upload Error", "Message : " + data.message);
                    alert(data.message);
                    up.stop();
                    $(".uploaderoverlay").removeClass("active");
                }
            },

            Error: function (up, err) {
                up.stop();
                //$("#" + buttonid).show();
                //$("#" + buttonid).html(button_html);
                //showdialog("Upload Error", "Code : " + err.code + "<br/>Message : " + err.message);

                pathRoot = '..' + applicationroot + '/';

                //Gestisco il messaggio con una DMessageBox in caso di questo errore. Gli altri con alert per mancanza di ML deifniti
                if (err.message == 'Il file supera la dimensione massima consentita.')
                    DMessageBox('', err.message, 'Errore', 1, 400, 300);
                else
                    //alert(err.message);
                    DMessageBox('', 'NO_ML###' + err.message, 'Errore', 1, 400, 300);


                $(".uploaderoverlay").removeClass("active");
            }
        }
    });
    return fileuploader;
}

function RunInTablePostUpload(tid, progressid, oldcontent, table_grid_id) {
    $("#" + progressid).find("div").css("width", "0%");
    getajax("uploadservice", "postprocess", { tid: tid }, function () {
        //$("#" + buttonid).show();
        alert("ERROR");
        //$("#error_message").html("System Error");
    }, function (res) {
        if (res.esit == true) {
            //$("#action").html(res.message);
            QueJobStatusInTable(res.content, progressid, oldcontent, table_grid_id);
        } else {
            display_error(res.message, false);
        }
    }, true);

    try {
        //inizializza il DRAG_AND_DROP sugli allegati
        //self.opener.Init_DRAG_AND_DROP_Allegati();   
        // var idClassAllegati = $(oldcontent);
        // getObj(idClassAllegati).removeClass("initialized")
        // var B = $(oldcontent).attr("id");
        // $(oldcontent).removeClass("initialized");  
        // //$(oldcontent).attr("id").removeClass("initialized");  
        Init_DRAG_AND_DROP_Allegati();
    }
    catch (e) { }
}

function RunPostUpload(tid, buttonid) {
    getajax("uploadservice", "postprocess", { tid: tid }, function () {
        //$("#" + buttonid).show();
        $("#error_message").html("System Error");
    }, function (res) {
        if (res.esit == true) {
            setpagelock(true);
            $("#action").html(res.message);
            QueJobStatus(res.content, buttonid);
        } else {
            display_error(res.message, false);
        }
    }, true);
}

var qput = null;
var qxhr = null;

function setprogress(label, percentage, ismarque) {
    if (ismarque != true && mtimeout != null) {
        clearTimeout(mtimeout);
        mtimeout = null;
    }
    if (label == null || label.trim() == "") {
        label = "&nbsp;";
    }
    $("#progress").html(label);
    $(".progress-bar").css("width", percentage + "%");
    //if (ismarque != true && percentage == 100) {
    //    setmarquee(label, 0, "up");
    //}
}

var mtimeout = null;
function setmarquee(label, current, direction) {
    if (current == null) {
        current = 0;
        direction = "up";
    } else if (current == 0) {
        direction = "up";
    } else if (current == 100) {
        direction = "down";
    }
    setprogress(label, current.toString(), true);
    if (direction == "down") {
        current -= 1;
    } else {
        current += 1;
    }
    mtimeout = setTimeout(function () { setmarquee(label, current, direction) }, 10);
}


function QueJobStatusInTable(jobid, progressid, oldcontent, newtimeout, table_grid_id) {
    if (newtimeout == null) {
        newtimeout = 3000;
    }
    qput = setTimeout(function () {
        qxhr = getajax("jobservice", "checkprogress", { jobid: jobid }, function () {
            //$("#error_message").html("System Error");
            alert("ERROR");
        }, function (res) {
            if (res.esit == true) {
                //$("#action").html(res.content.data.operation);
                //$("#elapsed").html(res.content.stage_elapsed);
                //$("#total_elapsed").html(res.content.main_elapsed);
                $("#" + progressid).find("div").css("width", res.content.percentage + "%");
                $("#" + progressid).find("label").html(res.content.data.operation);


                if (res.content.data.esit != null) {
                    //if (buttonid != null) {
                    //    //$("#" + buttonid).show();
                    //}
                    var closedialog = false;
                    var closetimeout = 1000;
                    var displaymessage = false;
                    if (res.content.data.esit == true) {
                        setpagelock(false);
                        //CHECK RETURN ACTIONS
                        $(Object.keys(res.content.data.returnactions))
                            .each(function (index, key) {
                                switch (key) {
                                    case "do-opener-update":
                                        var jsonstring = res.content.data.returnactions[key];
                                        var obj = JSON.parse(jsonstring);
                                        if (obj.message != null && obj.message.trim() != "") {
                                            displaymessage = true;
                                        }
                                        do_opener_update_InTable(progressid, oldcontent, obj.field, obj.htmlvalue, obj.techvalue, true, obj.save_hash, obj.refresh_parent_location, obj.message, table_grid_id);
                                        closedialog = false; //res.content.closedialog;
                                        break;
                                    //case "do-opener-insertsign":
                                    //    var jsonstring = res.content.data.returnactions[key];
                                    //    var obj = JSON.parse(jsonstring);
                                    //    do_opener_insertsign(obj.field, obj.field_visual, obj.save_hash, obj.refresh_parent_location, obj.message);
                                    //    //closedialog = res.content.closedialog;
                                    //    break;
                                    case "goto-url":
                                        var gotourl = res.content.data.returnactions[key];
                                        if (gotourl != null && gotourl.toString().trim() != "") {
                                            document.location = gotourl;
                                        }
                                        closedialog = res.content.closedialog;
                                        break;
                                    case "run-js":
                                        var js = res.content.data.returnactions[key];
                                        var toappend = "<script type='text/javascript'>" + js + "</script>";
                                        $("html").append(toappend);
                                        closedialog = res.content.closedialog;
                                        break;
                                    case "opener-write":
                                        var value = res.content.data.returnactions[key];
                                        opener.document.write(value);
                                        closedialog = res.content.closedialog;
                                        break;
                                    case "download-jobresult":
                                        closedialog = res.content.closedialog;
                                        var jobid = res.content.data.returnactions[key];
                                        try {
                                            opener.document.location = "downloadjobresult?jobid=" + jobid;
                                        }
                                        catch (error) {
                                            document.location = "downloadjobresult?jobid=" + jobid;
                                        }
                                        break;
                                    default:
                                        alert("Invalid Function Selector for :" + key);
                                        break;
                                }
                            });
                    } else {
                        display_error(res.content.data.message, res.content.displayonform);
                        //NON CHIUDERE LA DIALOG IN CASO DI ERRORE
                        //closedialog = true;
                        //closetimeout = 5000;
                    }
                    if (closedialog == true && displaymessage == false) {
                        setTimeout(function () { alert("CLOSED"); }, closetimeout);
                    }
                } else {
                    setpagelock(true);
                    QueJobStatusInTable(jobid, progressid, oldcontent, newtimeout, table_grid_id);
                }

            } else {
                //setpagelock(false);
                display_error(res.message, true);
                //$("#error_message").html(res.message);
                //$("#error_container").show();
            }
        }, true);
    }, newtimeout);
}



function QueJobStatus(jobid, buttonid, newtimeout) {
    if (newtimeout == null) {
        newtimeout = 3000;
    }
    qput = setTimeout(function () {
        qxhr = getajax("jobservice", "checkprogress", { jobid: jobid }, function () {
            $("#error_message").html("System Error");
        }, function (res) {
            if (res.esit == true) {
                $("#action").html(res.content.data.operation);
                $("#elapsed").html(res.content.stage_elapsed);
                $("#total_elapsed").html(res.content.main_elapsed);
                setprogress(res.content.percentage, res.content.percentage);

                //VARIABILI DI OUTPUT
                //var output = [];
                //$(Object.keys(res.content.data.displayvariables)).each(function (index, key) {
                //    var val = res.content.data.displayvariables[key];
                //    if (val == null) {
                //        val = "";
                //    }
                //    output.push(key + ' : ' + val.toString());
                //});
                //$("#output").html(output.join("<br/>"));

                if (res.content.data.esit != null) {
                    if (buttonid != null) {
                        //$("#" + buttonid).show();
                    }
                    var closedialog = false;
                    var closetimeout = 1000;
                    var displaymessage = false;
                    if (res.content.data.esit == true) {
                        setpagelock(false);
                        //CHECK RETURN ACTIONS
                        $(Object.keys(res.content.data.returnactions))
                            .each(function (index, key) {
                                switch (key) {
                                    case "do-opener-update":
                                        var jsonstring = res.content.data.returnactions[key];
                                        var obj = JSON.parse(jsonstring);
                                        if (obj.message != null && obj.message.trim() != "") {
                                            displaymessage = true;
                                        }
                                        do_opener_update(obj.field, obj.htmlvalue, obj.techvalue, true, obj.save_hash, obj.refresh_parent_location, obj.message);
                                        closedialog = false; //res.content.closedialog;
                                        break;
                                    //case "do-opener-insertsign":
                                    //    var jsonstring = res.content.data.returnactions[key];
                                    //    var obj = JSON.parse(jsonstring);
                                    //    do_opener_insertsign(obj.field, obj.field_visual, obj.save_hash, obj.refresh_parent_location, obj.message);
                                    //    //closedialog = res.content.closedialog;
                                    //    break;
                                    case "goto-url":
                                        var gotourl = res.content.data.returnactions[key];
                                        if (gotourl != null && gotourl.toString().trim() != "") {
                                            document.location = gotourl;
                                        }
                                        closedialog = res.content.closedialog;
                                        break;
                                    case "run-js":
                                        var js = res.content.data.returnactions[key];
                                        var toappend = "<script type='text/javascript'>" + js + "</script>";
                                        $("html").append(toappend);
                                        closedialog = res.content.closedialog;
                                        break;
                                    case "opener-write":
                                        var value = res.content.data.returnactions[key];
                                        opener.document.write(value);
                                        closedialog = res.content.closedialog;
                                        break;
                                    case "download-jobresult":
                                        closedialog = res.content.closedialog;
                                        var jobid = res.content.data.returnactions[key];
                                        try {
                                            opener.document.location = "downloadjobresult?jobid=" + jobid;
                                        }
                                        catch (error) {
                                            document.location = "downloadjobresult?jobid=" + jobid;
                                        }
                                        break;
                                    default:
                                        alert("Invalid Function Selector for :" + key);
                                        break;
                                }
                            });
                    } else {
                        setpagelock(false);
                        display_error(res.content.data.message, res.content.displayonform);
                        //NON CHIUDERE LA DIALOG IN CASO DI ERRORE
                        //closedialog = true;
                        //closetimeout = 5000;
                    }
                    if (closedialog == true && displaymessage == false) {
                        setTimeout(function () { window.close() }, closetimeout);
                    }
                } else {
                    setpagelock(true);
                    QueJobStatus(jobid, buttonid, newtimeout);
                }
            } else {
                setpagelock(false);
                display_error(res.message, true);
                //$("#error_message").html(res.message);
                //$("#error_container").show();
            }
        }, true);
    }, newtimeout);
}



function display_error(message, displayonform) {
    //alert(message);
    if (displayonform != null && displayonform == true) {
        $("div.lock-div").html(message);
        $("div.lock-div").addClass("error");
        $("div.lock-div").show();
    }
    else {

        //se passato esplicitamente allora applico Multilinguismo

        var MakeML = 'no';

        if (message.length > 7) {
            if (message.substring(message.length - 7) == '~YES_ML') {
                message = message.substring(0, message.length - 7);
                MakeML = 'yes';
            }
        }

        //document.location = '..' + applicationroot + '/ctl_library/MessageBoxWin.asp?ML=' + MakeML + '&MSG=' + escape(message) + '&CAPTION=Errore&ICO=2&NO_M=YES';

        //se non richiesto ML lo passo coerente
        if (MakeML === 'no')
            message = 'NO_ML###' + message;

        pathRoot = '..' + applicationroot + '/';
        DMessageBoxWithAction('', message, 'Errore', 1, 400, 300, 'ReloadForm');

    }
}

//per ricaricare il form di selezione degli allegati
function ReloadForm() {
    self.location = document.location;
}

function clear_error() {
    $("#error_message").html("");
    $("#error_container").hide();
}


function setpagelock(lock) {
    IsOperationProgress = lock;
    if (lock == true) {
        $("div.lock-div").show();
    } else {
        $("div.lock-div").hide();
    }
}

function do_opener_update(field, htmlvalue, techvalue, closeme, save_hash, refresh_parent_location, message) {

    var strformat = document.getElementById('format').value;

    //con la gestione degli attach multivalore questa gestione è deprecata
    /*
    self.opener.getObj(field).value = techvalue;

    if (self.opener.getObj("DIV_" + field))
    {
        self.opener.getObj("DIV_" + field).innerHTML = $(htmlvalue).html();
    }
    */

    //aggiorno il campo tecnico
    if (strFormat.indexOf("M") == -1) {
        document.getElementById('tech_value').value = techvalue;
    }
    else {
        if (techvalue != '') {
            strPrecTechValue = document.getElementById('tech_value').value;


            if (strPrecTechValue != '')
                strPrecTechValue = strPrecTechValue + '***';

            document.getElementById('tech_value').value = strPrecTechValue + techvalue;
        }
        else {
            document.getElementById('tech_value').value = '';
        }
    }



    //chiamo funzione che recupera la forma visuale ed aggiorna il campo sotto dell'opener
    if (self.opener.getObj("DIV_" + field))
        self.opener.getObj("DIV_" + field).parentNode.innerHTML = GetFormaVisualeAttach(field);

    try {
        if (self.opener.getObj(field).value != '') {
            //alert('opener.' + FIELD + '_OnChange();');        
            self.opener.getObj(field).onchange();
        }
    }
    catch (e) { }


    if (save_hash == true) {
        try {
            if (self.opener.getObj(field).value != '') {
                var fname = 'self.opener.' + field + '_OnChange();';
                eval(fname);
            }
        } catch (e) {
            alert(e);
        }
    }


    if (refresh_parent_location != null && refresh_parent_location.trim() != "") {
        //il servizio degli allegati lato server è utilizzato per elaborare i file di N applicazioni web ( ad es. application e newapplication ).
        //	la variabile refresh_parent_location viene composta prendendo la SYS della virtual directory. nel DB ci sarà 1 solo valore e qui lato web
        //	dobbiamo sovrascriverlo con il valore corretto ( recupero dal file di settings della virtual directory )

        try {
            refresh_parent_location = ReplaceALL(refresh_parent_location, '/application', applicationroot);
        }
        catch (e) { }

        opener.RefreshDocument(refresh_parent_location);
    }

    //se singolo come adesso
    if (strFormat.indexOf("M") == -1) {
        if (message != null && message != "") {
            self.document.location = '..' + applicationroot + '/ctl_library/MessageBoxWin.asp?ML=yes&MSG=' + escape(message) + '&CAPTION=Info&ICO=1&NO_M=YES';
        } else if (closeme == true) {

            try {
                //inizializza il DRAG_AND_DROP sugli allegati
                self.opener.Init_DRAG_AND_DROP_Allegati()
            }
            catch (e) { }

            self.close();
        }
    }
    else {
        //se multiplo ripristino le aree che erano nascoste
        $('#selector_area').show();
        $('#uploader_button').show();


        //il messaggio di esito lo inserisco in una nuova area che nascondo ad una nuova selezione
        if (message != null && message != "") {
            //self.document.location = '../application/ctl_library/MessageBoxWin.asp?ML=yes&MSG=' + escape(message) + '&CAPTION=Info&ICO=1&NO_M=YES';
            //alert(message);
            pathRoot = '..' + applicationroot + '/';
            DMessageBox('', message, 'Info', 1, 400, 300);
            //document.getElementById('dialog-message').innerHTML ='prova modale';
            //ShowModale();
        }


        //disegno la griglia
        Build_Grid_Attach_Multivalue();

        //reinizializzo gli oggeti client per il caricamento
        //fuploader = createuploader("uploader_button", "#selector_area", "drop_panel_id", "../chunkupload/1.0/?pid=<%:Request.QueryString("pid")%>", '<%=Model.fileextensions.Replace(";",",")%>', '<%:Model.maxsize%>', null,'<%:CTLDB.DatabaseManager.gettranslation(Model.language,"Uploading").Replace("'","\'")%>...');
        //fuploader.init();

        //alert(document.getElementById('tech_value').value);

        if (document.getElementById('tech_value').value != '') {
            $('#clear_button').show();
        } else {
            $('#clear_button').hide();
        }

    }

    try {
        //inizializza il DRAG_AND_DROP sugli allegati
        self.opener.Init_DRAG_AND_DROP_Allegati()
    }
    catch (e) { }
}



function do_opener_update_InTable(progressid, oldcontent, field, htmlvalue, techvalue, closeme, save_hash, refresh_parent_location, message, table_grid_id) {


    var container = $("#" + progressid).parent();
    $(container).html(oldcontent);
    $(container).find("input[type='hidden']").val(techvalue);
    $(container).find("table").first().replaceWith(htmlvalue);

    if (table_grid_id != undefined) {
        //area posizionale
        $(container).parent().find(".celluploadoverlay").removeClass("active").removeClass("disabled");
    }
    else {
        //area griglia
        $(container).parent().find(".celluploadoverlay_testata").removeClass("active").removeClass("disabled");
    }




    //if (getObj("DIV_" + field)) {
    //    getObj("DIV_" + field).innerHTML = $(htmlvalue).html();
    //}


    //try {
    //    if (getObj("DIV_" + field)) {
    //        getObj("DIV_" + field).parentNode.innerHTML = GetFormaVisualeAttach(field);
    //    }
    //}
    //catch (e) { }

    try {
        if (getObj(field).value != '') {
            //alert('opener.' + FIELD + '_OnChange();');        
            getObj(field).onchange();
        }
    }
    catch (e) { }


    if (save_hash == true) {
        try {
            if (getObj(field).value != '') {
                var fname = field + '_OnChange();';
                eval(fname);
            }
        } catch (e) {
            alert(e);
        }
    }

}


//function do_opener_insertsign(field, field_visual, save_hash, refresh_parent_location,message) {
//    try {
//        //aggiorno il campo del documento che contiene la forma tecnica 
//        //per aprire l'allegato in seguito
//        var obj = null;
//        var objUpdate = null;
//        self.opener.getObj(field_visual).value = self.opener.getObj(field).value;
//        obj = self.opener.getObj('DIV_' + field_visual);
//        objUpdate = self.opener.getObj('DIV_' + field);
//        //-- aggiorno il valore della DIV del FIELD
//        obj.innerHTML = objUpdate.innerHTML;
//    } catch (e) {}

//    //mi serve a capire se visualizzare messaggio 
//    var DisplayMsg = 1;
//    if (save_hash == true) {
//        try {
//            if (self.opener.getObj(field).value != '') {
//                //alert('opener.' + FIELD + '_OnChange();');        
//                eval('self.opener.' + field + '_OnChange();');
//                DisplayMsg = 0;
//            }
//        } catch (e) {}
//    }

//    try{
//        if (self.opener.getObj(field).value != '')
//        {
//            if (DisplayMsg == 1) {
//                document.location = '../application/ctl_library/MessageBoxWin.asp?ML=yes&MSG=allegato firmato correttamente salvato&CAPTION=Info&ICO=1';
//            }
//            try
//            {
//                //Se refresh parent location non viene passato vuol dire che l'opener non deve essere ricaricato
//                if (refresh_parent_location != null)
//                {
//                    opener.RefreshDocument(refresh_parent_location);
//                }

//            }catch( ein ){}
//        }

//    } catch (e) { }

//}

function GetFormaVisualeAttach(FieldName) {
    //RDOCUMENTAZIONEGrid_0_Allegato
    var path = document.getElementById('path').value;
    var strVirtualDirApp = document.getElementById('virtualdirapp').value;
    var strTechValue = document.getElementById('tech_value').value;
    var strFormat = document.getElementById('format').value;

    var nocache = new Date().getTime();

    var strTmpPath = '..' + strVirtualDirApp + '/';

    //da recuperare dal chiamante
    var strOnChange = '';

    try {
        //alert() //self.opener.getObj(field).onchange();
        var objField = self.opener.getObj(FieldName);
        //alert(objField);
        strOnChange = $(objField).attr("onchange");
        //alert(strOnChange);
        if (strOnChange == undefined)
            strOnChange = '';

    }
    catch (e) { }


    var Editable = 'yes';
    //alert(strTechValue);

    ajax = GetXMLHttpRequest();

    ajax.open("GET", strTmpPath + 'CTL_Library/GetField.asp?TIPO=18&PATH=' + path + '&EDITABLE=' + Editable + '&FIELD=' + FieldName + '&VALUE=' + encodeURIComponent(strTechValue) + '&ONCHANGE=' + strOnChange + '&FORMAT=' + encodeURIComponent(strFormat) + '&nocache=' + nocache, false);

    ajax.send(null);



    if (ajax.readyState == 4) {

        if (ajax.status == 200) {
            //-- funziona solo per i domini chiusi perchè sono in un div
            //alert(ajax.responseText);
            return ajax.responseText;
        }
    }

}


function GetXMLHttpRequest() {
    var
        XHR = null,
        browserUtente = navigator.userAgent.toUpperCase();

    if (typeof (XMLHttpRequest) === "function" || typeof (XMLHttpRequest) === "object")
        XHR = new XMLHttpRequest();
    else if (window.ActiveXObject && browserUtente.indexOf("MSIE 4") < 0) {
        if (browserUtente.indexOf("MSIE 5") < 0)
            XHR = new ActiveXObject("Msxml2.XMLHTTP");
        else
            XHR = new ActiveXObject("Microsoft.XMLHTTP");
    }
    return XHR;
};

function Build_Grid_Attach_Multivalue() {
    //alert('disegno la griglia allegati multivalore');
    //alert(document.getElementById('tech_value').value);


    var strHTMLGrid = '';
    var strTechValueAttach = document.getElementById('tech_value').value;

    $("#ElencoFile").hide();
    $("#DIV_GRID_ATTACH_MULTIVALUE").hide();
    $("#Sep_Elenco_File").hide();

    if (strTechValueAttach != '') {


        $("#ElencoFile").show();
        $("#DIV_GRID_ATTACH_MULTIVALUE").show();
        $("#Sep_Elenco_File").show();

        var strTechValue;
        //faccio la split
        var aInfoAttach = strTechValueAttach.split('***');
        var nNumAttach = aInfoAttach.length;
        //alert(nNumAttach);
        //per ogni allegato faccio chiamata a filterfield


        //effettuo chiamata ajax per farmi ritornare lo stato del certificato se la format lo richiede
        var strFormat = document.getElementById('format').value;

        var InfoCertificato = '';
        if (strFormat.indexOf("V") != -1) {
            InfoCertificato = GetInfoCertificato(strTechValueAttach);

            var aInfo = InfoCertificato.split('***');
        }

        strHTMLGrid = '<table class="GRID_ELENCO_FILE">';




        for (i = 0; i < nNumAttach; i++) {

            //alert(aInfoAttach[i]);
            strTechValue = aInfoAttach[i];
            //alert(strTechValue);
            //strVisualValue = strTechValue;
            strInfoCert = ""
            if (InfoCertificato != "")
                strInfoCert = aInfo[i]


            strHTMLGrid = strHTMLGrid + BuildRowGrid(strTechValue, i, strInfoCert);


        }


        strHTMLGrid = strHTMLGrid + '</table>'
    }

    //aggiorno la griglia nella div preposta
    document.getElementById('DIV_GRID_ATTACH_MULTIVALUE').innerHTML = strHTMLGrid;



}

//ritorna html riga 
function BuildRowGrid(strTechValueAttach, r, InfoCertificato) {
    var strExtFile;
    var strStatusCert;
    var strNomeFile = '';
    var aInfoSingleAttach;
    var strHTML_RowGrid;
    var strVirtualDirApp = document.getElementById('virtualdirapp').value;
    var strOnClick = '';
    var path = '../' + strVirtualDirApp;

    aInfoSingleAttach = strTechValueAttach.split('*');
    strNomeFile = aInfoSingleAttach[0];
    strExtFile = aInfoSingleAttach[1];

    //alert(strExtFile);

    //cotruisco riga tabella html
    strHTML_RowGrid = '<tr class="ROW_ELENCO_FILE" id="GRID_ATTACH_R_' + r + '">';

    //colonna cestino
    strHTML_RowGrid = strHTML_RowGrid + '<td class="CELL_ELENCOFILE" onclick="javascript:DeleteRow_GridAttach(' + i + ')"><img src="' + strVirtualDirApp + '/CTL_LIBRARY/images/toolbar/Delete_Light.GIF"></td>';

    strTechValueAttach = strTechValueAttach.replace('\\', '\\\\');
    strTechValueAttach = strTechValueAttach.replace("'", "\\'");


    //costruisco onclick
    strOnClick = 'onclick="javascript:DisplayAttach(\'' + encodeURIComponent(path) + '\',\'' + strTechValueAttach + '\')"';

    //colonna icona estensione 
    //../../CTL_Library/images/Domain/Ext_pdf.gif
    strPathImage = strVirtualDirApp + '/CTL_Library/images/Domain/Ext_' + strExtFile + '.gif';
    strHTML_RowGrid = strHTML_RowGrid + '<td class="CELL_ELENCOFILE"><img src="' + strPathImage + '" ' + strOnClick + '>';
    strHTML_RowGrid = strHTML_RowGrid + '</td>';

    //colonna info certificato se nella format è presente la V 
    if (InfoCertificato != '') {
        strPathImage = strVirtualDirApp + '/CTL_Library/images/Domain/' + InfoCertificato + '.png';
        strHTML_RowGrid = strHTML_RowGrid + '<td class="CELL_CERTIFICATO"><img src="' + strPathImage + '">';
        strHTML_RowGrid = strHTML_RowGrid + '</td>';
    }
    //colonna nome file
    strHTML_RowGrid = strHTML_RowGrid + '<td class="CELL_DESCRIZIONE_ELENCO_FILE"><span ' + strOnClick + '>';
    strHTML_RowGrid = strHTML_RowGrid + strNomeFile;
    strHTML_RowGrid = strHTML_RowGrid + '</span></td>';
    //alert(strHTML_RowGrid);
    strHTML_RowGrid = strHTML_RowGrid + '</tr>'

    return strHTML_RowGrid;
}

//cancella una riga attach
function DeleteRow_GridAttach(r) {
    //alert('cancellazione riga ' + r);


    //cancello allegato i-esimo dal techvalue
    var strfieldid = document.getElementById('fieldid').value;
    var strTechValueAttach = document.getElementById('tech_value').value;
    var aInfoAttach = strTechValueAttach.split('***');
    var nNumAttach = aInfoAttach.length;

    var strNewValueTechAttach = '';


    for (i = 0; i < nNumAttach; i++) {
        if (i != r) {
            if (strNewValueTechAttach != '')
                strNewValueTechAttach = strNewValueTechAttach + '***';

            strNewValueTechAttach = strNewValueTechAttach + aInfoAttach[i];

        }

    }
    //alert(strNewValueTechAttach);

    document.getElementById('tech_value').value = strNewValueTechAttach;


    //ridisegno la tabella
    Build_Grid_Attach_Multivalue();

    //aggiorno il campo sotto completo
    self.opener.getObj("DIV_" + strfieldid).parentNode.innerHTML = GetFormaVisualeAttach(strfieldid);


    if (document.getElementById('tech_value').value != '') {
        $('#clear_button').show();
    } else {
        $('#clear_button').hide();
        $("#ElencoFile").hide();
        $("#Sep_Elenco_File").hide();
    }

}

/*
function DisplayAttach( strTechValueAttach )
{
    var strVirtualDirApp = document.getElementById('virtualdirapp').value;
    //alert(strTechValueAttach);
    //ExecFunction( '../Application/CTL_Library/functions/field/DisplayAttach.ASP?OPERATION=DISPLAY&FIELD=AllegatoPerOCP&PATH=%2E%2E%2F%2E%2E%2F&TECHVALUE=2020%5F06%5F11%5Frichiesta%5Fsater%2Epdf%2Apdf%2A499849%2Abb88bdd24c324818a%5F20211125155422595%2ASHA256%2AD8196A5F737D53B24E6529F02FDCBE1B92E0E6F625BF8F5C9A24801569A00519%2A2021%2D11%2D25T16%3A54%3A26&FORMAT=INTM'  , 'DisplayAttach' , ',height=400,width=600' );
    var strUrl = '../Application/CTL_Library/functions/field/DisplayAttach.ASP?';
    strUrl = strUrl + 'OPERATION=DISPLAY&TECHVALUE=' + encodeURIComponent(strTechValueAttach);
    //strUrl = strUrl + 'TECHVALUE=' + encodeURIComponent(strTechValueAttach);
    ExecFunction(  strUrl  , 'DisplayAttach' , ',height=400,width=600' );

}
*/



function GetInfoCertificato(strTechValueAttach) {
    var strVirtualDirApp = document.getElementById('virtualdirapp').value;
    var nocache = new Date().getTime();
    var strTmpPath = '..' + strVirtualDirApp + '/';

    //alert(strTmpPath + 'CTL_Library/functions/GetInfoCertificato.asp?VALUE=' +  encodeURIComponent(strTechValueAttach) + '&nocache=' + nocache);

    ajax = GetXMLHttpRequest();

    ajax.open("GET", strTmpPath + 'CTL_Library/functions/GetInfoCertificato.asp?VALUE=' + encodeURIComponent(strTechValueAttach) + '&nocache=' + nocache, false);

    ajax.send(null);

    if (ajax.readyState == 4) {

        if (ajax.status == 200) {
            //-- funziona solo per i domini chiusi perchè sono in un div

            return ajax.responseText;
        }
    }
}




function ShowModale() {
    try {
        //alert('pippo');
        $(function () {

            $("#dialog-message").dialog({
                modal: true,
                buttons: {
                    Ok: function () {
                        $(this).dialog("close");
                    }
                }
            });
        });
    }
    catch (e) {
        //alert(e);
    }
}
