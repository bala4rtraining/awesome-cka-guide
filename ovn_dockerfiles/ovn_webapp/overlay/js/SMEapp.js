/**
 * File:     SMEapp.js
 * Purpose:  To display a table of SME information  (data sourced from a simple REST-API)
 *
 */
var componenttable;
var membertable;
var tracktable;

$(document).ready(function() {

    $("#tabs").tabs();

    $('#member_tbl').DataTable( {
        "scrollY":        '50vh',
        "scrollCollapse": true,
        "paging":         false,
        "ajax": "api/member",
        "columns": [
            { "data": "memberid", "title": "MemberID" },
            { "data": "firstname" , "title": "Member Name"},
            { "data": "email_id", "title": "Email" },
            { "data": "location", "title": "Loc" },
            { "data": "trackid", "title": "Track ID" },
            { "data": "title", "title": "Title" },
            { "data": "phone", "title": "Phone Number" },
            { "data": "managername", "title": "Manager" }
        ]
    } );

    $('#component_tbl').DataTable( {
        "scrollY":        '50vh',
        "scrollCollapse": true,
        "paging":         false,
        "ajax": "api/component",
        "columns": [
            { "data": "componentid", "title": "CompID" },
            { "data": "cname" , "title": "Component Name"},
            { "data": "description" , "title": "Description"},
            { "data": "sme1", "title": "SME1" },
            { "data": "sme2", "title": "SME2" },
            { "data": "sme3", "title": "SME3" },
            { "data": "sme4", "title": "SME4" }
        ]
    } );

    $('#track_tbl').DataTable( {
        "scrollY":        '50vh',
        "scrollCollapse": true,
        "paging":         false,
        "ajax": "api/track",
        "columns": [
            { "data": "trackid", "title": "TrackID" },
            { "data": "name" , "title": "Track Name"},
            { "data": "tracklead1", "title": "Track lead 1" },
            { "data": "tracklead2", "title": "Track lead 2" },
            { "data": "description", "title": "Description" },
            { "data": "managername", "title": "Dev Manager" }
        ]
    } );
$.ajax({
  url: "api/track",
}).done(function(data) {
  $('#json_data').append(JSON.stringify(data))
});
} );
