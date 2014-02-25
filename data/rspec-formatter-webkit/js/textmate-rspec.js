/*
 * RSpec WebKit Formatter javascript
 * $Id$
 * 
 * Most of these functions were converted from Safari's Web Inspector, which is licensed 
 * under the following terms:
 * 
 *   Copyright (C) 2007 Apple Inc.  All rights reserved.
 *   
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 *   
 *   1.  Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer. 
 *   2.  Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution. 
 *   3.  Neither the name of Apple Computer, Inc. ("Apple") nor the names of
 *       its contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission. 
 *   
 *   THIS SOFTWARE IS PROVIDED BY APPLE AND ITS CONTRIBUTORS "AS IS" AND ANY
 *   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *   DISCLAIMED. IN NO EVENT SHALL APPLE OR ITS CONTRIBUTORS BE LIABLE FOR ANY
 *   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * All mistakes and modifications are (c) 2009 Michael Granger, and are distributed under
 * the same terms as the original.
 * 
 */

var polltimer = null;

function fade_out_rect( ctx, x, y, w, h, a1, a2 ) {
    ctx.save();

    var gradient = ctx.createLinearGradient(x, y, x, y + h);
    gradient.addColorStop(0.0, "rgba(0, 0, 0, " + (1.0 - a1) + ")");
    gradient.addColorStop(0.8, "rgba(0, 0, 0, " + (1.0 - a2) + ")");
    gradient.addColorStop(1.0, "rgba(0, 0, 0, 1.0)");

    ctx.globalCompositeOperation = "destination-out";

    ctx.fillStyle = gradient;
    ctx.fillRect(x, y, w, h);

    ctx.restore();
}

