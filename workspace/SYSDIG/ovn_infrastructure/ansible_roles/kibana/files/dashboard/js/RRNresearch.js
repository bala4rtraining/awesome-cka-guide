/**
 * File:     RRNresearch.js
 * Purpose:  To handle the dynamic pieces of the Transaction research page plugin for Kibana
 * Versions: (0.5) 1st Sep 2016 - initial creation, removing hardcoded items to enable it to be portable between systems
 *
 */
var maxhits=1000;
var rrntable;
var elasticsearchurl="/elasticsearch/*-syslog-*/_search";
var kibanapage="/app/kibana#/discover/Transaction-research-(items-with-RRN)";
var d1 = new Date();
d1.setUTCHours(0,0,0);
var d2 = new Date();
d2.setUTCHours(23,59,59);

var kibanaurl=kibanapage +
    "?_g=(refreshInterval:(display:Off,pause:!f,value:0)," +
    "time:(from:now-3d,mode:relative,to:now))&" +
    "_a=(columns:!(Hostname,Payload,rrn,mti_in,mti_out,contextmap,src)," +
    "filters:!(),index:'*-syslog-*',interval:auto," +
    "query:(query_string:(analyze_wildcard:!t," +
    "query:'rrn:%5C%3C%5C%3C%5C%226*'))," +
    "sort:!(Timestamp,desc))";

var requestdata={
    "query": {
        "filtered": {
            "query": {
                "range": {
                    "Timestamp": {
                        "from": d1.toISOString(),
                        "to": d2.toISOString()
                    }
                }
            },
            "filter": {
                "bool": {
                    "must_not": {
                        "missing": {
                            "field": "rrn",
                                "existence": true,
                                "null_value": true
                        }
                    },
                    "filter": {
                        "wildcard": {
                            "rrn": "*0*"
                        }
                    }
                }
            }
        }
    },
    "size": maxhits
};


