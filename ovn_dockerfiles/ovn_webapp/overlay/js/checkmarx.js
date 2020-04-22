/**
 * File:     checkmarx.js
 * Purpose:  To display a table of Checkmarx information  (data sourced from a simple REST-API)
 *
 */

$(document).ready(function() {

    $("#tabs").tabs();


    $('#checkmarx_tbl').DataTable( {
        "scrollY":        '50vh',
        "scrollCollapse": true,
        "paging":         false,
        "ajax": "api/checkmarx",
	"columns": [
            { "data": "importscanid" , "title": "Scan_ID"},
            { "data": "cxi_id" , "title": "CXi_ID"},
            { "data": "cxi_directlink" , "title": "CXi_Directlink"},
            { "data": "cxi_queryname", "title": "CXi_QueryName" },
            { "data": "cxi_status", "title": "CXi_Status" },
            { "data": "cxi_sourcefolder", "title": "CXi_SourcePath" },
        ]
    } );

} );