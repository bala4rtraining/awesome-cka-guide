/**
 * File:     SMEapp.js
 * Purpose:  To display a table of SME information  (data sourced from a simple REST-API)
 *
 */
var smeapp_api_url="http://localhost:8090/api";
var testdata3=[["1","Jenkinsfile","4","3","2","1"],["2","golang","4","3","2","1"],["2","LINEgolang","4","3","2","1"],["3","authorization application","4","3","2","1"],["4","elasticsearch","4","3","2","1"],["5","kibana","4","3","2","1"],["6","fluentd","4","3","2","1"],["7","kafka","4","3","2","1"]];
$(document).ready( function () {
    alert("hello World");


    maintable = $('#maintable').DataTable({
        destroy: true,
        data: testdata3,
        columns: [
            { title: "Timestamp (GMT)", "searchable": false, "width": "16%" },
            { title: "RRN", "width": "10%" },
            { title: "Type", "width": "10%" },
            { title: "Hostname", "searchable": false, "width":"10%" },
            { title: "Payload", "searchable": false },
            { title: "Timestamp (GMT)", "searchable": false, "width": "16%" }
        ]
    });

    $('#refreshbutton')
        .button()
        .click(function( event ) {
            refresh();
    });
});


function refresh() {
    var newdataSet = [];        // for DataTable build
    alert("hello World  REFRESH");
    $.ajax({
        type: "POST",         // use GET + 'source=' for elasticsearch REST API.
        url: smeapp_api_url,
        data: '{"Table": "member"}',
        success: function (data) {
//      Create and reload the data in the datatable
            alert("hello World - after the POST");
            smetable = $('#maintable').DataTable({
                destroy: true,
                data: newdataSet
            });
        }
    });
}
