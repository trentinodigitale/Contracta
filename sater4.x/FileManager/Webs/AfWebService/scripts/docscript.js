

var applicationroot = null;
function initgriduploader() {
    var p = `
        <!--FUNZIONTAMENTO UPLOADER-->            
            <link rel = "stylesheet"  href = "https://afsvm046f.afsoluzioni.it/AF_WebFileManager/assets/tableupload.css" />
            <link rel="stylesheet"  href="https://afsvm046f.afsoluzioni.it/AF_WebFileManager/assets/jquery-ui.css"/>
            <script src="https://afsvm046f.afsoluzioni.it/AF_WebFileManager/scripts/aftoolkit.js"></script>
            <script src="https://afsvm046f.afsoluzioni.it/AF_WebFileManager/js/plupload/js/plupload.full.min.js"></script>
            <script src="https://afsvm046f.afsoluzioni.it/AF_WebFileManager/js/plupload/js/i18n/it.js"></script>
            <!--per funzionamento modale-- >
            <script src="https://afsvm046f.afsoluzioni.it/AF_WebFileManager/js/jquery/jquery-ui.min.js" type="text/javascript"></script>
        <!--FUNZIONTAMENTO UPLOADER-- >`;
    $("body").append(p);


    setTimeout(function() {
        UploadServiceRootUrl = "/AF_WebFileManager/";
        applicationroot = "/Application";

        $("#DOCUMENTAZIONEGrid div.DIV_ATTACH_CONTAINER:not(.initialized)").each(function (i, maincontainer) {
            var maincontainerid = $(maincontainer).attr("id");
            var abutton = $(maincontainer).find("input.Attach_button");
            var buttonlink = $(abutton).attr("onclick");

            //var res = preparecellupload('BB4CCC04-D054-4B66-ABB5-0266045CAF9A', buttonlink);
            var dragid = getrandom();
            $(maincontainer).parent().append("<div id='" + dragid + "' class='celluploadoverlay'>DRAG FILE HERE</div>");

            //+ res.pid,
            var fuploader = createTableUploader(buttonlink, dragid, maincontainerid, "https://afsvm046f.afsoluzioni.it/AF_WebFileManager/chunkupload/1.0/?pid=", 'pdf','10mb', null, 'Uploading...');
            fuploader.init();


            //SET EFFECTS
            //DRAG OVERLAY SECTION
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
            $(maincontainer).addClass("initialized");

        });

        

    }, 1000);


}


initgriduploader();