function draw_summary_graph( selector, segments ) {
	var graphElement = $(selector).get( 0 );
	var i = 0;
	
    if (!graphElement)
        return;

    if (!segments || !segments.length) {
        segments = [{color: "white", value: 1}];
        // this._showingEmptySummaryGraph = true;
    } // else
     //        delete this._showingEmptySummaryGraph;

    // Calculate the total of all segments.
    var total = 0;
    for (i = 0; i < segments.length; ++i)
        total += segments[i].value;

    // Calculate the percentage of each segment, rounded to the nearest percent.
    var percents = segments.map(function(s) {
		return Math.max(Math.round(100 * s.value / total), 1);
	});

    // Calculate the total percentage.
    var percentTotal = 0;
    for (i = 0; i < percents.length; ++i)
        percentTotal += percents[i];

    // Make sure our percentage total is not greater-than 100, it can be greater
    // if we rounded up for a few segments.
    while (percentTotal > 100) {
        for (i = 0; i < percents.length && percentTotal > 100; ++i) {
            if (percents[i] > 1) {
                --percents[i];
                --percentTotal;
            }
        }
    }

    // Make sure our percentage total is not less-than 100, it can be less
    // if we rounded down for a few segments.
    while (percentTotal < 100) {
        for (i = 0; i < percents.length && percentTotal < 100; ++i) {
            ++percents[i];
            ++percentTotal;
        }
    }

    var ctx = graphElement.getContext("2d");

    var x = 0;
    var y = 0;
    var w = 450;
    var h = 19;
    var r = (h / 2);

    function drawPillShadow()
    {
        // This draws a line with a shadow that is offset away from the line. The line is stroked
        // twice with different X shadow offsets to give more feathered edges. Later we erase the
        // line with destination-out 100% transparent black, leaving only the shadow. This only
        // works if nothing has been drawn into the canvas yet.

        ctx.beginPath();
        ctx.moveTo(x + 4, y + h - 3 - 0.5);
        ctx.lineTo(x + w - 4, y + h - 3 - 0.5);
        ctx.closePath();

        ctx.save();

        ctx.shadowBlur = 2;
        ctx.shadowColor = "rgba(0, 0, 0, 0.5)";
        ctx.shadowOffsetX = 3;
        ctx.shadowOffsetY = 5;

        ctx.strokeStyle = "white";
        ctx.lineWidth = 1;

        ctx.stroke();

        ctx.shadowOffsetX = -3;

        ctx.stroke();

        ctx.restore();

        ctx.save();

        ctx.globalCompositeOperation = "destination-out";
        ctx.strokeStyle = "rgba(0, 0, 0, 1)";
        ctx.lineWidth = 1;

        ctx.stroke();

        ctx.restore();
    }

    function drawPill()
    {
        // Make a rounded rect path.
        ctx.beginPath();
        ctx.moveTo(x, y + r);
        ctx.lineTo(x, y + h - r);
        ctx.quadraticCurveTo(x, y + h, x + r, y + h);
        ctx.lineTo(x + w - r, y + h);
        ctx.quadraticCurveTo(x + w, y + h, x + w, y + h - r);
        ctx.lineTo(x + w, y + r);
        ctx.quadraticCurveTo(x + w, y, x + w - r, y);
        ctx.lineTo(x + r, y);
        ctx.quadraticCurveTo(x, y, x, y + r);
        ctx.closePath();

        // Clip to the rounded rect path.
        ctx.save();
        ctx.clip();

        // Fill the segments with the associated color.
        var previousSegmentsWidth = 0;
        for (var i = 0; i < segments.length; ++i) {
            var segmentWidth = Math.round(w * percents[i] / 100);
            ctx.fillStyle = segments[i].color;
            ctx.fillRect(x + previousSegmentsWidth, y, segmentWidth, h);
            previousSegmentsWidth += segmentWidth;
        }

        // Draw the segment divider lines.
        ctx.lineWidth = 1;
        for (i = 1; i < 20; ++i) {
            ctx.beginPath();
            ctx.moveTo(x + (i * Math.round(w / 20)) + 0.5, y);
            ctx.lineTo(x + (i * Math.round(w / 20)) + 0.5, y + h);
            ctx.closePath();

            ctx.strokeStyle = "rgba(0, 0, 0, 0.2)";
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(x + (i * Math.round(w / 20)) + 1.5, y);
            ctx.lineTo(x + (i * Math.round(w / 20)) + 1.5, y + h);
            ctx.closePath();

            ctx.strokeStyle = "rgba(255, 255, 255, 0.2)";
            ctx.stroke();
        }

        // Draw the pill shading.
        var lightGradient = ctx.createLinearGradient(x, y, x, y + (h / 1.5));
        lightGradient.addColorStop(0.0, "rgba(220, 220, 220, 0.6)");
        lightGradient.addColorStop(0.4, "rgba(220, 220, 220, 0.2)");
        lightGradient.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");

        var darkGradient = ctx.createLinearGradient(x, y + (h / 3), x, y + h);
        darkGradient.addColorStop(0.0, "rgba(0, 0, 0, 0.0)");
        darkGradient.addColorStop(0.8, "rgba(0, 0, 0, 0.2)");
        darkGradient.addColorStop(1.0, "rgba(0, 0, 0, 0.5)");

        ctx.fillStyle = darkGradient;
        ctx.fillRect(x, y, w, h);

        ctx.fillStyle = lightGradient;
        ctx.fillRect(x, y, w, h);

        ctx.restore();
    }

    ctx.clearRect(x, y, w, (h * 2));

    drawPillShadow();
    drawPill();

    ctx.save();

    ctx.translate(0, (h * 2) + 1);
    ctx.scale(1, -1);

    drawPill();

    ctx.restore();

    fade_out_rect(ctx, x, y + h + 1, w, h, 0.5, 0.0);
}


function draw_swatch( canvas, color ) {
    var ctx = canvas.getContext("2d");

    function draw_swatch_square() {
        ctx.fillStyle = color;
        ctx.fillRect(0, 0, 13, 13);

        var gradient = ctx.createLinearGradient(0, 0, 13, 13);
        gradient.addColorStop(0.0, "rgba(255, 255, 255, 0.2)");
        gradient.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");

        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, 13, 13);

        gradient = ctx.createLinearGradient(13, 13, 0, 0);
        gradient.addColorStop(0.0, "rgba(0, 0, 0, 0.2)");
        gradient.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");

        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, 13, 13);

        ctx.strokeStyle = "rgba(0, 0, 0, 0.6)";
        ctx.strokeRect(0.5, 0.5, 12, 12);
    }

    ctx.clearRect(0, 0, 13, 24);

    draw_swatch_square();

    ctx.save();

    ctx.translate(0, 25);
    ctx.scale(1, -1);

    draw_swatch_square();

    ctx.restore();

    fade_out_rect(ctx, 0, 13, 13, 13, 0.5, 0.0);
}