$(document).ready(function(){
    $( "#datepicker" ).datepicker();
    $( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" );
    $( "#datepicker" ).datepicker( "option", "autoSize", true );
    var today = new Date();
    datepicker.value=$.datepicker.formatDate( "yy-mm-dd", today );

    $("#slider-range").slider({
        range: true,
        min: 0,
        max: 1439,
        step: 15,
        values: [0, 1439],
        slide: function (e, ui) {
            drawTimeRange(ui.values[0],ui.values[1]);
        }
    });
    rrntable = $('#rrnTable').DataTable({
        destroy: true,
        data: [],
        columns: [
            { title: "Timestamp (GMT)", "searchable": false, "width": "16%" },
            { title: "RRN", "width": "10%" },
            { title: "Type", "width": "10%" },
            { title: "Hostname", "searchable": false, "width":"10%" },
            { title: "Payload", "searchable": false }
        ]
    });

    $('#kibanabutton')
        .button({
            icons: { primary: "ui-icon-gear", secondary: "ui-icon-triangle-1-s" }
        })
        .click(function( event ) {
            window.location=kibanaurl;
        });
    $('#refreshbutton')
        .button()
        .click(function( event ) {
            var slidervalues = $('#slider-range').slider("values");
            var mm1 = slidervalues[0] % 60;
            var hh1 = (slidervalues[0] - (slidervalues[0] % 60)) / 60;
            var mm2 = slidervalues[1] % 60;
            var hh2 = (slidervalues[1] - (slidervalues[1] % 60)) / 60;
            if (mm1<10) {mm1 = '0' + mm1}
            if (mm2<10) {mm2 = '0' + mm2}
            if (hh1<10) {hh1 = '0' + hh1}
            if (hh2<10) {hh2 = '0' + hh2}
            requestdata.query.filtered.query.range.Timestamp.from= datepicker.value + "T" + hh1 + ":" + mm1;
            requestdata.query.filtered.query.range.Timestamp.to=   datepicker.value + "T" + hh2 + ":" + mm2;
            if (rrntable !==undefined) {
                var searchvalue = rrntable.search();
                if (searchvalue == undefined | searchvalue == '') {
                    requestdata.query.filtered.filter.bool.filter.wildcard.rrn = '*0*';
                } else {
                    requestdata.query.filtered.filter.bool.filter.wildcard.rrn = "*" + searchvalue + "*";
                    kibanaurl=kibanapage +
                    "?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:'" +
                    requestdata.query.filtered.query.range.Timestamp.from +
                    "Z',mode:absolute,to:'" +
                    requestdata.query.filtered.query.range.Timestamp.to +
                    "Z'))&" +
                    "_a=(columns:!(Hostname,Payload,rrn,mti_in,mti_out,contextmap,src)," +
                    "filters:!(),index:'*-syslog-*',interval:auto," +
                    "query:(query_string:(analyze_wildcard:!t," +
                    "query:'rrn:" +
                    requestdata.query.filtered.filter.bool.filter.wildcard.rrn +
                     "'))," +
                    "sort:!(Timestamp,desc))";
                }
            }
            refresh();
    });
    refresh();
});

function refresh() {
    var dataSet = [];        // for DataTable build
    $.ajax({
        type: "GET",         // use GET + 'source=' for elasticsearch REST API.
        url: elasticsearchurl,
        data: "source=" + JSON.stringify(requestdata),
        success: function (data) {
            var totalhits = data.hits.total;
            var matchdata = data.hits.hits;
            var rowitem = [];
            var size = 0;
            var workingrrn = 0;
            var minTimestamp;
            var maxTimestamp;
            for (var key in matchdata) {
                if (typeof matchdata[key]._source.rrn !== 'undefined') {  // debugging ??
                    workingrrn = matchdata[key]._source.rrn.replace('<<"', "").replace('">>', "");
                } else {
                    workingrrn = '?';   // basically for debug (should always exist)
                }
                if (minTimestamp == undefined) {
                    minTimestamp = matchdata[key]._source.Timestamp
                }
                else if (minTimestamp > matchdata[key]._source.Timestamp) {
                    minTimestamp = matchdata[key]._source.Timestamp
                }
                if (maxTimestamp == undefined) {
                    maxTimestamp = matchdata[key]._source.Timestamp
                }
                else if (maxTimestamp < matchdata[key]._source.Timestamp) {
                    maxTimestamp = matchdata[key]._source.Timestamp
                }
                rowitem = [
                    matchdata[key]._source.Timestamp,
                    workingrrn,
                    matchdata[key]._source.Type,
                    matchdata[key]._source.Hostname,
                    matchdata[key]._source.Payload
                ];
                dataSet.push(rowitem);
                size++;
            }
//      Create and reload the data in the datatable
            rrntable = $('#rrnTable').DataTable({
                destroy: true,
                data: dataSet
            });
//      Enable clickable rrns
            $('#rrnTable tbody').on('click', 'tr', function () {
                var data = rrntable.row(this).data();     // when a row is clicked get the RRN selected
                rrntable.search(data[1]).draw();          // And put it into the search pane
            });
//      Reset the timerange sliders based on returned data
            if (minTimestamp !== undefined) {
                var bot = minTimestamp.substr(11, 2) * 60 + (minTimestamp.substr(14, 2) * 1.0);
                bot = bot - (bot % 15);
                var top = maxTimestamp.substr(11, 2) * 60 + (maxTimestamp.substr(14, 2) * 1.0);
                top = 15 + (top - (top % 15));
                $("#slider-range").slider("option", "values", [ bot, top ]);
                drawTimeRange(bot, top);
            }
        }
    });
}

function drawTimeRange(lower, upper){
    var hours1 = Math.floor(lower / 60);
    var minutes1 = lower - (hours1 * 60);

    if (hours1 < 10) hours1 = '0' + hours1;
    if (minutes1.length == 1) minutes1 = '0' + minutes1;
    if (minutes1 == 0) minutes1 = '00';
    $('.slider-time').html(hours1 + ':' + minutes1);

    var hours2 = Math.floor(upper / 60);
    var minutes2 = upper - (hours2 * 60);

    if (hours2 < 10) hours2 = '0' + hours2;
    if (minutes2.length == 1) minutes2 = '0' + minutes2;
    if (minutes2 == 0) minutes2 = '00';
    $('.slider-time2').html(hours2 + ':' + minutes2);
}
