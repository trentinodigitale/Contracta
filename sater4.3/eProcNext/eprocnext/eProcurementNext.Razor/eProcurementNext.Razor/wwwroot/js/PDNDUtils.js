
//$("#purposeId").change(function () {
//    let url = '?handler=Pippo';
//    alert(url);
//});
// let params = { "id": id }
// EprocRequest("GET", url, null, params, (err, data) => {
//     data = JSON.parse(data);
//     if (data.status != "OK") {
//         console.error(data.result);
//         $("#loader").hide();
//     } else {
//         HandleButtonRecentActivityClick();
//     }
// })

//$("#lstAziende").change(function () {
//    var azi = $("#lstAziende").val();
//    alert(azi);
//    let url = `/testVoucher`;
//    let params = {
//        "handler": 'Test',
//        "IdAzi": azi
//    }
//    EprocRequest("GET", url, null, params, (err, data) => {
//        data = JSON.parse(data);
//        if (data.status != "OK") {
//            console.error(data.result);
//            $("#loader").hide();
//        } else {
//            alert('Errore');
//        }
//    })
//});

//$("#lstAziende").change(function () {
//    var id = $("#lstAziende").val();
//    $.ajax({
//        url: "?handler=Test&idAzi=" + id,
//        method: "GET",
//        success: function (prog) {
//            alert("prog:" + prog);
//            var json = JSON.parse(prog);
//            alert("json: " + json);
            
//            //Remove all items in the countriesList
//            //if (json.length > 0) {
//            //    $("#purposeId option").remove();
//            //    for (var i = 0; i < json.length; i++) {
//            //        //...append that item to the countriesList
//            //        $("#purposeId").append("<option value='" + json[i][0] + "'>" + json[i][1] + "</option>");
//            //    };
//            //}
//        }
//    })
//});