function make_legend_element( label, value, color ) {
    var legendElement = document.createElement("label");
    legendElement.className = "rspec-graph-legend-item " + label.replace(/\W+/g, '-');

    if (color) {
        var swatch = document.createElement("canvas");
        swatch.className = "rspec-graph-legend-swatch";
        swatch.setAttribute("width", "13");
        swatch.setAttribute("height", "24");

        legendElement.appendChild(swatch);

        draw_swatch(swatch, color);
    }

    var labelElement = document.createElement("div");
    labelElement.className = "rspec-graph-legend-label";
    legendElement.appendChild(labelElement);

    var headerElement = document.createElement("div");
    headerElement.className = "rspec-graph-legend-header";
    headerElement.textContent = label;
    labelElement.appendChild(headerElement);

    var valueElement = document.createElement("div");
    valueElement.className = "rspec-graph-legend-value";
    valueElement.textContent = value;
    labelElement.appendChild(valueElement);

    return legendElement;
}


function update_summary_graph() {
	var total = $('#spec-count').eq(0).text();
	var graphInfo = {
		passed: $('.spec.passed'),
		pending: $('.spec.pending'),
		failed: $('.spec.failed'),
		'pending:fixed': $('.spec.pending-fixed'),
		total: parseInt( total, 10 )
	};

    var categoryOrder = ["passed", "pending", "pending:fixed", "failed"];
	var categoryColors = {
		passed: {r: 0, g: 157, b: 37},            // #009D25
		pending: {r: 227, g: 184, b: 0},          // #E3B800
		'pending:fixed': {r: 9, g: 60, b: 226},   // #093CE2
		failed: {r: 192, g: 0, b: 0}              // #C00000
	};
    var fillSegments = [];
	var doneCount = 0;

	var legendElement = $( '#rspec-summary-graph-legend' );
	legendElement.empty();

	jQuery.each( categoryOrder, function(i, val) {
        var category = categoryOrder[i];
        var size = graphInfo[ category ].length;
        if (!size) return true;
		doneCount += size;

        var color = categoryColors[category];
        var colorString = "rgb(" + color.r + ", " + color.g + ", " + color.b + ")";

        var fillSegment = {color: colorString, value: size};
        fillSegments.push(fillSegment);

        var legendLabel = make_legend_element( category, size, colorString );
        legendElement.append( legendLabel );
    });

    if ( graphInfo.total ) {
        var totalLegendLabel = make_legend_element( "remaining", graphInfo.total - doneCount );
        // totalLegendLabel.addStyleClass( "total" );
        legendElement.append( totalLegendLabel );
		if ( doneCount < graphInfo.total ) {
			var fillSegment = { color: 'rgb(254,254,254)', value: graphInfo.total - doneCount };
			console.log( "Adding segment for examples yet to run: " + fillSegment.toString() );
			fillSegments.push( fillSegment );
		}
    }

	draw_summary_graph( '#rspec-summary-graph', fillSegments );
}

function toggle_spec_status() {
	var status = $(this).attr( 'class' ).match( /(passed|pending(?:-fixed)?|failed)/ )[0];
	console.log( "Looking for specs with class '" + status + "'." );

	$( this ).removeClass( 'hidden' );
	$( 'label' ).not( this ).toggleClass( 'hidden' );
	$( '.spec.' + status ).show('fast');
	$( '.spec' ).not( '.' + status ).toggle('fast');
}

function hook_legend_clickables() {
	$('label.passed').click( toggle_spec_status );
	$('label.pending').click( toggle_spec_status );
	$('label.pending-fixed').click( toggle_spec_status );
	$('label.failed').click( toggle_spec_status );
}

function hook_log_clickables() {
	$('.spec:has(div.log-messages)').each( function() {
		$(this).addClass( 'logged' );
	}).find( '.spec-name' ).click( function(e) {
		$(this).parent().find('div.log-messages').toggle();
	});
}

$(document).ready(function() {
	console.log( "Document is ready." );
	clearInterval( polltimer );

	$('#rspec-summary-stats').html( 'Finished in ' + $('#summary .duration').html() );
	
	update_summary_graph();
	hook_legend_clickables();
	hook_log_clickables();
});

polltimer = setInterval( update_summary_graph, 250 );

