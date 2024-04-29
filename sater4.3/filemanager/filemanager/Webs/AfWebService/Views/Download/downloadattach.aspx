<%@ Page Title="" Language="VB"  Inherits="System.Web.Mvc.ViewPage" %>
<%="" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title>Files Uploader</title>
        
        <link href="../../assets/style.css" rel="stylesheet" />

        <script src="js/jquery/jquery-3.4.1.min.js"></script>
        <script src="scripts/aftoolkit.js"></script>
        <script src="js/plupload/js/plupload.full.min.js"></script>


    </head>
    <body>
        <form id="form1" runat="server">
            <div>
                <fieldset>
                    <legend>File Download Details</legend>
                    <div  class="report">
                        <table class="reporting-table">
                            <tbody>                          
                                <tr>
                                    <th>Stage Progress:</th>
                                    <td>
                                        <div class="progress-div">
                                            <div class="progress-bar">
                                                <span id="progress"></span>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Current Stage:</th>
                                    <td><span id="action"></span></td>
                                </tr>
                                <tr>
                                    <th>Stage Elapsed:</th>
                                    <td><span id="elapsed"></span></td>
                                </tr>
                                <tr>
                                    <th>Total Time:</th>
                                    <td><span id="total_elapsed"></span></td>
                                </tr>
                                <tr>
                                    <th>Error:</th>
                                    <td><span id="error_message"></span></td>
                                </tr>
                                                                

                            </tbody>                        
                        </table>
                    </div>
                </fieldset>

            </div>
        </form>
        

        <script type="text/javascript">
            
            function update_progress(data,action) {
                $("#action").html(action);
                if (data == null) {
                    $("#progress").html("");
                    $(".progress-bar").css("width", "0%");                    
                    $("#remaining").html("");
                    $("#elapsed").html("");
                    $("#total_elapsed").html("");
                    $("#error_message").html("");
                } else {
                    $("#progress").html(data.percentage);
                    $(".progress-bar").css("width", data.percentage);
                    $("#remaining").html(data.remaining);
                    $("#elapsed").html(data.elapsed);
                    $("#total_elapsed").html(data.elapsed);
                }
            }
            QueJobStatus("<%:Request.QueryString("id")%>",null,1000);
        </script>
               
    </body>
</html>
